file(COPY_FILE "${jegp.cmake_modules_SOURCE_DIR}/.cmake-format-additional_commands.yaml"
     "${CMAKE_CURRENT_SOURCE_DIR}/cmake/.cmake-format-additional_commands-jegp.cmake_modules.yaml" ONLY_IF_DIFFERENT)
file(COPY_FILE "${CPM.cmake_SOURCE_DIR}/cmake/.cmake-format-additional_commands-cpm"
     "${CMAKE_CURRENT_SOURCE_DIR}/cmake/.cmake-format-additional_commands-cpm" ONLY_IF_DIFFERENT)
