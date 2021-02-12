import QtQuick 2.15
import QtLocation 5.15
import QtPositioning 5.15
import QtQuick.FreeVirtualKeyboard 1.0
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.15 as Controls

Item {
    id: mainItem

    InputPanel {
        id: inputPanel

        z: 99
        y: mainItem.height

        btnTextFontFamily: "monospace"

        anchors.left: parent.left
        anchors.right: parent.right

        states: State {
            name: "visible"
            when: Qt.inputMethod.visible
            PropertyChanges {
                target: inputPanel
                y: mainItem.height - inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    property var port: 50000
    property var host: "localhost"
    property string mapboxAccessToken
    property var defaultZoom: 12

    signal call(string phoneNumber);
    signal tell(string instruction, string distance);

    Plugin {
        id: mapPlugin
        name: "mapboxgl"

        PluginParameter { name: "mapbox.access_token"; value: mapboxAccessToken }
    }

    Plugin {
        id: geoPlugin
        name: "mapbox"

        PluginParameter { name: "mapbox.access_token"; value: mapboxAccessToken }
    }

    PositionSource {
        id: positionSource
        updateInterval: 500
        active: false
        //        name: "gpsd"
        name: "fake"
        
        PluginParameter { name: "port"; value: port }
        PluginParameter { name: "host"; value: host }

        Component.onCompleted: {
            console.log("PositionSource ready");
            positionSource.start();
        }

        onPositionChanged: {
            driver.update();
        }

        onSourceErrorChanged: {
            switch(sourceError) {
            case PositionSource.AccessError:
                console.log("AccessError"); break;
            case PositionSource.ClosedError:
                console.log("ClosedError"); break;
            case PositionSource.NoError:
                console.log("NoError"); break;
            case PositionSource.UnknownSourceError:
                console.log("UnknownSourceError"); break;
            case PositionSource.AccessError:
                console.log("SocketError"); break;
            }

        }

        onUpdateTimeout: {
            console.log("Update timeout");
        }

        onActiveChanged: {
            console.log("Active: " + active);
        }
    }

    SearchPage {
        id: searchPage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: parent.width / 3
    }

    Driver {
        id: driver
    }

    DrivingMap {
        id: map
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: searchPage.right
        plugin: mapPlugin
    }
}
