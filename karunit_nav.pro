TEMPLATE        = lib
CONFIG         += plugin c++17
DEFINES        += QT_DEPRECATED_WARNINGS
QT             += qml quick xml Kirigami2
TARGET          = karunit_nav_plugin
DESTDIR         = $$PWD/../karunit/app/plugins

unix {
target.path = /usr/local/bin/plugins
INSTALLS += target
}

LIBS += -L$$PWD/../karunit/plugininterface/ -lkarunit_plugininterface
INCLUDEPATH += $$PWD/../karunit/plugininterface

LIBS += -L$$PWD/../karunit/common/ -lkarunit_common
INCLUDEPATH += $$PWD/../karunit/common

LIBS += -L$$PWD/../karunit/third-party/xblog/lib -lxblog
INCLUDEPATH += $$PWD/../karunit/third-party/xblog/include

SUBDIRS += \
    src/ \
    res/

include(src/src.pri)
include(res/res.pri)
