import QtQuick 2.5
import QtQuick.Controls 2.14
import QtLocation 5.14
import QtPositioning 5.14

Item {
    id: mainItem

    property var portname: "/dev/pts/0"
    property string mapboxAccessToken

    signal call(phoneNumber: string);

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
        id: src
        updateInterval: 500
        active: false
        name: "fake"

        PluginParameter { name: "portname"; value: portname }

        Component.onCompleted: {
            console.log("PositionSource ready");
            src.start();
        }

        onPositionChanged: {
            mainPage.position = src.position.coordinate;
            searchPage.position = src.position.coordinate;
            routePage.position = src.position.coordinate;
            drivePage.position = src.position.coordinate;
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

    MainPage {
        id: mainPage
    }

    SearchPage {
        id: searchPage
        onCall: call(phoneNumber);
        onGoTo: function(latitude, longitude) {
            console.log("test")
            console.log(latitude)
            console.log(longitude)
            routePage.destinationCoordinate = QtPositioning.coordinate(latitude, longitude);
            mainStackView.push(routePage, StackView.Immediate);
            routePage.start();
        }
    }

    RoutePage {
        id: routePage
    }

    DrivePage {
        id: drivePage
    }

    StackView {
        id: mainStackView
        initialItem: mainPage
        anchors.fill: parent
    }
}
