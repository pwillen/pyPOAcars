from setuptools import Extension, setup
from Cython.Build import cythonize

include_dirs = "/usr/local/include/libacars-2/"
library_dirs = "/usr/local/lib/"

setup(
    ext_modules=cythonize(
        [
            Extension(
                "libacars",
                ["libacars.pyx"],
                include_dirs=[include_dirs],
                libraries=["acars-2"],
                library_dirs=[library_dirs],
            )
        ]
    )
)
