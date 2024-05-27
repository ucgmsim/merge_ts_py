import os

import cython

from libc.stdlib cimport free, malloc

cdef extern from "sys/types.h":
    ctypedef long off_t
cdef extern from "sys/sendfile.h":
    ssize_t sendfile(int out_fd, int in_fd, off_t * offset, size_t count)

def merge_fds(
    int merged_fd, _component_xyts_files, int merged_nt, int merged_ny, _local_nxs, _local_nys, _y0s
):
    cdef int float_size, cur_timestep, cur_component, cur_y, i, y0, local_ny, local_nx, xyts_fd, n_files

    cdef int *component_xyts_files, *local_nxs, *local_nys, *y0s

    n_files = len(_component_xyts_files)

    # The lists _component_xyts_files, ... are CPython lists.
    # If we access these inside our copying loop everything becomes very slow
    # because we need to go to the Python interpreter. So we first copy the each
    # list into an equivalent C list.
    component_xyts_files = <int *> malloc(len(_component_xyts_files) * cython.sizeof(int))
    local_nxs = <int *> malloc(len(_local_nxs) * cython.sizeof(int))
    local_nys = <int *> malloc(len(_local_nys) * cython.sizeof(int))
    y0s = <int *> malloc(len(_y0s) * cython.sizeof(int))
    for i in range(len(_component_xyts_files)):
        component_xyts_files[i] = _component_xyts_files[i]
        local_nxs[i] = _local_nxs[i]
        local_nys[i] = _local_nys[i]
        y0s[i] = _y0s[i]

    for cur_timestep in range(merged_nt):
        for cur_component in range(3):  # for each component
            for cur_ in range(merged_ny):
                for i in range(n_files):
                    y0 = y0s[i]
                    local_ny = local_nys[i]
                    local_nx = local_nxs[i]
                    xyts_fd = component_xyts_files[i]
                    if y0 > cur_y or cur_y >= y0 + local_ny:
                        continue
                    # By passing None as the offset, sendfile() will read from
                    # the current position in xyts_fd
                    sendfile(merged_fd, xyts_fd, NULL, local_nx * 4)

    free(component_xyts_files)
    free(local_nxs)
    free(local_nys)
    free(y0s)
