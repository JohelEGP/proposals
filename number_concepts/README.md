# The design of a library of number concepts

This manual contains instructions on how to build the PDF.
File paths in commands are relative to this directory.

1. Configure: `cmake -S . -B <build directory>`
2. Build: `cmake --build <build directory> --target JohelEGP_Proposals_number_concepts-pdf`

Specify these variables to avoid the network overhead.
- [`CPM_SOURCE_CACHE`](https://github.com/cpm-cmake/CPM.cmake#cpm_source_cache)
- [`CPM_<dependency name>_SOURCE`](https://github.com/cpm-cmake/CPM.cmake#local-package-override)
  for these dependencies:
  * [jegp.cmake_modules](https://github.com/JohelEGP/jegp.cmake_modules/)
  * [CPM.cmake](https://github.com/cpm-cmake/CPM.cmake)
- [`JEGP_STANDARDESE_SOURCES_GIT_REPOSITORY`](https://github.com/JohelEGP/jegp.cmake_modules/tree/std-src#variables-that-change-behavior)
