// Component mancool men AdminPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Rectangle {
        id: orderRow
        required property var modelData
        property bool compact: false
        signal statusRequested(string orderId, string status, string label)
        height: 76
        radius: Theme.rInput
        color: rowHover.hovered ? Theme.sky50 : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
        Column {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 220
            spacing: 2
            Controls.PText {
                ts: Theme.labelStrong
                text: "#" + orderRow.modelData.orderId + "  ·  " + orderRow.modelData.customerName
            }
            Controls.PText {
                ts: Theme.meta12
                color: Theme.textSecondary
                text: orderRow.modelData.createdText + "  ·  " + orderRow.modelData.count
                      + (orderRow.modelData.count === 1 ? " item" : " items")
            }
        }
        Controls.PText {
            x: 250
            width: 140
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
            ts: Theme.valueStrong
            text: orderRow.modelData.totalText
        }
        Controls.StatusChip {
            x: 414
            anchors.verticalCenter: parent.verticalCenter
            status: orderRow.modelData.status
            text: orderRow.modelData.statusLabel
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            // Only Order::nextStatusesFor(status): pending -> confirmed / cancelled, … shipped -> delivered
            Repeater {
                model: orderRow.compact ? [] : orderRow.modelData.nextStatuses.map((option) => Object.assign({ owner: orderRow }, option))
                delegate: Controls.PcButton {
                    required property var modelData
                    height: 40
                    horizontalPadding: 16
                    textStyle: Theme.link
                    variant: modelData.value === "cancelled" ? "secondary" : "primary"
                    text: modelData.value === "cancelled" ? "Cancel" : "Mark " + modelData.label.toLowerCase()
                    onClicked: modelData.owner.statusRequested(modelData.owner.modelData.orderId, modelData.value, modelData.label)
                }
            }
            Controls.IconButton {
                iconName: "arrowR"
                iconSize: 16
                onClicked: App.go("orderDetails", { orderId: orderRow.modelData.orderId })
            }
        }
        HoverHandler {
            id: rowHover
        }
    }
