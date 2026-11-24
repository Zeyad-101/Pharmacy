// Component mancool men AccountPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Item {
        id: details
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: detailsColumn.height + 96

        readonly property string orderId: App.pageParams.orderId !== undefined ? App.pageParams.orderId : ""
        property var orderData: App.order(orderId)
        readonly property bool found: orderData.ok === true

        function refresh() {
            orderData = App.order(orderId)
        }
        function cancelOrder() {
            const result = App.cancelMyOrder(orderId)
            App.showToast(result.ok ? "success" : "error", result.ok ? "Order cancelled" : "Could not cancel the order", result.message)
            refresh()
        }
        Connections {
            target: App
            function onDataChanged() {
                details.refresh()
            }
        }

        Column {
            id: detailsColumn
            y: 36
            x: (parent.width - Theme.contentWidth) / 2
            width: Theme.contentWidth
            spacing: 32
            PageHead {
                crumbs: [{ label: "Home", page: "home", params: {} },
                         { label: App.isAdmin ? "Admin orders" : "My orders", page: App.isAdmin ? "admin" : "account",
                           params: App.isAdmin ? { tab: "orders" } : { tab: "orders" } }]
                current: details.found ? "Order #" + details.orderId : "Order"
                title: details.found ? "Order #" + details.orderId : "Order not found"
                subtitle: details.found ? "Placed " + details.orderData.createdText + "  ·  " + details.orderData.count
                                          + (details.orderData.count === 1 ? " item" : " items") : ""
            }
            Controls.EmptyState {
                visible: !details.found
                width: parent.width
                iconName: "bag"
                title: "We could not find this order"
                message: details.orderData.message !== undefined ? details.orderData.message : ""
                actionText: "Back to my orders"
                onAction: App.go("account", { tab: "orders" })
            }
            Row {
                visible: details.found
                spacing: 40
                Column {
                    width: 780
                    spacing: 24
                    Controls.Panel {
                        width: parent.width
                        height: trackColumn.height + 64
                        Column {
                            id: trackColumn
                            x: 32
                            y: 32
                            width: parent.width - 64
                            spacing: 24
                            Item {
                                width: parent.width
                                height: 32
                                Controls.PText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    ts: Theme.h3
                                    text: "Order status"
                                }
                                Controls.StatusChip {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    status: details.found ? details.orderData.status : "pending"
                                    text: details.found ? details.orderData.statusLabel : ""
                                }
                            }
                            StatusTracker {
                                width: parent.width
                                status: details.found ? details.orderData.status : "pending"
                                placedText: details.found ? details.orderData.dateShortText : ""
                            }
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: shipCol.height + 40
                        radius: Theme.rOption
                        color: Theme.surfaceTint
                        Column {
                            id: shipCol
                            x: 20
                            y: 20
                            width: parent.width - 40
                            spacing: 10
                            Row {
                                spacing: 8
                                Controls.Icon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: "pin"
                                    size: 16
                                    color: Theme.royal600
                                }
                                Controls.PText {
                                    ts: Theme.linkBold
                                    text: "Shipping to"
                                }
                            }
                            Controls.PText {
                                width: parent.width
                                ts: Theme.bodyS
                                color: Theme.textBody
                                wrapMode: Text.WordWrap
                                text: details.found ? details.orderData.address.line1 + "\n" + details.orderData.address.line2 : ""
                            }
                        }
                    }
                    // Cancel: only offered while OrderManager allows it (pending, confirmed, processing)
                    Controls.Panel {
                        visible: details.found && !App.isAdmin
                        width: parent.width
                        height: 96
                        Column {
                            x: 28
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 28 - cancelButton.width - 56
                            spacing: 4
                            Controls.PText {
                                ts: Theme.labelStrong
                                text: details.orderData.canCancel === true ? "Need to change something?" : "This order can no longer be cancelled"
                            }
                            Controls.PText {
                                width: parent.width
                                ts: Theme.small13Regular
                                color: Theme.textSecondary
                                elide: Text.ElideRight
                                text: details.orderData.canCancel === true
                                      ? "You can cancel until the order is shipped. The items go back into stock."
                                      : details.orderData.status === "cancelled" ? "It has already been cancelled."
                                      : "It has already been shipped."
                            }
                        }
                        Controls.PcButton {
                            id: cancelButton
                            anchors.right: parent.right
                            anchors.rightMargin: 28
                            anchors.verticalCenter: parent.verticalCenter
                            variant: "secondary"
                            text: "Cancel order"
                            iconName: "x"
                            iconFirst: true
                            enabled: details.orderData.canCancel === true
                            onClicked: cancelDialog.open()
                        }
                    }
                }
                Controls.ShadowRect {
                    width: 460
                    height: summaryColumn.height + 56
                    radius: Theme.rModal
                    color: Theme.white
                    border.width: Theme.borderThin
                    border.color: Theme.borderHairline
                    elevation: "sm"
                    Column {
                        id: summaryColumn
                        x: 28
                        y: 28
                        width: parent.width - 56
                        spacing: 16
                        Controls.PText {
                            ts: Theme.h4
                            text: "Order summary"
                        }
                        Repeater {
                            model: details.found ? details.orderData.items : []
                            delegate: Item {
                                id: itemRow
                                required property var modelData
                                width: parent ? parent.width : 0
                                height: 56
                                Controls.RoundedImage {
                                    width: 56
                                    height: 56
                                    radius: Theme.rInput
                                    source: itemRow.modelData.image
                                }
                                Column {
                                    x: 70
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 70 - 110
                                    spacing: 2
                                    Controls.PText {
                                        width: parent.width
                                        ts: Theme.labelStrong
                                        elide: Text.ElideRight
                                        text: itemRow.modelData.name
                                    }
                                    Controls.PText {
                                        ts: Theme.meta12
                                        color: Theme.textSecondary
                                        text: "Qty " + itemRow.modelData.quantity + " · " + itemRow.modelData.unitPriceText + " each"
                                    }
                                }
                                Controls.PText {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    ts: Theme.valueStrong
                                    text: itemRow.modelData.lineTotalText
                                }
                            }
                        }
                        Controls.Divider {
                            width: parent.width
                        }
                        Controls.SummaryRow {
                            width: parent.width
                            compact: true
                            label: "Subtotal"
                            value: details.found ? details.orderData.subtotalText : ""
                        }
                        Controls.SummaryRow {
                            visible: details.found && details.orderData.hasDiscount
                            width: parent.width
                            compact: true
                            label: "Discount · " + (details.found ? details.orderData.promoCode : "")
                            value: details.found ? details.orderData.discountText : ""
                            valueColor: Theme.royal600
                        }
                        Controls.Divider {
                            width: parent.width
                        }
                        Item {
                            width: parent.width
                            height: 36
                            Controls.PText {
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.totalLabel
                                text: "Total"
                            }
                            Controls.PText {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.totalPrice
                                text: details.found ? details.orderData.totalText : ""
                            }
                        }
                    }
                }
            }
        }

        Controls.ConfirmDialog {
            id: cancelDialog
            title: "Cancel order #" + details.orderId + "?"
            message: "The order will be cancelled and the items go back into stock. This cannot be undone."
            confirmText: "Cancel order"
            cancelText: "Keep order"
            onConfirmed: details.cancelOrder()
        }
    }
