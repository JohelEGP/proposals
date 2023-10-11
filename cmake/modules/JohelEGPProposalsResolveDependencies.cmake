include("${CMAKE_CURRENT_LIST_DIR}/JohelEGPProposalsDownloadCPM.cmake")

CPMAddPackage("gh:JohelEGP/jegp.cmake_modules#std-src")
CPMAddPackage("gh:cpm-cmake/CPM.cmake#master")

list(APPEND CMAKE_MODULE_PATH "${jegp.cmake_modules_SOURCE_DIR}/modules")

include("${CMAKE_CURRENT_LIST_DIR}/JohelEGPProposalsUpdateDependencyCopies.cmake")
