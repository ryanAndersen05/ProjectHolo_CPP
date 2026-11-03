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

option(PROJECT_HOLO_BUILD_PHYSICS_TESTS "Build character physics checks" OFF)
if(PROJECT_HOLO_BUILD_PHYSICS_TESTS)
    add_executable(ProjectHoloPhysicsTests
            tests/physics/EHPhysicsTests.cpp
            src/core/EHActor.cpp
            src/core/EHActorComponent.cpp
            src/library/EHLibrary.cpp
            src/physics/EHPhyicsComponent.cpp
            src/physics/EHBoxColliderComponent.cpp
            src/physics/EHPhysicsSystem.cpp)
    target_include_directories(ProjectHoloPhysicsTests PRIVATE
            $<TARGET_PROPERTY:ProjectHolo_CPP,INCLUDE_DIRECTORIES>)
    target_compile_features(ProjectHoloPhysicsTests PRIVATE cxx_std_20)
    target_compile_options(ProjectHoloPhysicsTests PRIVATE
            $<TARGET_PROPERTY:ProjectHolo_CPP,COMPILE_OPTIONS>)
    target_link_libraries(ProjectHoloPhysicsTests PRIVATE SFML::Graphics)
    enable_testing()
    add_test(NAME character-physics COMMAND ProjectHoloPhysicsTests)
    if(WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        get_filename_component(PHYSICS_TEST_COMPILER_DIR "${CMAKE_CXX_COMPILER}" DIRECTORY)
        set_property(TEST character-physics APPEND PROPERTY ENVIRONMENT_MODIFICATION
                "PATH=path_list_prepend:${PHYSICS_TEST_COMPILER_DIR}")
    endif()
endif()

option(PROJECT_HOLO_BUILD_INPUT_TESTS "Build directional input checks" OFF)
if(PROJECT_HOLO_BUILD_INPUT_TESTS)
    set(INPUT_TEST_SOURCES ${SRC_FILES})
    list(REMOVE_ITEM INPUT_TEST_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp")
    add_executable(ProjectHoloInputTests tests/input/EHDirectionalInputTests.cpp ${INPUT_TEST_SOURCES})
    target_include_directories(ProjectHoloInputTests PRIVATE
            $<TARGET_PROPERTY:ProjectHolo_CPP,INCLUDE_DIRECTORIES>)
    target_compile_features(ProjectHoloInputTests PRIVATE cxx_std_20)
    target_compile_options(ProjectHoloInputTests PRIVATE
            $<TARGET_PROPERTY:ProjectHolo_CPP,COMPILE_OPTIONS>)
    target_link_libraries(ProjectHoloInputTests PRIVATE
            SFML::Graphics SFML::Window SFML::System SFML::Audio SFML::Network
            ${CMAKE_CURRENT_SOURCE_DIR}/include/lua/liblua54.a)
    enable_testing()
    add_test(NAME directional-input COMMAND ProjectHoloInputTests)
    set_tests_properties(directional-input PROPERTIES
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/tests/input/fixtures")
    if(WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        get_filename_component(INPUT_TEST_COMPILER_DIR "${CMAKE_CXX_COMPILER}" DIRECTORY)
        set_property(TEST directional-input APPEND PROPERTY ENVIRONMENT_MODIFICATION
                "PATH=path_list_prepend:${INPUT_TEST_COMPILER_DIR}")
    endif()
endif()

option(PROJECT_HOLO_BUILD_CAMERA_TESTS "Build follow camera checks" OFF)
if(PROJECT_HOLO_BUILD_CAMERA_TESTS)
    set(CAMERA_TEST_SOURCES ${SRC_FILES})
    list(REMOVE_ITEM CAMERA_TEST_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp")
    add_executable(ProjectHoloCameraTests tests/camera/EHFollowCameraTests.cpp ${CAMERA_TEST_SOURCES})
    target_include_directories(ProjectHoloCameraTests PRIVATE
            $<TARGET_PROPERTY:ProjectHolo_CPP,INCLUDE_DIRECTORIES>)
    target_compile_features(ProjectHoloCameraTests PRIVATE cxx_std_20)
    target_compile_options(ProjectHoloCameraTests PRIVATE
            $<TARGET_PROPERTY:ProjectHolo_CPP,COMPILE_OPTIONS>)
    target_link_libraries(ProjectHoloCameraTests PRIVATE
            SFML::Graphics SFML::Window SFML::System SFML::Audio SFML::Network
            ${CMAKE_CURRENT_SOURCE_DIR}/include/lua/liblua54.a)
    enable_testing()
    add_test(NAME follow-camera COMMAND ProjectHoloCameraTests)
    set_tests_properties(follow-camera PROPERTIES
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/tests/camera/fixtures")
    if(WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        get_filename_component(CAMERA_TEST_COMPILER_DIR "${CMAKE_CXX_COMPILER}" DIRECTORY)
        set_property(TEST follow-camera APPEND PROPERTY ENVIRONMENT_MODIFICATION
                "PATH=path_list_prepend:${CAMERA_TEST_COMPILER_DIR}")
    endif()
endif()

option(PROJECT_HOLO_BUILD_PARALLAX_TESTS "Build parallax world checks" OFF)
if(PROJECT_HOLO_BUILD_PARALLAX_TESTS)
    set(PARALLAX_TEST_SOURCES ${SRC_FILES})
    list(REMOVE_ITEM PARALLAX_TEST_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp")
    add_executable(ProjectHoloParallaxTests tests/parallax/EHParallaxWorldTests.cpp ${PARALLAX_TEST_SOURCES})
    target_include_directories(ProjectHoloParallaxTests PRIVATE
            $<TARGET_PROPERTY:ProjectHolo_CPP,INCLUDE_DIRECTORIES>)
    target_compile_features(ProjectHoloParallaxTests PRIVATE cxx_std_20)
    target_compile_options(ProjectHoloParallaxTests PRIVATE
            $<TARGET_PROPERTY:ProjectHolo_CPP,COMPILE_OPTIONS>)
    target_link_libraries(ProjectHoloParallaxTests PRIVATE
            SFML::Graphics SFML::Window SFML::System SFML::Audio SFML::Network
            ${CMAKE_CURRENT_SOURCE_DIR}/include/lua/liblua54.a)
    enable_testing()
    add_test(NAME parallax-world COMMAND ProjectHoloParallaxTests)
    if(WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        get_filename_component(PARALLAX_TEST_COMPILER_DIR "${CMAKE_CXX_COMPILER}" DIRECTORY)
        set_property(TEST parallax-world APPEND PROPERTY ENVIRONMENT_MODIFICATION
                "PATH=path_list_prepend:${PARALLAX_TEST_COMPILER_DIR}")
    endif()
endif()
