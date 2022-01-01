import QtQuick 2.15
import QtLocation 5.15
import QtPositioning 5.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.15 as Controls

import KarunitPlugins 1.0

Item {
    id: mainItem

    property int port: 50000
    property string host: "localhost"
    property string mapboxAccessToken: KUPNavPluginConnector.mapboxAccessToken
    property int defaultZoom: 12

    function call(phoneNumber) {
        KUPNavPluginConnector.call(phoneNumber)
    }

    function tell(instruction, distance) {
        KUPNavPluginConnector.tell(instruction, distance)
    }

    function loadPlaces() {
        console.log("loadPlaces")
        searchPage.model.loadPlaces()
    }

    function savePlaces() {
        console.log("savePlaces")
        searchPage.model.savePlaces()
    }

    Component.onCompleted: {
        loadPlaces()
    }

    Component.onDestruction: {
        savePlaces()
    }

    Plugin {
        id: mapPlugin
        name: "mapboxgl"

        PluginParameter {
            name: "mapbox.access_token"
            value: mapboxAccessToken
        }
    }

    Plugin {
        id: geoPlugin
        name: "mapbox"

        PluginParameter {
            name: "mapbox.access_token"
            value: mapboxAccessToken
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 500
        active: false
        //        name: "gpsd"
        name: "fake"

        PluginParameter {
            name: "port"
            value: port
        }
        PluginParameter {
            name: "host"
            value: host
        }

        Component.onCompleted: {
            console.log("PositionSource ready")
            positionSource.start()
        }

        onPositionChanged: {
            driver.update()
        }

        onSourceErrorChanged: {
            switch (sourceError) {
            case PositionSource.AccessError:
                console.log("AccessError")
                break
            case PositionSource.ClosedError:
                console.log("ClosedError")
                break
            case PositionSource.NoError:
                console.log("NoError")
                break
            case PositionSource.UnknownSourceError:
                console.log("UnknownSourceError")
                break
            case PositionSource.AccessError:
                console.log("SocketError")
                break
            }
        }

        onUpdateTimeout: {
            console.log("Update timeout")
        }

        onActiveChanged: {
            console.log("Active: " + active)
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
