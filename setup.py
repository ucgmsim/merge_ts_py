from Cython.Build import cythonize
from setuptools import Extension, setup

# Define Cython extension module
extensions = [Extension("merge_ts.merge_ts_loop", ["merge_ts/merge_ts_loop.pyx"])]

setup(
    name="merge_ts",
    version="1.0",
    packages=["merge_ts"],
    ext_modules=cythonize(extensions),
    install_requires=[
        "cython",
        "typer",
        "qcore @ git+https://github.com/ucgmsim/qcore",
        "setuptools",
        "typer",
        "typing_extensions",
    ],
    entry_points={"console_scripts": ["merge_ts=merge_ts.merge_ts:main"]},
)
