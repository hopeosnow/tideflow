cmake_minimum_required(VERSION 3.21)
project(TideflowLaunch VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 6.5 REQUIRED COMPONENTS
        Core Gui Qml Quick QuickControls2
)

qt_standard_project_setup()
qt_policy(SET QTP0001 NEW)          # ← 消掉 QTP0001 警告

qt_add_executable(tideflow-launch main.cpp)

qt_add_qml_module(tideflow-launch
        URI Tideflow
        VERSION 1.0
        QML_FILES Main.qml              # ← 文件名必须大写开头
)

target_link_libraries(tideflow-launch PRIVATE
        Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2
)