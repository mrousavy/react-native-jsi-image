cmake_minimum_required(VERSION 3.4.1)

set (CMAKE_VERBOSE_MAKEFILE ON)
set (CMAKE_CXX_STANDARD 11)

add_library(jsi-image
            SHARED
            cpp-adapter.cpp
            JsiImage.cpp
            ../cpp/TypedArray/TypedArray.cpp
)

include_directories(
                    ./android
                    ../cpp
                    # RN JSI sources
)
