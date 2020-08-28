import QtQuick 2.5
import QtQuick.Controls 2.14
import QtLocation 5.14
import QtPositioning 5.14

Item {
    id: mainItem

    property var port: 50000
    property var host: "localhost"
    property string mapboxAccessToken
    property var defaultZoom: 12

    signal call(phoneNumber: string);
    signal tell(instruction: string, distance: string);

    function formatTime(sec) {
        var value = sec
        var seconds = value % 60
        value /= 60
        value = (value > 1) ? Math.round(value) : 0
        var minutes = value % 60
        value /= 60
        value = (value > 1) ? Math.round(value) : 0
        var hours = value
        if (hours > 0) {
            if(minutes < 10) minutes = "0"+minutes;
            value = hours + "h"+ minutes + "m"
        }
        else value = minutes + " min"
        return value
    }

    function formatDistance(meters) {
        var dist = Math.round(meters)
        if (dist > 1000 ){
            if (dist > 100000){
                dist = Math.round(dist / 1000)
            }
            else{
                dist = Math.round(dist / 100)
                dist = dist / 10
            }
            dist = dist + " km"
        }
        else{
            dist = dist + " m"
        }
        return dist
    }

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

        PluginParameter { name: "port"; value: port }
        PluginParameter { name: "host"; value: host }

        Component.onCompleted: {
            console.log("PositionSource ready");
            src.start();
        }

        onPositionChanged: {
            mainPage.position = src.position.coordinate;
            searchPage.position = src.position.coordinate;
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
            console.log("goTo")
            console.log(latitude)
            console.log(longitude)
            drivePage.destinationCoordinate = QtPositioning.coordinate(latitude, longitude);
            mainStackView.push(drivePage, StackView.Immediate);
            drivePage.start();
            drivePage.fitItems();
        }
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
