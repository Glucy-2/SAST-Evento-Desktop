import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI
import SAST_Evento
import "../imports"
import "../window"

FluScrollablePage {
    id: control
    launchMode: FluPageType.SingleTask

    property var departmentJson
    property int departmentId: -1
    property var subscribeArr

    function loadDepartmentEventsPage() {
        statusMode = FluStatusViewType.Loading
        DepartmentEventsController.loadDepartmentsInfo()
    }

    function loadDepartmentEvents(departmentId) {
        DepartmentEventsController.loadDepartmentEvents(departmentId)
    }

    onErrorClicked: {
        loadDepartmentEventsPage()
    }
    errorButtonText: lang.lang_reload
    loadingText: lang.lang_loading

    Component.onCompleted: {
        loadDepartmentEventsPage()
    }

    Connections {
        target: DepartmentEventsController
        function onLoadDepartmentsSuccessEvent(json) {
            departmentJson = JSON.parse(json)
            var departmentArr = []
            for (var i = 0; i < departmentJson.length; ++i) {
                departmentArr.push(tree_view.createItem(
                                       departmentJson[i].departmentName,
                                       true, [], {
                                           "id": departmentJson[i].id
                                       }))
            }
            tree_view.updateData(departmentArr)
            if (UserHelper.permission === 1)
                statusMode = FluStatusViewType.Success
            else
                DepartmentEventsController.loadSubscribedDepartment()
        }
    }

    Connections {
        target: DepartmentEventsController
        function onLoadDepartmentsErrorEvent(message) {
            errorText = message
            statusMode = FluStatusViewType.Error
        }
    }

    Connections {
        target: DepartmentEventsController
        function onLoadDepartmentEventSuccessEvent() {
            statusMode = FluStatusViewType.Success
        }
    }

    Connections {
        target: DepartmentEventsController
        function onLoadDepartmentEventErrorEvent(message) {
            errorText = message
            statusMode = FluStatusViewType.Error
        }
    }

    Connections {
        target: DepartmentEventsController
        function onLoadSubscribedDepartmentsSuccessEvent(departmentJson) {
            subscribeArr = JSON.parse(departmentJson)
            statusMode = FluStatusViewType.Success
        }
    }

    Connections {
        target: DepartmentEventsController
        function onLoadSubscribedDepartmentsErrorEvent(message) {
            errorText = message
            statusMode = FluStatusViewType.Error
        }
    }

    Connections {
        target: DepartmentEventsController
        function onSubscribeSuccessEvent() {
            if (!subscribeButton.checked) {
                subscribeArr.push(departmentId)
                subscribeButton.checked = false
                subscribeButton.state = "hasSub"
                showInfo(lang.lang_subscribe_success)
            } else {
                subscribeArr.splice(subscribeArr.indexOf(departmentId), 1)
                subscribeButton.checked = true
                subscribeButton.state = "noSub"
                showInfo(lang.lang_cancelled)
            }
        }
    }

    function gridHeight() {
        var h = eventCard.model / 2
        return (h ? h : h + 1) * eventCard.cellHeight
    }

    FluTextButton {
        id: subscribeButton
        visible: UserHelper.permission !== 1
        Layout.alignment: Qt.AlignRight
        checked: true
        state: "noSub"
        opacity: (departmentId > 0) ? 1 : 0
        states: [
            State {
                name: "hasSub"
                PropertyChanges {
                    target: subscribeButton
                    text: lang.lang_unsubscribe
                    textColor: disableColor
                }
            },
            State {
                name: "noSub"
                PropertyChanges {
                    target: subscribeButton
                    text: lang.lang_subscribe
                    textColor: pressedColor
                }
            }
        ]

        onClicked: {
            checked = !checked
            DepartmentEventsController.subscribeDepartment(!checked,
                                                           departmentId)
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 20

        FluArea {
            paddings: 10
            width: 200
            Layout.alignment: Qt.AlignTop
            height: 500
            FluTreeView {
                id: tree_view
                width: 200
                height: 500
                selectionMode: FluTreeViewType.Single
                anchors.fill: parent
                onItemClicked: item => {
                                   if (UserHelper.permission !== 1) {
                                       departmentId = item.data.id
                                       if (subscribeArr.indexOf(
                                               departmentId) !== -1) {
                                           subscribeButton.checked = false
                                           subscribeButton.state = "hasSub"
                                       } else {
                                           subscribeButton.checked = true
                                           subscribeButton.state = "noSub"
                                       }
                                   }
                                   loadDepartmentEvents(item.data.id)
                               }

                Component.onCompleted: {

                }
            }
        }

        GridView {
            id: eventCard
            Layout.topMargin: 10
            Layout.rightMargin: 10
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            implicitHeight: gridHeight()
            cellHeight: 150
            cellWidth: 292
            interactive: false
            delegate: com_item
            model: EventoBriefModel
        }
    }

    Component {
        id: com_item
        Item {
            Layout.topMargin: 10
            width: 280
            height: 135
            FluArea {
                radius: 8
                width: 280
                height: 135
                anchors.centerIn: parent
                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: {
                        if (FluTheme.dark) {
                            if (item_mouse.containsMouse) {
                                return Qt.rgba(1, 1, 1, 0.03)
                            }
                            return Qt.rgba(0, 0, 0, 0)
                        } else {
                            if (item_mouse.containsMouse) {
                                return Qt.rgba(0, 0, 0, 0.03)
                            }
                            return Qt.rgba(0, 0, 0, 0)
                        }
                    }
                }
                FluRectangle {
                    id: item_icon
                    height: 115
                    width: 115
                    radius: [6, 6, 6, 6]
                    shadow: false
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    FluImage {
                        anchors.fill: parent
                        source: model.url
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                FluText {
                    id: item_title
                    text: model.title
                    font: FluTextStyle.Subtitle
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    anchors {
                        left: item_icon.right
                        leftMargin: 12
                        top: item_icon.top
                        right: parent.right
                        rightMargin: 5
                    }
                }

                Row {
                    id: item_time
                    spacing: 5
                    anchors {
                        left: item_title.left
                        right: parent.right
                        rightMargin: 20
                        top: item_title.bottom
                        topMargin: 10
                    }
                    FluIcon {
                        iconSource: FluentIcons.EmojiTabFavorites
                    }
                    FluText {
                        text: model.time
                        color: FluColors.Grey120
                        width: 110
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        font: FluTextStyle.Caption
                        maximumLineCount: 2
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    id: item_location
                    spacing: 5
                    anchors {
                        left: item_title.left
                        right: parent.right
                        rightMargin: 20
                        top: item_time.bottom
                        topMargin: 5
                    }
                    FluIcon {
                        iconSource: FluentIcons.POI
                    }
                    FluText {
                        text: model.location
                        width: 110
                        color: FluColors.Grey120
                        font: FluTextStyle.Caption
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    id: item_department
                    spacing: 5
                    anchors {
                        left: item_title.left
                        right: parent.right
                        rightMargin: 20
                        top: item_location.bottom
                        topMargin: 5
                    }
                    FluIcon {
                        iconSource: FluentIcons.EMI
                    }
                    FluText {
                        text: model.department
                        width: 110
                        color: FluColors.Grey120
                        elide: Text.ElideRight
                        font: FluTextStyle.Caption
                        maximumLineCount: 1
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: item_mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        EventoHelper.id = model.id
                        MainWindow.window.pushPage(
                                    "qrc:/qml/page/T_EventInfo.qml")
                    }
                }
            }
        }
    }
}
