// Component mancool le file lewa7do 3ashan ne-kasar el cyclic dependency (QML maby2balsh file ye3temed 3ala file beye3temed 3aleh).
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Dialogs

Rectangle {
        id: stockRow
        required property var modelData
        property string messageText: ""
        height: 72
        radius: Theme.rInput
        color: stockHover.hovered ? Theme.sky50 : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }

        function add() {
            const result = App.increaseStock(stockRow.modelData.id, qtyField.text)
            if (result.ok) {
                App.showToast("success", "Stock updated", result.message)
                qtyField.text = ""
            } else {
                messageText = result.message
            }
        }

        Controls.RoundedImage {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: 48
            radius: Theme.rInput
            source: stockRow.modelData.image
        }
        Column {
            x: 72
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Controls.PText {
                ts: Theme.labelStrong
                text: stockRow.modelData.name
            }
            Controls.PText {
                ts: Theme.meta12
                color: stockRow.messageText !== "" ? Theme.error : Theme.textSecondary
                text: stockRow.messageText !== "" ? stockRow.messageText : stockRow.modelData.id + "  ·  " + stockRow.modelData.code
            }
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: stockLabel.implicitWidth + 24
                height: 28
                radius: height / 2
                color: stockRow.modelData.stock === 0 ? Theme.errorBg : Theme.sky100
                Controls.PText {
                    id: stockLabel
                    anchors.centerIn: parent
                    ts: Theme.chip
                    color: stockRow.modelData.stock === 0 ? Theme.error : Theme.royal700
                    text: stockRow.modelData.stock + " in stock"
                }
            }
            Controls.FormInput {
                id: qtyField
                width: 110
                placeholder: "Qty"
                maximumLength: 6
                status: stockRow.messageText !== "" ? "error" : ""
                onTextChanged: stockRow.messageText = ""
                onAccepted: stockRow.add()
            }
            Controls.PcButton {
                anchors.verticalCenter: parent.verticalCenter
                height: 44
                horizontalPadding: 18
                textStyle: Theme.link
                text: "Add stock"
                iconName: "plus"
                iconFirst: true
                onClicked: stockRow.add()
            }
        }
        HoverHandler {
            id: stockHover
        }
    }
