cmake_minimum_required(VERSION 3.28)
project(tideflow LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


set(CMAKE_AUTOMOC ON)  # 自动处理 Q_OBJECT 宏
set(CMAKE_AUTORCC ON)  # 自动处理 .qrc 资源文件
set(CMAKE_AUTOUIC ON)  # 自动处理 .ui 文件（如果你以后用 Qt Designer）

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

add_subdirectory(launch)