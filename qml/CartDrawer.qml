// Component mancool men CheckoutPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Item {
        id: drawer
        property bool justAdded: false
        property var cart: App.cartItems()
        signal closeRequested()

        function refresh() {
            cart = App.cartItems()
        }
        function changeQuantity(productId: string, quantity: int) {
            const result = App.changeCartQuantity(productId, quantity)
            if (!result.ok)
                App.showToast("error", "Could not update the quantity", result.message)
        }

        readonly property var lineModel: cart.items.map((item) => Object.assign({ owner: drawer }, item))

        Connections {
            target: App
            function onCartChanged() {
                drawer.refresh()
            }
        }

        // Panel: white, radius 24 on the top-left corner only, lg shadow
        Controls.ShadowRect {
            anchors.fill: parent
            radius: Theme.rSidebar
            color: Theme.white
            elevation: "lg"
        }
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            width: Theme.rSidebar
            height: Theme.rSidebar
            color: Theme.white
        }
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: Theme.rSidebar
            color: Theme.surfaceTint
        }

        // Head
        Item {
            id: drawerHead
            width: parent.width
            height: 88
            Row {
                x: 28
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Controls.PText {
                    ts: Theme.drawerTitle
                    text: "Your bag"
                }
                Controls.PText {
                    anchors.bottom: parent.bottom
                    ts: Theme.body
                    color: Theme.textSecondary
                    text: drawer.cart.count + (drawer.cart.count === 1 ? " item" : " items")
                }
            }
            Controls.IconButton {
                anchors.right: parent.right
                anchors.rightMargin: 28
                anchors.verticalCenter: parent.verticalCenter
                iconName: "x"
                onClicked: drawer.closeRequested()
            }
        }

        // "Item added" banner
        Rectangle {
            id: addedBanner
            anchors.top: drawerHead.bottom
            width: parent.width
            height: drawer.justAdded ? 41 : 0
            visible: drawer.justAdded
            color: Theme.successBg
            Row {
                x: 28
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Controls.Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "check"
                    size: 16
                    color: Theme.success
                }
                Controls.PText {
                    anchors.verticalCenter: parent.verticalCenter
                    ts: Theme.linkBold
                    color: Theme.success
                    text: "Item added to your bag"
                }
            }
        }

        // Items
        ListView {
            id: itemList
            anchors.top: addedBanner.bottom
            anchors.bottom: drawerFooter.top
            x: 28
            width: parent.width - 56
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            visible: !drawer.cart.empty
            model: drawer.lineModel
            delegate: Item {
                id: row
                required property var modelData
                width: ListView.view.width
                height: 104
                Controls.RoundedImage {
                    id: rowThumb
                    y: 16
                    width: 72
                    height: 72
                    radius: Theme.rThumb
                    source: row.modelData.image
                }
                Column {
                    anchors.left: rowThumb.right
                    anchors.leftMargin: 14
                    anchors.right: rowPrice.left
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Controls.PText {
                        width: parent.width
                        ts: Theme.link
                        elide: Text.ElideRight
                        text: row.modelData.name
                    }
                    Controls.PText {
                        ts: Theme.meta12
                        color: Theme.textSecondary
                        text: row.modelData.requiresPrescription ? "Prescription required" : row.modelData.unitPriceText + " each"
                    }
                    // Mini quantity pill (25 px)
                    Rectangle {
                        width: miniRow.implicitWidth + 20
                        height: 25
                        radius: height / 2
                        color: Theme.white
                        border.width: Theme.borderThin
                        border.color: Theme.borderControl
                        Row {
                            id: miniRow
                            anchors.centerIn: parent
                            spacing: 10
                            Controls.Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "minus"
                                size: 12
                                color: Theme.midnight700
                                opacity: row.modelData.quantity > 1 ? 1.0 : 0.35
                                TapHandler {
                                    enabled: row.modelData.quantity > 1
                                    onTapped: row.modelData.owner.changeQuantity(row.modelData.id, row.modelData.quantity - 1)
                                }
                                HoverHandler {
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                            Controls.PText {
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.countBadge
                                color: Theme.textPrimary
                                text: row.modelData.quantity
                            }
                            Controls.Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "plus"
                                size: 12
                                color: Theme.midnight700
                                opacity: row.modelData.quantity < row.modelData.maxQuantity ? 1.0 : 0.35
                                TapHandler {
                                    enabled: row.modelData.quantity < row.modelData.maxQuantity
                                    onTapped: row.modelData.owner.changeQuantity(row.modelData.id, row.modelData.quantity + 1)
                                }
                                HoverHandler {
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }
                }
                Controls.PText {
                    id: rowPrice
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    ts: Theme.linkBold
                    text: row.modelData.lineTotalText
                }
                Controls.Divider {
                    anchors.bottom: parent.bottom
                    width: parent.width
                }
            }
        }

        // Empty bag
        Column {
            visible: drawer.cart.empty
            anchors.top: addedBanner.bottom
            anchors.topMargin: 48
            x: 28
            width: parent.width - 56
            spacing: 12
            Controls.PText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                ts: Theme.cardTitle
                text: "Your bag is empty"
            }
            Controls.PText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                ts: Theme.bodyS
                color: Theme.textSecondary
                wrapMode: Text.WordWrap
                text: "Browse the shop and add products to see them here."
            }
        }

        // Footer
        Rectangle {
            id: drawerFooter
            anchors.bottom: parent.bottom
            width: parent.width
            height: footerColumn.height + 48
            color: Theme.surfaceTint
            Column {
                id: footerColumn
                x: 28
                y: 20
                width: parent.width - 56
                spacing: 14
                Item {
                    visible: !drawer.cart.empty
                    width: parent.width
                    height: 25
                    Controls.PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.cardLine
                        text: "Subtotal"
                    }
                    Controls.PText {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.subtotal
                        text: drawer.cart.subtotalText
                    }
                }
                Controls.PText {
                    visible: !drawer.cart.empty
                    ts: Theme.meta12
                    color: Theme.textSecondary
                    text: "Promo codes are applied at checkout"
                }
                Controls.PcButton {
                    visible: !drawer.cart.empty
                    width: parent.width
                    text: "Checkout"
                    iconName: "lock"
                    iconFirst: true
                    iconSize: 16
                    onClicked: {
                        drawer.closeRequested()
                        App.goToCheckout()
                    }
                }
                Controls.PcButton {
                    width: parent.width
                    variant: "secondary"
                    text: drawer.cart.empty ? "Continue shopping" : "View bag"
                    onClicked: {
                        drawer.closeRequested()
                        if (!drawer.cart.empty)
                            App.go("cart")
                    }
                }
            }
        }
    }
