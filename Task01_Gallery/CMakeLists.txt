cmake_minimum_required(VERSION 3.16)

project(Task01_Gallery VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appTask01_Gallery
    main.cpp
    Backend/info.cpp
)

qt_add_qml_module(appTask01_Gallery
    URI Task01_Gallery
    VERSION 1.0
    QML_FILES
        Main.qml
        Widgets/TempWidget.qml
        Widgets/HumidityWidget.qml
        Widgets/WindWidget.qml
        Widgets/GalleryWidget.qml
        Widgets/AboutWidget.qml
        Pages/AboutPopupPage.qml
        Pages/ImagePopupPage.qml
        Pages/GalleryPage.qml
    RESOURCES 
        resources.qrc
)

set_target_properties(appTask01_Gallery PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTask01_Gallery
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appTask01_Gallery
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
