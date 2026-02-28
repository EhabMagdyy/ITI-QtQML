cmake_minimum_required(VERSION 3.16)

project(Task_1 VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appTask_1
    main.cpp
)

qt_add_qml_module(appTask_1
    URI Task_1
    VERSION 1.0
    QML_FILES
        Main.qml
        MainScreenWidgets/TempWidget.qml
        MainScreenWidgets/HumidityWidget.qml
        MainScreenWidgets/GalleryWidget.qml
        MainScreenWidgets/AboutWidget.qml
        Pages/AboutPopupPage.qml
        Pages/ImagePopupPage.qml
        Pages/GalleryPage.qml
    RESOURCES 
        resources.qrc
)

set_target_properties(appTask_1 PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTask_1
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appTask_1
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
