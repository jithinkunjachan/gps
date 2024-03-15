# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(gps_library VERSION 0.0.1 LANGUAGES C)

add_library(gps SHARED
  "gps.c"
)

set_target_properties(gps PROPERTIES
  PUBLIC_HEADER gps.h
  OUTPUT_NAME "gps"
)

target_compile_definitions(gps PUBLIC DART_SHARED_LIB)
