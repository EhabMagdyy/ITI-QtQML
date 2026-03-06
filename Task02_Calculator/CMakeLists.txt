cmake_minimum_required(VERSION 3.16)

project(Task02_Calculator VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find the Qt6 package, specifically the Quick module, which is required for this application.
find_package(Qt6 6.8 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appTask02_Calculator
    main.cpp
)
# Define a QML module named "Task02_Calculator" with version 1.0, and specify that it includes the QML file "Main.qml".
qt_add_qml_module(appTask02_Calculator
    URI Task02_Calculator
    VERSION 1.0
    QML_FILES
        Main.qml
        MButton.qml
    RESOURCES resources.qrc
)

set_target_properties(appTask02_Calculator PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTask02_Calculator
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appTask02_Calculator
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
