// Component mancool men ShopPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Item {
        id: page
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: pageColumn.height

        readonly property string productId: App.pageParams.id !== undefined ? App.pageParams.id : ""
        readonly property var product: App.product(productId)
        readonly property bool found: product.ok === true
        readonly property bool rx: found && product.requiresPrescription === true
        readonly property var related: App.relatedProducts(productId, 4)
        readonly property var recent: App.recentlyViewed(productId, 4)
        property int quantity: 1
        onProductIdChanged: quantity = 1

        readonly property string availabilityText: !found ? ""
            : product.expired === true ? "Expired · not available to order"
            : product.inStock !== true ? "Out of stock"
            : rx ? "In stock · Dispatched after prescription check"
            : product.lowStock === true ? "Only " + product.stock + " left in stock"
            : "In stock"

        Column {
            id: pageColumn
            width: parent.width

            Controls.EmptyState {
                visible: !page.found
                width: Theme.contentWidth
                anchors.horizontalCenter: parent.horizontalCenter
                iconName: "info"
                title: "Product not found"
                message: "This product is no longer in the catalogue."
                actionText: "Back to shop"
                onAction: App.go("shop")
            }

            // ---------- Breadcrumb row ----------
            Item {
                visible: page.found
                width: parent.width
                height: 28 + 17 + 24
                Item {
                    y: 28
                    width: Theme.contentWidth
                    height: 17
                    anchors.horizontalCenter: parent.horizontalCenter
                    Breadcrumb {
                        crumbs: [
                            { label: "Home", page: "home", params: {} },
                            { label: page.found ? page.product.category : "", page: "shop", params: { category: page.found ? page.product.category : "" } }
                        ]
                        current: page.found ? page.product.name : ""
                    }
                    Controls.TextLink {
                        anchors.right: parent.right
                        iconName: "arrowL"
                        color: Theme.midnight600
                        text: "Back to results"
                        onClicked: App.back()
                    }
                }
            }

            // ---------- Main: image + info ----------
            Item {
                visible: page.found
                width: parent.width
                height: Math.max(640, info.height)
                Row {
                    width: Theme.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 64
                    Item {
                        width: 640
                        height: 640
                        Controls.RoundedImage {
                            anchors.fill: parent
                            radius: Theme.rBanner
                            source: page.found ? page.product.image : ""
                        }
                        Controls.ProductBadge {
                            x: 24
                            y: 24
                            product: page.product
                        }
                    }
                    Column {
                        id: info
                        width: 576
                        spacing: 20
                        Controls.PText {
                            visible: text !== ""
                            ts: Theme.brandAccent
                            color: Theme.accent
                            text: page.found ? page.product.brand : ""
                        }
                        Controls.PText {
                            width: parent.width
                            ts: Theme.pdpTitle
                            wrapMode: Text.WordWrap
                            text: page.found ? page.product.name : ""
                        }
                        // Price block
                        Rectangle {
                            width: parent.width
                            height: priceColumn.height + 44
                            radius: Theme.rCard
                            color: Theme.surfaceTint
                            Column {
                                id: priceColumn
                                x: 22
                                y: 22
                                spacing: 10
                                Controls.PText {
                                    ts: Theme.pdpPrice
                                    text: page.found ? page.product.priceText : ""
                                }
                                Row {
                                    spacing: 8
                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 8
                                        height: 8
                                        radius: height / 2
                                        color: page.found && page.product.inStock === true && page.product.lowStock !== true ? Theme.success : Theme.error
                                    }
                                    Controls.PText {
                                        ts: Theme.small13
                                        color: Theme.textLabel
                                        text: page.availabilityText
                                    }
                                }
                            }
                        }
                        Controls.PText {
                            width: parent.width
                            ts: Theme.body
                            color: Theme.textBody
                            wrapMode: Text.WordWrap
                            text: page.found ? page.product.description : ""
                        }
                        // Prescription notice (Rx products only)
                        Rectangle {
                            visible: page.rx
                            width: parent.width
                            height: rxRow.height + 36
                            radius: Theme.rOption
                            color: Theme.midnight900
                            Row {
                                id: rxRow
                                x: 18
                                y: 18
                                spacing: 14
                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: Theme.rTile
                                    color: Theme.alpha(Theme.white, 0.1)
                                    Controls.Icon {
                                        anchors.centerIn: parent
                                        name: "rx"
                                        size: 22
                                        color: Theme.azure300
                                    }
                                }
                                Column {
                                    width: 576 - 36 - 40 - 14
                                    spacing: 4
                                    Controls.PText {
                                        ts: Theme.cardLine
                                        color: Theme.white
                                        text: "Prescription required"
                                    }
                                    Controls.PText {
                                        width: parent.width
                                        ts: Theme.bodyS
                                        color: Theme.alpha(Theme.white, 0.7)
                                        wrapMode: Text.WordWrap
                                        text: "This medicine is dispensed only with a valid prescription. You will be asked to confirm your prescription at checkout."
                                    }
                                }
                            }
                        }
                        // Admins do not shop: they get a link to the product in the admin area instead
                        Controls.PcButton {
                            visible: App.isAdmin && page.found
                            variant: "secondary"
                            text: "Manage in admin"
                            iconName: "arrowR"
                            onClicked: App.go("admin", { tab: "products", edit: page.productId })
                        }
                        // Buy row
                        Row {
                            visible: !App.isAdmin
                            spacing: 12
                            Controls.QuantitySelector {
                                value: page.quantity
                                maximum: page.found ? Math.max(1, page.product.stock) : 1
                                enabled: page.found && page.product.inStock === true
                                onStepped: (newValue) => page.quantity = newValue
                            }
                            Controls.PcButton {
                                width: 576 - 136 - 12
                                text: page.rx ? "Add to Cart · Rx" : "Add to Cart"
                                iconName: "bag"
                                iconFirst: true
                                enabled: page.found && page.product.inStock === true
                                onClicked: {
                                    const result = App.addToCart(page.productId, page.quantity)
                                    if (result.ok)
                                        App.openCartDrawer()
                                    else
                                        App.showToast("error", "Could not add to bag", result.message)
                                }
                            }
                        }
                        // Buy Now: Royal Glow gradient + glow (adds the quantity, then checkout)
                        Controls.PcButton {
                            visible: !App.isAdmin
                            width: 576
                            gradient: true
                            text: "Buy Now"
                            iconName: "arrowR"
                            enabled: page.found && page.product.inStock === true
                            onClicked: {
                                const result = App.addToCart(page.productId, page.quantity)
                                if (result.ok)
                                    App.goToCheckout()
                                else
                                    App.showToast("error", "Could not add to bag", result.message)
                            }
                        }
                    }
                }
            }

            // ---------- Details: description + specifications | accordions ----------
            Item {
                visible: page.found
                width: parent.width
                height: 88 + Math.max(details.height, accordions.height)
                Row {
                    y: 88
                    width: Theme.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 64
                    Column {
                        id: details
                        width: 736
                        spacing: 24
                        Column {
                            spacing: 24
                            Controls.PText {
                                ts: Theme.overline
                                color: Theme.accent
                                text: "About this product"
                            }
                            Controls.PText {
                                ts: Theme.h2
                                text: "Description"
                            }
                        }
                        Controls.PText {
                            width: parent.width
                            ts: Theme.bodyL
                            color: Theme.textBody
                            wrapMode: Text.WordWrap
                            text: page.found ? page.product.description : ""
                        }
                        Item {
                            width: 1
                            height: 16
                        }
                        Controls.PText {
                            ts: Theme.h3
                            text: "Specifications"
                        }
                        SpecTable {
                            rows: page.found ? [
                                { label: "Product code", value: page.product.code },
                                { label: "Category", value: page.product.category },
                                { label: "Classification", value: page.rx ? "Prescription-only medicine (Rx)" : "No prescription needed" },
                                { label: "Expiry date", value: page.product.expiryText !== "" ? page.product.expiryText : "No expiry date" },
                                { label: "Availability", value: page.product.inStock === true ? "In stock" : (page.product.expired === true ? "Expired" : "Out of stock") }
                            ] : []
                        }
                    }
                    Column {
                        id: accordions
                        width: 480
                        spacing: 12
                        Controls.Accordion {
                            open: true
                            title: "Prescription"
                            body: page.rx
                                  ? "This is a prescription-only medicine. Before your order is placed you will be asked to confirm that you hold a valid prescription."
                                  : "No prescription is needed for this product."
                        }
                        Controls.Accordion {
                            title: "Expiry date"
                            body: page.found && page.product.expiryText !== ""
                                  ? "Best before " + page.product.expiryText + "."
                                  : "This product has no expiry date."
                        }
                        Controls.Accordion {
                            title: "Availability"
                            body: !page.found ? ""
                                  : page.product.inStock === true ? page.product.stock + " in stock and ready to order."
                                  : page.product.expired === true ? "This product has expired and cannot be ordered."
                                  : "This product is currently out of stock."
                        }
                    }
                }
            }

            // ---------- Related products ----------
            Item {
                visible: page.found && page.related.length > 0
                width: parent.width
                height: visible ? 88 + relatedHeader.height + 32 + 436 : 0
                Controls.SectionHeader {
                    id: relatedHeader
                    y: 88
                    anchors.horizontalCenter: parent.horizontalCenter
                    overline: "Complete your routine"
                    title: "Related products"
                }
                Row {
                    anchors.top: relatedHeader.bottom
                    anchors.topMargin: 32
                    x: (parent.width - Theme.contentWidth) / 2
                    spacing: 24
                    Repeater {
                        model: page.related
                        delegate: Controls.ProductCard {
                            required property var modelData
                            product: modelData
                        }
                    }
                }
            }

            // ---------- Recently viewed ----------
            Item {
                visible: page.found && page.recent.length > 0
                width: parent.width
                height: visible ? 72 + 32 + 24 + 96 : 0
                Controls.PText {
                    y: 72
                    x: (parent.width - Theme.contentWidth) / 2
                    ts: Theme.h3
                    text: "Recently viewed"
                }
                Row {
                    y: 72 + 32 + 24
                    x: (parent.width - Theme.contentWidth) / 2
                    spacing: 16
                    Repeater {
                        model: page.recent
                        delegate: Controls.MiniProductCard {
                            required property var modelData
                            product: modelData
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 96
            }
        }
    }
