import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQuick.XmlListModel 2.12
import QtLocation 5.14

Page {
    property var defaultZoom: 20
    property var position;

    onPositionChanged: {
        poiCurrent.coordinate = src.position.coordinate;
    }

    function giveFocusToSearch() {
        searchTextInput.forceActiveFocus();
    }

    function clear() {
        searchTextInput.clear();
        geocodeModel.reset();
    }

    header: ToolBar {
        contentHeight: goBackButton.implicitHeight

        ToolButton {
            anchors.left: parent.left
            id: goBackButton
            text: "\u25C0"
            visible: mainStackView.depth > 1
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (mainStackView.depth > 1) {
                    mainStackView.pop(StackView.Immediate);
                }
            }
        }

        TextInput {
            id: searchTextInput
            anchors.left: goBackButton.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            verticalAlignment: Qt.AlignVCenter

            Text {
                id: searchPlaceHolderText
                anchors.fill: parent
                verticalAlignment: Qt.AlignVCenter

                text: qsTr("Search for an address...")
                color: "#aaa"
                visible: !searchTextInput.text
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottomMargin: 5

                height: 1
                color: searchPlaceHolderText.color
            }

            onTextEdited: {
                geocodeModel.query = searchTextInput.text;
                geocodeModel.update();
            }
        }
    }

    GeocodeModel {
        id: geocodeModel
        plugin: map.plugin
        autoUpdate: false

        onStatusChanged: {
            if (status == GeocodeModel.Error) {
                console.log("GeocodeModel error: " + errorString);
            } else if (status == GeocodeModel.Null) {
                console.log("GeocodeModel null");
            } else if (status == GeocodeModel.Loading) {
                console.log("GeocodeModel loading");
            } else {
                console.log("GeocodeModel ready");
            }
        }
        onLocationsChanged: {
            if(count > 0) {
                console.log("GeocodeModel count: " + count);
                console.log("GeocodeModel 0: " + JSON.stringify(get(0)));
                poiCurrent.visible = false;
                map.fitViewportToVisibleMapItems();
                poiCurrent.visible = true;

                addressesListView.currentIndex = 0;
                reverseXmlModel.reverseSearch(get(0).coordinate);
            } else {
                //TODO search for close by locations
                //TODO if no results, search in larger bounds
            }
        }
    }

    // https://github.com/costales/unav/blob/master/qml/Main.qml#L601
    XmlListModel {
        id: reverseXmlModel

        readonly property string baseUrl: "https://nominatim.openstreetmap.org/reverse?format=xml&addressdetails=0&extratags=1&zoom=18&namedetails=1&"

        function reverseSearch(coordinate) {
            source = (baseUrl + "lat=" + coordinate.latitude + "&lon=" + coordinate.longitude);
        }

        function clear() {
            source = "";
        }

        onStatusChanged: {
            console.log("reverseXmlModel onStatusChanged")
            if (status === XmlListModel.Error || (status === XmlListModel.Ready && count === 0)) {
                console.log("Error reverse geocoding the location!")
            } else if (status === XmlListModel.Ready) {
                if(count > 0) {
                    console.log(JSON.stringify(reverseXmlModel.get(0)));
                    // Check if the location returned by reverse geocoding is a POI by looking for the existence of certain parameters
                    // like cuisine, phone, opening_hours, internet_access, wheelchair etc that do not apply to a generic address
                    if(reverseXmlModel.get(0).description
                    || reverseXmlModel.get(0).cuisine
                    || reverseXmlModel.get(0).phone
                    || reverseXmlModel.get(0).contactphone
                    || reverseXmlModel.get(0).opening_hours) {
                        //TODO
                    } else {
                        //TODO
                    }
                } else {
                    //TODO
                }
            }
        }

        source: ""
        query: "/reversegeocode"

        XmlRole { name: "osm_type"; query: "result/@osm_type/string()" }
        XmlRole { name: "osm_id"; query: "result/@osm_id/string()" }
        XmlRole { name: "result"; query: "result/string()" }
        XmlRole { name: "name"; query: "namedetails/name[1]/string()" }
        XmlRole { name: "description"; query: "extratags/tag[@key='description']/@value/string()" }
        XmlRole { name: "cuisine"; query: "extratags/tag[@key='cuisine']/@value/string()" }
        XmlRole { name: "opening_hours"; query: "extratags/tag[@key='opening_hours']/@value/string()" }
        XmlRole { name: "phone"; query: "extratags/tag[@key='phone']/@value/string()" }
        XmlRole { name: "contactphone"; query: "extratags/tag[@key='contact:phone']/@value/string()" }
    }

    Item {
        id: panes
        anchors.fill: parent

        Item {
            id: sidePane
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.width * 0.33

            ListView {
                id: addressesListView
                anchors.fill: parent
                spacing: 5

                model: geocodeModel
                delegate: RowLayout {
                    Rectangle {
                        color: addressesListView.currentIndex == index ? "aquamarine" : "lightgrey"
                        width: addressesListView.width
                        height: childrenRect.height

                        RowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            TextEdit {
                                Layout.margins: 5
                                Layout.fillWidth: true
                                text: locationData.address.text
                                readOnly: true
                                wrapMode: Text.WordWrap
                                selectByMouse: true
                                font.bold: true

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        map.center = locationData.coordinate;
                                        map.zoomLevel = map.maximumZoomLevel;

                                        addressesListView.currentIndex = index;
                                        reverseXmlModel.reverseSearch(locationData.coordinate);
                                    }
                                }
                            }

//                            RoundButton {
//                                Layout.margins: 5
//                                Layout.alignment: Qt.AlignRight
//                                id: goToButton
//                                text: ">"

//                                onClicked: {
//                                    //TODO
//                                }
//                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: infoPane
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left: sidePane.right

            Rectangle {
                Layout.fillWidth: true
                height: 100

                //TODO
                color: "aquamarine"
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Map {
                    anchors.fill: parent
                    id: map
                    plugin: Plugin { name: "osm" }
                    zoomLevel: defaultZoom

                    MapQuickItem {
                        id: poiCurrent
                        sourceItem: Rectangle { width: 14; height: 14; color: "#1e25e4"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
                        opacity: 1.0
                        anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                    }

                    MapQuickItem {
                        id: poiSelected
                        sourceItem: Rectangle { width: 14; height: 14; color: "red"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
                        opacity: 1.0
                        anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                    }

                    MapItemView {
                        id: mapItemView
                        model: geocodeModel
                        //autoFitViewport: true
                        delegate: MapQuickItem {
                            id: point
                            sourceItem: Rectangle { width: 14; height: 14; color: "magenta"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
                            opacity: 1.0
                            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                            coordinate: locationData.coordinate
                        }
                    }
                }

                RoundButton {
                    id: centerOnPositionButton
                    width: 40
                    height: 40
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 20
                    anchors.bottomMargin: 20

                    text: "X"
                    font.pixelSize: Qt.application.font.pixelSize * 1.6
                    onClicked: {
                        map.center = position;
                    }
                }
            }
        }
    }
}

