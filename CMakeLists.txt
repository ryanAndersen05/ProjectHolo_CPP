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
target_include_directories(ProjectHolo_CPP PRIVATE include/lua/include)
target_include_directories(ProjectHolo_CPP PRIVATE include/sol)
target_include_directories(ProjectHolo_CPP PRIVATE include/lua)
target_include_directories(ProjectHolo_CPP PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_include_directories(ProjectHolo_CPP PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/assets)
target_include_directories(ProjectHolo_CPP PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/shaders)
target_link_libraries(ProjectHolo_CPP PRIVATE SFML::Graphics SFML::Window SFML::System SFML::Audio SFML::Network)
target_link_libraries(ProjectHolo_CPP PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include/lua/liblua54.a)

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/assets")
    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/assets" DESTINATION "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
else()
    message(WARNING "assets folder not found")
endif()

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/shaders")
    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/shaders" DESTINATION "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
else()
    message(WARNING "shaders folder not found")
endif()

option(PROJECT_HOLO_BUILD_HITBOX_TESTS "Build the hitbox C++/Lua smoke checks" OFF)
if(PROJECT_HOLO_BUILD_HITBOX_TESTS)
    set(HITBOX_TEST_SOURCES ${SRC_FILES})
    list(REMOVE_ITEM HITBOX_TEST_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp")
    add_executable(ProjectHoloHitboxTests
            tests/hitbox/EHHitboxSmokeTests.cpp
            ${HITBOX_TEST_SOURCES}
    )
    target_include_directories(ProjectHoloHitboxTests PRIVATE
            $<TARGET_PROPERTY:ProjectHolo_CPP,INCLUDE_DIRECTORIES>)
    target_compile_features(ProjectHoloHitboxTests PRIVATE cxx_std_20)
    target_compile_options(ProjectHoloHitboxTests PRIVATE
            $<TARGET_PROPERTY:ProjectHolo_CPP,COMPILE_OPTIONS>)
    target_link_libraries(ProjectHoloHitboxTests PRIVATE
            SFML::Graphics SFML::Window SFML::System SFML::Audio SFML::Network
            ${CMAKE_CURRENT_SOURCE_DIR}/include/lua/liblua54.a)

    enable_testing()
    add_test(NAME hitbox-control COMMAND ProjectHoloHitboxTests)
    set_tests_properties(hitbox-control PROPERTIES
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/tests/hitbox/fixtures")
    if(WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        get_filename_component(HITBOX_TEST_COMPILER_DIR "${CMAKE_CXX_COMPILER}" DIRECTORY)
        set_property(TEST hitbox-control APPEND PROPERTY ENVIRONMENT_MODIFICATION
                "PATH=path_list_prepend:${HITBOX_TEST_COMPILER_DIR}")
    endif()
endif()
