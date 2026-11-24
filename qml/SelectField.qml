// Component mancool men Controls.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Controls.Basic as Basic

Column {
        id: selectField
        property string label: ""
        property string value: ""
        property string placeholder: "Choose…"
        property var options: []
        property string status: ""
        property string helper: ""
        signal picked(string value)
        function choose(option: string) {
            selectMenu.close()
            picked(option)
        }
        width: 360
        spacing: 8
        Controls.PText {
            visible: selectField.label !== ""
            ts: Theme.link
            color: Theme.textLabel
            text: selectField.label
        }
        Rectangle {
            id: selectTrigger
            width: parent.width
            height: 52
            radius: Theme.rInput
            color: Theme.white
            border.width: selectMenu.opened || selectTrigger.activeFocus ? Theme.borderFocus : Theme.borderThin
            border.color: selectField.status === "error" ? Theme.error
                        : selectMenu.opened || selectTrigger.activeFocus ? Theme.royal600 : Theme.borderControl
            activeFocusOnTab: true
            Keys.onReturnPressed: selectMenu.open()
            Keys.onSpacePressed: selectMenu.open()
            Controls.PText {
                x: 16
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 56
                ts: Theme.body
                elide: Text.ElideRight
                color: selectField.value === "" ? Theme.textMuted : Theme.textPrimary
                text: selectField.value === "" ? selectField.placeholder : selectField.value
            }
            Controls.Icon {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                name: selectMenu.opened ? "chevU" : "chevD"
                size: 18
                color: Theme.textSecondary
            }
            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
            MouseArea {
                anchors.fill: parent
                onClicked: selectMenu.opened ? selectMenu.close() : selectMenu.open()
            }
            Basic.Popup {
                id: selectMenu
                y: selectTrigger.height + 6
                width: selectTrigger.width
                padding: 8
                closePolicy: Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutsideParent
                background: Controls.ShadowRect {
                    radius: Theme.rMenu
                    color: Theme.white
                    border.width: Theme.borderThin
                    border.color: Theme.borderHairline
                    elevation: "md"
                }
                contentItem: Column {
                    width: selectTrigger.width - 16
                    spacing: 2
                    Repeater {
                        // each option carries its field ("owner"), so the delegate needs no outer ids
                        model: selectField.options.map((option) => ({ text: option, owner: selectField }))
                        delegate: Controls.MenuOption {
                            required property var modelData
                            width: parent ? parent.width : 0
                            text: modelData.text
                            selected: modelData.text === modelData.owner.value
                            onClicked: modelData.owner.choose(modelData.text)
                        }
                    }
                }
            }
        }
        Controls.PText {
            visible: selectField.helper !== ""
            ts: Theme.caption
            color: selectField.status === "error" ? Theme.error : Theme.textSecondary
            text: selectField.helper
        }
    }
