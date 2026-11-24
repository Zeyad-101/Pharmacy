// Component mancool men CheckoutPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Item {
        id: cartPage
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: cartColumn.height

        property var cart: App.cartItems()
        property var totals: App.cartTotals()
        // Item table columns (780 wide): info | quantity 112 | total 156 | remove 40
        readonly property int columnGap: 24
        readonly property int totalColumnWidth: 156
        readonly property int totalColumnX: 780 - 40 - 20 - totalColumnWidth
        readonly property int qtyColumnWidth: 112
        readonly property int qtyColumnX: totalColumnX - columnGap - qtyColumnWidth
        property string noticeText: ""
        property string noticeAction: ""
        property string undoProductId: ""
        property int undoQuantity: 0

        function refresh() {
            cart = App.cartItems()
            totals = App.cartTotals()
        }
        function changeQuantity(productId: string, quantity: int) {
            const result = App.changeCartQuantity(productId, quantity)
            if (result.ok) {
                noticeText = result.message
                noticeAction = "Dismiss"
                undoProductId = ""
            } else {
                App.showToast("error", "Could not update the quantity", result.message)
            }
        }
        function remove(productId: string) {
            const result = App.removeFromCart(productId)
            if (result.ok) {
                noticeText = result.message
                noticeAction = "Undo"
                undoProductId = productId
                undoQuantity = result.quantity
            } else {
                App.showToast("error", "Could not remove the item", result.message)
            }
        }
        function noticeClicked() {
            if (noticeAction === "Undo" && undoProductId !== "") {
                const result = App.addToCart(undoProductId, undoQuantity)
                if (!result.ok)
                    App.showToast("error", "Could not undo", result.message)
            }
            noticeText = ""
            undoProductId = ""
        }
        function applyPromo(code: string) {
            const result = App.applyPromo(code)
            if (!result.ok)
                App.showToast("error", "Promo code not valid", result.message)
        }

        Connections {
            target: App
            function onCartChanged() {
                cartPage.refresh()
            }
        }

        // Delegate model: each line plus "owner" for its actions
        readonly property var lineModel: cart.items.map((item) => Object.assign({ owner: cartPage }, item))

        Column {
            id: cartColumn
            width: parent.width

            // ---------- Page head ----------
            Item {
                width: parent.width
                height: 36 + 17 + 16 + 66 + 32
                Column {
                    y: 36
                    x: (parent.width - Theme.contentWidth) / 2
                    width: Theme.contentWidth
                    spacing: 16
                    Breadcrumb {
                        crumbs: [{ label: "Home", page: "home", params: {} }, { label: "Shop", page: "shop", params: {} }]
                        current: "Shopping bag"
                    }
                    Item {
                        width: parent.width
                        height: 66
                        Row {
                            anchors.bottom: parent.bottom
                            spacing: 14
                            Controls.PText {
                                ts: Theme.pageTitle
                                text: "Your bag"
                            }
                            Controls.PText {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 8
                                ts: Theme.bodyL
                                color: Theme.textSecondary
                                text: cartPage.totals.count + (cartPage.totals.count === 1 ? " item" : " items")
                            }
                        }
                    }
                }
            }

            // ---------- Empty bag ----------
            Item {
                visible: cartPage.cart.empty
                width: parent.width
                height: visible ? emptyBag.height + 80 : 0
                Controls.EmptyState {
                    id: emptyBag
                    width: Theme.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    iconName: "bag"
                    title: "Your bag is empty"
                    message: "Browse the shop and add the medicines, skincare and supplements you need."
                    actionText: "Continue shopping"
                    onAction: App.go("shop")
                }
            }

            // ---------- Items + order summary ----------
            Item {
                visible: !cartPage.cart.empty
                width: parent.width
                height: visible ? Math.max(itemsColumn.height, summary.height) + 80 : 0
                Row {
                    x: (parent.width - Theme.contentWidth) / 2
                    spacing: 60
                    Column {
                        id: itemsColumn
                        width: 780
                        Item {
                            width: parent.width
                            height: 31
                            Controls.PText {
                                ts: Theme.brandLine
                                color: Theme.textMuted
                                text: "Product"
                            }
                            // Centred over the stepper column / right-aligned over the total column
                            Controls.PText {
                                x: cartPage.qtyColumnX + (cartPage.qtyColumnWidth - width) / 2
                                ts: Theme.brandLine
                                color: Theme.textMuted
                                text: "Quantity"
                            }
                            Controls.PText {
                                x: cartPage.totalColumnX + cartPage.totalColumnWidth - width
                                ts: Theme.brandLine
                                color: Theme.textMuted
                                text: "Total"
                            }
                        }
                        Controls.Divider {
                            width: parent.width
                        }
                        Repeater {
                            model: cartPage.lineModel
                            delegate: Column {
                                id: line
                                required property var modelData
                                width: 780
                                Item {
                                    width: parent.width
                                    height: 144
                                    Controls.RoundedImage {
                                        id: lineThumb
                                        y: 20
                                        width: 104
                                        height: 104
                                        radius: Theme.rOption
                                        source: line.modelData.image
                                    }
                                    Column {
                                        x: 124
                                        width: line.modelData.owner.qtyColumnX - line.modelData.owner.columnGap - x
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 6
                                        Controls.PText {
                                            visible: text !== ""
                                            ts: Theme.brandLine
                                            color: Theme.textSecondary
                                            text: line.modelData.brand
                                        }
                                        Controls.PText {
                                            width: parent.width
                                            ts: Theme.cardLine
                                            elide: Text.ElideRight
                                            text: line.modelData.name
                                        }
                                        Controls.PText {
                                            ts: Theme.caption
                                            color: line.modelData.inStock ? Theme.success : Theme.error
                                            text: (line.modelData.inStock ? "In stock" : "Out of stock")
                                                  + (line.modelData.requiresPrescription ? "  ·  Prescription required" : "")
                                        }
                                        Controls.PText {
                                            ts: Theme.meta12
                                            color: Theme.textSecondary
                                            text: line.modelData.unitPriceText + " each"
                                        }
                                    }
                                    Controls.QuantitySelector {
                                        x: line.modelData.owner.qtyColumnX
                                        anchors.verticalCenter: parent.verticalCenter
                                        large: false
                                        value: line.modelData.quantity
                                        maximum: line.modelData.maxQuantity
                                        onStepped: (newValue) => line.modelData.owner.changeQuantity(line.modelData.id, newValue)
                                    }
                                    // Fixed column: long amounts never reach the stepper (very long ones shrink to fit)
                                    Controls.PText {
                                        x: line.modelData.owner.totalColumnX
                                        width: line.modelData.owner.totalColumnWidth
                                        anchors.verticalCenter: parent.verticalCenter
                                        ts: Theme.price
                                        horizontalAlignment: Text.AlignRight
                                        fontSizeMode: Text.HorizontalFit
                                        minimumPixelSize: Theme.caption.size
                                        text: line.modelData.lineTotalText
                                    }
                                    Controls.IconButton {
                                        id: removeButton
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        iconName: "trash"
                                        iconColor: Theme.textSecondary
                                        onClicked: line.modelData.owner.remove(line.modelData.id)
                                    }
                                }
                                Controls.Divider {
                                    width: parent.width
                                }
                            }
                        }
                        Item {
                            width: parent.width
                            height: 41
                            Controls.TextLink {
                                y: 24
                                iconName: "arrowL"
                                spacing: 8
                                color: Theme.textPrimary
                                text: "Continue shopping"
                                onClicked: App.go("shop")
                            }
                        }
                        Item {
                            visible: cartPage.noticeText !== ""
                            width: parent.width
                            height: visible ? 20 + 46 : 0
                            Controls.InlineNotice {
                                y: 20
                                width: parent.width
                                text: cartPage.noticeText
                                actionText: cartPage.noticeAction
                                onAction: cartPage.noticeClicked()
                            }
                        }
                    }

                    // Order summary
                    Controls.ShadowRect {
                        id: summary
                        width: 440
                        height: summaryColumn.height + 64
                        radius: Theme.rModal
                        color: Theme.white
                        border.width: Theme.borderThin
                        border.color: Theme.borderHairline
                        elevation: "md"
                        Column {
                            id: summaryColumn
                            x: 32
                            y: 32
                            width: parent.width - 64
                            spacing: 18
                            Controls.PText {
                                ts: Theme.h3
                                text: "Order summary"
                            }
                            Controls.SummaryRow {
                                label: "Subtotal (" + cartPage.totals.count + (cartPage.totals.count === 1 ? " item)" : " items)")
                                value: cartPage.totals.subtotalText
                            }
                            Controls.SummaryRow {
                                label: cartPage.totals.hasDiscount ? "Discount · " + cartPage.totals.promoCode : "Discount"
                                value: cartPage.totals.hasDiscount ? cartPage.totals.discountText : "—"
                                valueColor: cartPage.totals.hasDiscount ? Theme.royal600 : Theme.textMuted
                            }
                            Controls.PromoField {
                                width: parent.width
                                appliedCode: cartPage.totals.promoCode
                                successText: cartPage.totals.hasDiscount
                                             ? "Code applied — you saved " + cartPage.totals.percentage + "% on this order" : ""
                                onApplyRequested: (code) => cartPage.applyPromo(code)
                                onRemoveRequested: App.clearPromo()
                            }
                            Controls.Divider {
                                width: parent.width
                            }
                            Item {
                                width: parent.width
                                height: 32
                                Controls.PText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    ts: Theme.totalLabel
                                    text: "Total"
                                }
                                Controls.PText {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    ts: Theme.totalPrice
                                    text: cartPage.totals.totalText
                                }
                            }
                            Controls.PcButton {
                                width: parent.width
                                height: 56
                                text: "Proceed to Checkout"
                                iconName: "lock"
                                iconFirst: true
                                onClicked: App.goToCheckout()
                            }
                        }
                    }
                }
            }
        }
    }
