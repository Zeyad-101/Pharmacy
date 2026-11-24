// Component mancool men CheckoutPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Item {
        id: confirmation
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: confirmColumn.height

        readonly property string orderId: App.pageParams.orderId !== undefined ? App.pageParams.orderId : ""
        readonly property var orderData: App.order(orderId)
        readonly property bool found: orderData.ok === true

        Column {
            id: confirmColumn
            width: parent.width

            Controls.EmptyState {
                visible: !confirmation.found
                width: Theme.contentWidth
                anchors.horizontalCenter: parent.horizontalCenter
                iconName: "info"
                title: "Order not found"
                message: "We could not find this order."
                actionText: "Back to shop"
                onAction: App.go("shop")
            }

            // ---------- Success hero ----------
            Item {
                visible: confirmation.found
                width: parent.width
                height: visible ? heroColumn.height + 72 + 56 : 0
                clip: true
                Controls.GradientFill {
                    anchors.fill: parent
                    direction: "vertical"
                    colors: Theme.gradSkyAir
                }
                Controls.Glow {
                    x: parent.width / 2 - 300
                    y: -120
                    width: 600
                    height: 400
                    color: Theme.alpha(Theme.azure300, 0.5)
                    blurRadius: 140
                }
                Column {
                    id: heroColumn
                    y: 72
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 132
                        height: 132
                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: Theme.alpha(Theme.royal500, 0.1)
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: 108
                            height: 108
                            radius: height / 2
                            color: Theme.alpha(Theme.royal500, 0.2)
                        }
                        Controls.ShadowRect {
                            anchors.centerIn: parent
                            width: 84
                            height: 84
                            radius: height / 2
                            color: Theme.royal600
                            elevation: "glow"
                        }
                        Controls.GradientFill {
                            anchors.centerIn: parent
                            width: 84
                            height: 84
                            radius: 42
                            direction: "diagonal"
                            colors: Theme.gradRoyalGlow
                        }
                        Controls.Icon {
                            anchors.centerIn: parent
                            name: "check"
                            size: 36
                            color: Theme.white
                        }
                    }
                    Controls.PText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        ts: Theme.overline
                        color: Theme.success
                        text: "Order confirmed"
                    }
                    Controls.PText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        ts: Theme.successTitle
                        horizontalAlignment: Text.AlignHCenter
                        text: App.currentUserName !== "" && !(confirmation.found && confirmation.orderData.isGuest)
                              ? "Thank you, " + App.currentUserName + "." : "Thank you."
                    }
                    Controls.PText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 620
                        ts: Theme.bodyL
                        color: Theme.textBody
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: "Your order has been received and is now with our pharmacists for final checks."
                    }
                    // Order meta bar
                    Controls.ShadowRect {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: metaRow.implicitWidth
                        height: 80
                        radius: Theme.rPanel
                        color: Theme.white
                        border.width: Theme.borderThin
                        border.color: Theme.borderHairline
                        elevation: "sm"
                        Row {
                            id: metaRow
                            Repeater {
                                model: confirmation.found ? [
                                    { label: "Order number", value: "#" + confirmation.orderData.orderId },
                                    { label: "Order date", value: confirmation.orderData.createdText },
                                    { label: "Status", value: confirmation.orderData.statusLabel },
                                    { label: "Total", value: confirmation.orderData.totalText }
                                ] : []
                                delegate: Row {
                                    id: metaCell
                                    required property var modelData
                                    required property int index
                                    Rectangle {
                                        visible: metaCell.index > 0
                                        y: 20
                                        width: 1
                                        height: 40
                                        color: Theme.borderHairline
                                    }
                                    Column {
                                        topPadding: 18
                                        leftPadding: 28
                                        rightPadding: 28
                                        spacing: 4
                                        Controls.PText {
                                            ts: Theme.caption
                                            color: Theme.textSecondary
                                            text: metaCell.modelData.label
                                        }
                                        Controls.PText {
                                            ts: Theme.cardLine
                                            text: metaCell.modelData.value
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12
                        // Design "Track Order": opens this order in My orders (live status from the backend); not for guests
                        Controls.PcButton {
                            visible: !(confirmation.found && confirmation.orderData.isGuest)
                            text: "Track Order"
                            iconName: "arrowR"
                            onClicked: App.go("orderDetails", { orderId: confirmation.orderData.orderId })
                        }
                        Controls.PcButton {
                            variant: "secondary"
                            text: "Continue Shopping"
                            onClicked: App.go("home")
                        }
                    }
                    // Guest checkout: no My orders for guests; an account can be created now (the phone comes along)
                    Row {
                        visible: confirmation.found && confirmation.orderData.isGuest === true
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6
                        Controls.PText {
                            ts: Theme.small13
                            color: Theme.textBody
                            text: "Want to follow your next orders?"
                        }
                        Controls.TextLink {
                            textStyle: Theme.linkBold
                            text: "Create an account"
                            onClicked: App.go("register", { phone: confirmation.orderData.guestPhone })
                        }
                    }
                }
            }

            // ---------- Body: status + delivery | order summary ----------
            Item {
                visible: confirmation.found
                width: parent.width
                height: visible ? 24 + Math.max(leftColumn.height, orderSummary.height) + 96 : 0
                Row {
                    y: 24
                    x: (parent.width - Theme.contentWidth) / 2
                    spacing: 40
                    Column {
                        id: leftColumn
                        width: 780
                        spacing: 24
                        Rectangle {
                            width: parent.width
                            height: trackerColumn.height + 64
                            radius: Theme.rModal
                            color: Theme.white
                            border.width: Theme.borderThin
                            border.color: Theme.borderHairline
                            Column {
                                id: trackerColumn
                                x: 32
                                y: 32
                                width: parent.width - 64
                                spacing: 24
                                Controls.PText {
                                    ts: Theme.h3
                                    text: "Order status"
                                }
                                StatusTracker {
                                    width: parent.width
                                    status: confirmation.found ? confirmation.orderData.status : "pending"
                                    placedText: confirmation.found ? confirmation.orderData.createdText : ""
                                }
                            }
                        }
                        Rectangle {
                            width: 382
                            height: shipColumn.height + 40
                            radius: Theme.rOption
                            color: Theme.surfaceTint
                            Column {
                                id: shipColumn
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
                                    text: confirmation.found
                                          ? confirmation.orderData.address.line1 + "\n" + confirmation.orderData.address.line2 : ""
                                }
                            }
                        }
                    }
                    Controls.ShadowRect {
                        id: orderSummary
                        width: 460
                        height: orderColumn.height + 56
                        radius: Theme.rModal
                        color: Theme.white
                        border.width: Theme.borderThin
                        border.color: Theme.borderHairline
                        elevation: "sm"
                        Column {
                            id: orderColumn
                            x: 28
                            y: 28
                            width: parent.width - 56
                            spacing: 16
                            Controls.PText {
                                ts: Theme.h4
                                text: "Order summary"
                            }
                            Repeater {
                                model: confirmation.found ? confirmation.orderData.items : []
                                delegate: Item {
                                    id: orderLine
                                    required property var modelData
                                    width: parent ? parent.width : 0
                                    height: 56
                                    Controls.RoundedImage {
                                        id: orderThumb
                                        width: 56
                                        height: 56
                                        radius: Theme.rThumb
                                        source: orderLine.modelData.image
                                    }
                                    Column {
                                        anchors.left: orderThumb.right
                                        anchors.leftMargin: 14
                                        anchors.right: orderPrice.left
                                        anchors.rightMargin: 14
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        Controls.PText {
                                            width: parent.width
                                            ts: Theme.link
                                            elide: Text.ElideRight
                                            text: orderLine.modelData.name
                                        }
                                        Controls.PText {
                                            ts: Theme.meta12
                                            color: Theme.textSecondary
                                            text: "Qty " + orderLine.modelData.quantity + " · " + orderLine.modelData.unitPriceText + " each"
                                        }
                                    }
                                    Controls.PText {
                                        id: orderPrice
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        ts: Theme.linkBold
                                        text: orderLine.modelData.lineTotalText
                                    }
                                }
                            }
                            Controls.Divider {
                                width: parent.width
                            }
                            Controls.SummaryRow {
                                compact: true
                                label: "Subtotal"
                                value: confirmation.found ? confirmation.orderData.subtotalText : ""
                            }
                            Controls.SummaryRow {
                                visible: confirmation.found && confirmation.orderData.hasDiscount
                                compact: true
                                label: "Discount · " + (confirmation.found ? confirmation.orderData.promoCode : "")
                                value: confirmation.found ? confirmation.orderData.discountText : ""
                                valueColor: Theme.royal600
                            }
                            Item {
                                width: parent.width
                                height: 32
                                Controls.PText {
                                    anchors.bottom: parent.bottom
                                    ts: Theme.h4
                                    text: "Total"
                                }
                                Controls.PText {
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    ts: Theme.totalPrice
                                    text: confirmation.found ? confirmation.orderData.totalText : ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }
