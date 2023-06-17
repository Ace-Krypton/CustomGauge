cmake_minimum_required(VERSION 3.16)

project(Speedometer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Quick Quick3D)

qt_standard_project_setup()

qt_add_executable(appSpeedometer
    main.cpp
)

qt_add_qml_module(appSpeedometer
    URI Speedometer
    VERSION 1.0
    QML_FILES Main.qml Gauge.qml
)

set_target_properties(appSpeedometer PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appSpeedometer
    PRIVATE Qt6::Quick
    PRIVATE Qt::Core
    PRIVATE Qt::Gui
    PRIVATE Qt::Quick3D
)

install(TARGETS appSpeedometer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
