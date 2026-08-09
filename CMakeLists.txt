cmake_minimum_required(VERSION 4.3)
project(ProjectHolo_CPP LANGUAGES CXX)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

include(FetchContent)
FetchContent_Declare(
        SFML
        GIT_REPOSITORY https://github.com/SFML/SFML.git
        GIT_TAG 3.0.2
        GIT_SHALLOW ON
        EXCLUDE_FROM_ALL
        SYSTEM
)
FetchContent_MakeAvailable(SFML)

# -----------------------
# Glob sources and headers
# -----------------------
file(GLOB_RECURSE SRC_FILES CONFIGURE_DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
)

file(GLOB_RECURSE HEADER_FILES CONFIGURE_DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/include/*.h
)

if(NOT SRC_FILES)
    message(WARNING "No source files found in ${CMAKE_CURRENT_SOURCE_DIR}/src")
endif()

add_executable(ProjectHolo_CPP
        ${SRC_FILES}
        ${HEADER_FILES}
)

if (MSVC)
    target_compile_options(ProjectHolo_CPP PRIVATE /W4 /WX)
else()
    target_compile_options(ProjectHolo_CPP PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()

target_include_directories(ProjectHolo_CPP PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

target_compile_features(ProjectHolo_CPP PRIVATE cxx_std_20)

target_include_directories(ProjectHolo_CPP PRIVATE include/nlohmann)
target_include_directories(ProjectHolo_CPP PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_include_directories(ProjectHolo_CPP PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/assets)
target_link_libraries(ProjectHolo_CPP PRIVATE SFML::Graphics SFML::Window SFML::System SFML::Audio SFML::Network)

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/assets")
    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/assets" DESTINATION "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
else()
    message(WARNING "assets folder not found")
endif()