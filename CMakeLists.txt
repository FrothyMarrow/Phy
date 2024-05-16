cmake_minimum_required(VERSION 3.5)

project(Phy)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_C_STANDARD 11)

add_executable(phy)

find_package(OpenGL REQUIRED)
find_package(GLFW3 REQUIRED)

target_sources(phy PRIVATE
        src/main.c
        src/vector.c
)

target_include_directories(phy PRIVATE
    include
)

target_link_libraries(phy PRIVATE
        glfw
        "-framework OpenGL"
)
