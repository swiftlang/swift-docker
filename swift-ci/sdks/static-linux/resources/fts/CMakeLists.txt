# ===----------------------------------------------------------------------===
#
#  Swift Static SDK for Linux: Build libfts
#
#  This source file is part of the Swift.org open source project
#
#  Copyright (c) 2024 Apple Inc. and the Swift project authors
#  Licensed under Apache License v2.0 with Runtime Library Exception
#
#  See https://swift.org/LICENSE.txt for license information
#  See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
#
# ===----------------------------------------------------------------------===

cmake_minimum_required(VERSION 3.22.1)

project(fts)

add_library(fts STATIC fts.c)
set_target_properties(fts PROPERTIES PUBLIC_HEADER fts.h)
target_include_directories(fts PRIVATE SYSTEM ${CMAKE_CURRENT_SOURCE_DIR})

install(TARGETS fts
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
