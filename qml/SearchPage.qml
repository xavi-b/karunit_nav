import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQuick.XmlListModel 2.12
import QtQml.Models 2.1
import QtLocation 5.14
import QtPositioning 5.14

Page {
    property var position;
    property var currentIndexCoordinate;
    property var mapCenter;

    onPositionChanged: {
        poiCurrent.coordinate = position;
    }

    function giveFocusToSearch() {
        searchTextInput.forceActiveFocus();
        map.center = mapCenter;
    }

    function clear() {
        searchTextInput.clear();
        placeSearchModel.reset();
    }

    signal call(phoneNumber: string);
    signal goTo(latitude: double, longitude: double);

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

            onEditingFinished: {
                placeSearchModel.searchTerm = searchTextInput.text;
                placeSearchModel.searchArea = QtPositioning.circle(position);
                //placeSearchModel.searchArea = map.visibleArea;
                placeSearchModel.update();
            }
        }
    }

    PlaceSearchModel {
        id: placeSearchModel
        plugin: geoPlugin

        relevanceHint: PlaceSearchModel.DistanceHint

        onStatusChanged: {
            switch (status) {
            case PlaceSearchModel.Ready:
//                poiCurrent.visible = false;
//                map.fitViewportToVisibleMapItems();
//                poiCurrent.visible = true;
                break;
            case PlaceSearchModel.Error:
                console.log(errorString());
                break;
            }
        }

    }

    property var currentPlace: Place;

    function focusOnPlace(place) {
        console.log("focusOnPlace");
        map.center = place.location.coordinate;
        map.zoomLevel = defaultZoom;

        currentIndexCoordinate = QtPositioning.coordinate(place.location.coordinate.latitude, place.location.coordinate.longitude);
        if (!place.detailsFetched) {
            place.getDetails();
            currentPlace = place;
        }
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

                model: placeSearchModel
                delegate: RowLayout {
                    Rectangle {
                        color: "lightgrey"
                        width: addressesListView.width
                        height: childrenRect.height

                        RowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            Text {
                                Layout.margins: 5
                                Layout.fillWidth: true
                                text: title + "<br>" + place.location.address.text
                                wrapMode: Text.WordWrap
                                font.bold: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                focusOnPlace(place);
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: infoPane
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left: sidePane.right

            Rectangle {
                id: infoRectangle
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: panes.height * 0.25
                color: "aquamarine"

                //TODO place infos
                RowLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: goButton.top

                    TextEdit {
                        Layout.margins: 5
                        Layout.fillWidth: true
                        text: "Phone: " + (currentPlace.primaryPhone ? currentPlace.primaryPhone : "NONE")
                        readOnly: true
                        wrapMode: Text.WordWrap
                        selectByMouse: true
                        font.bold: true
                    }

                    RoundButton {
                        Layout.margins: 5
                        Layout.alignment: Qt.AlignRight
                        id: callButton
                        visible: currentPlace.primaryPhone ? true : false

                        font.family: "Font Awesome 5 Free"
                        text: "\uf192"
                        onClicked: {
                            if(currentPlace.primaryPhone) {
                                mainItem.call(currentPlace.primaryPhone);
                            }
                        }
                    }
                }

                Button {
                    id: goButton
                    text: "Go"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    onClicked: {
                        searchPage.goTo(currentIndexCoordinate.latitude, currentIndexCoordinate.longitude);
                    }
                }
            }

            Item {
                anchors.top: infoRectangle.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                Map {
                    anchors.fill: parent
                    id: map
                    plugin: mapPlugin
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
                        model: placeSearchModel
                        //autoFitViewport: true
                        delegate: MapQuickItem {
                            id: point
                            sourceItem: Rectangle {
                                width: 30
                                height: width
                                color: "magenta"
                                border.width: 2
                                border.color: "white"
                                smooth: true
                                radius: width/2

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        focusOnPlace(place);
                                    }
                                }
                            }
                            opacity: 1.0
                            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                            coordinate: place.location.coordinate
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

                    font.family: "Font Awesome 5 Free"
                    text: "\uf192"
                    onClicked: {
                        map.center = position;
                    }
                }
            }
        }
    }
}

