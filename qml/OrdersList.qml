// Component mancool men AccountPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Column {
        id: ordersList
        property var orders: []
        width: parent ? parent.width : 952
        spacing: 16

        Controls.EmptyState {
            visible: ordersList.orders.length === 0
            width: parent.width
            iconName: "bag"
            title: App.isAdmin ? "Admins do not place orders" : "No orders yet"
            message: App.isAdmin ? "Customer orders are in the admin area." : "When you place an order it appears here, with its status from placed to delivered."
            actionText: App.isAdmin ? "Open admin orders" : "Start shopping"
            onAction: App.isAdmin ? App.go("admin", { tab: "orders" }) : App.go("shop")
        }
        Repeater {
            model: ordersList.orders
            delegate: Rectangle {
                id: orderRow
                required property var modelData
                width: parent ? parent.width : 0
                height: 112
                radius: Theme.rPanel
                color: rowHover.hovered ? Theme.sky50 : Theme.white
                border.width: Theme.borderThin
                border.color: rowHover.hovered ? Theme.sky200 : Theme.borderHairline
                Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
                // Up to three product thumbnails, overlapping
                Item {
                    x: 24
                    anchors.verticalCenter: parent.verticalCenter
                    width: 64 + 28 * 2
                    height: 64
                    Repeater {
                        model: orderRow.modelData.images
                        delegate: Rectangle {
                            id: thumbFrame
                            required property string modelData
                            required property int index
                            x: index * 28
                            width: 64
                            height: 64
                            radius: Theme.rInput
                            color: Theme.white
                            border.width: 2
                            border.color: Theme.white
                            Controls.RoundedImage {
                                anchors.fill: parent
                                anchors.margins: 2
                                radius: Theme.rInput - 2
                                source: thumbFrame.modelData
                            }
                        }
                    }
                }
                Column {
                    x: 24 + 120 + 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Row {
                        spacing: 12
                        Controls.PText {
                            anchors.verticalCenter: parent.verticalCenter
                            ts: Theme.cardLine
                            text: "Order #" + orderRow.modelData.orderId
                        }
                        Controls.StatusChip {
                            anchors.verticalCenter: parent.verticalCenter
                            status: orderRow.modelData.status
                            text: orderRow.modelData.statusLabel
                        }
                    }
                    Controls.PText {
                        ts: Theme.small13Regular
                        color: Theme.textSecondary
                        text: orderRow.modelData.createdText + "  ·  " + orderRow.modelData.count
                              + (orderRow.modelData.count === 1 ? " item" : " items")
                    }
                }
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 24
                    Controls.PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.price
                        text: orderRow.modelData.totalText
                    }
                    Controls.TextLink {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "View details"
                        iconName: "arrowR"
                        iconAfter: true
                        onClicked: App.go("orderDetails", { orderId: orderRow.modelData.orderId })
                    }
                }
                HoverHandler {
                    id: rowHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: App.go("orderDetails", { orderId: orderRow.modelData.orderId })
                }
            }
        }
    }
