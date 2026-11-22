// El file da fih safa7at el shira2: el cart, el cart drawer, el checkout (el 3enwan w el review), el confirmation, wel prescription modal.
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Controls.Basic as Basic

QtObject {

    // ===================== CART PAGE =====================
    component CartPage: Item {
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
                    Controls.Breadcrumb {
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

    // ===================== CART DRAWER (overlay on the right) =====================
    component CartDrawer: Item {
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

    // ===================== CHECKOUT (shipping address -> review -> place order) =====================
    component CheckoutPage: Item {
        id: checkout
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: Math.max(checkoutBody.height + 120, 760)

        property int step: 0
        property var cart: App.cartItems()
        property var totals: App.cartTotals()
        readonly property var profile: App.currentUserProfile()
        property var missing: []
        property string bannerText: ""
        property bool placing: false
        property bool prescriptionConfirmed: false
        property bool acceptPriceChanges: false
        property var priceChanges: []

        readonly property var address: ({
            city: cityField.text,
            street: streetField.text,
            building: buildingField.text,
            apartment: apartmentField.text,
            postalCode: postalField.text
        })

        function refresh() {
            cart = App.cartItems()
            totals = App.cartTotals()
        }
        function continueToReview() {
            const check = App.checkAddress(address)
            missing = check.missing
            bannerText = check.message
            if (check.ok) {
                bannerText = ""
                step = 1
            }
        }
        function startPlaceOrder() {
            bannerText = ""
            // Rx items: the customer must confirm the prescription first (Prescription modal)
            if (App.cartNeedsPrescription() && !prescriptionConfirmed) {
                prescriptionPopup.open()
                return
            }
            placeOrder()
        }
        function placeOrder() {
            placing = true
            const result = App.placeOrder(address, saveAddress.checked, prescriptionConfirmed, acceptPriceChanges)
            placing = false
            if (result.ok) {
                App.go("confirmation", { orderId: result.orderId })
                return
            }
            if (result.status === "prescriptionRequired") {
                prescriptionConfirmed = false
                prescriptionPopup.open()
            } else if (result.status === "priceChanged") {
                priceChanges = result.priceChanges
                pricePopup.open()
            } else if (result.status === "invalidAddress") {
                step = 0
                continueToReview()
                if (bannerText === "")
                    bannerText = result.message
            } else if (result.status === "emptyCart") {
                // App.go() replaces this page, so nothing of the page may run after it
                App.showToast("error", "Your bag is empty", result.message)
                App.go("cart")
                return
            } else if (result.status === "customerNotFound") {
                App.showToast("error", "Please sign in again", result.message)
                App.logout()
                App.go("login", { next: "checkout" })
                return
            } else {
                bannerText = result.message
            }
            refresh()
        }

        Component.onCompleted: {
            const saved = profile.ok ? profile.address : null
            if (saved !== null && saved.valid === true) {
                cityField.text = saved.city
                streetField.text = saved.street
                buildingField.text = saved.building
                apartmentField.text = saved.apartment
                postalField.text = saved.postalCode
            }
        }

        Connections {
            target: App
            function onCartChanged() {
                checkout.refresh()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.surfaceTint
        }

        // Empty bag: nothing to check out
        Controls.EmptyState {
            visible: checkout.cart.empty
            y: 40
            width: Theme.contentWidth
            anchors.horizontalCenter: parent.horizontalCenter
            iconName: "bag"
            title: "Your bag is empty"
            message: "Add products to your bag before checking out."
            actionText: "Continue shopping"
            onAction: App.go("shop")
        }

        Row {
            id: checkoutBody
            visible: !checkout.cart.empty
            y: 40
            x: (parent.width - Theme.contentWidth) / 2
            spacing: 48

            // ---------- Main column ----------
            Column {
                width: 792
                spacing: 24
                Controls.CheckoutStepper {
                    width: 780
                    steps: ["Shipping address", "Review"]
                    current: checkout.step
                }
                Controls.ErrorBanner {
                    visible: checkout.bannerText !== ""
                    width: parent.width
                    text: checkout.bannerText
                }

                // Step 1: shipping address
                Controls.ShadowRect {
                    visible: checkout.step === 0
                    width: parent.width
                    height: addressColumn.height + 80
                    radius: Theme.rModal
                    color: Theme.white
                    border.width: Theme.borderThin
                    border.color: Theme.borderHairline
                    elevation: "sm"
                    Column {
                        id: addressColumn
                        x: 40
                        y: 40
                        width: parent.width - 80
                        spacing: 28
                        Column {
                            width: parent.width
                            spacing: 6
                            Controls.PText {
                                ts: Theme.cardTitle
                                text: "Shipping address"
                            }
                            Controls.PText {
                                width: parent.width
                                ts: Theme.body
                                color: Theme.textSecondary
                                wrapMode: Text.WordWrap
                                text: "Where should we deliver your order?"
                            }
                        }
                        Row {
                            spacing: 24
                            Controls.FormInput {
                                id: cityField
                                width: 344
                                label: "City"
                                placeholder: "Cairo"
                                status: checkout.missing.indexOf("city") !== -1 ? "error" : ""
                                helper: status === "error" ? "Please enter your city" : ""
                                onAccepted: checkout.continueToReview()
                            }
                            Controls.FormInput {
                                id: postalField
                                width: 344
                                label: "Postal code (optional)"
                                placeholder: "11511"
                                maximumLength: 10
                                onAccepted: checkout.continueToReview()
                            }
                        }
                        Controls.FormInput {
                            id: streetField
                            width: parent.width
                            label: "Street address"
                            placeholder: "Street name and area"
                            status: checkout.missing.indexOf("street") !== -1 ? "error" : ""
                            helper: status === "error" ? "Please enter your street" : ""
                            onAccepted: checkout.continueToReview()
                        }
                        Row {
                            spacing: 24
                            Controls.FormInput {
                                id: buildingField
                                width: 344
                                label: "Building number"
                                placeholder: "12"
                                status: checkout.missing.indexOf("building") !== -1 ? "error" : ""
                                helper: status === "error" ? "Please enter the building number" : ""
                                onAccepted: checkout.continueToReview()
                            }
                            Controls.FormInput {
                                id: apartmentField
                                width: 344
                                label: "Apartment / Unit (optional)"
                                placeholder: "Apt 4"
                                onAccepted: checkout.continueToReview()
                            }
                        }
                        Controls.FilterCheckbox {
                            id: saveAddress
                            width: parent.width
                            text: "Save this address for future orders"
                            onToggled: checked = !checked
                        }
                        Item {
                            width: parent.width
                            height: 64
                            Controls.TextLink {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: 4
                                iconName: "arrowL"
                                spacing: 8
                                color: Theme.textLabel
                                text: "Return to bag"
                                onClicked: App.go("cart")
                            }
                            Controls.PcButton {
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 56
                                horizontalPadding: 32
                                text: "Continue to review"
                                iconName: "arrowR"
                                onClicked: checkout.continueToReview()
                            }
                        }
                    }
                }

                // Step 2: review
                Controls.ShadowRect {
                    visible: checkout.step === 1
                    width: parent.width
                    height: reviewColumn.height + 80
                    radius: Theme.rModal
                    color: Theme.white
                    border.width: Theme.borderThin
                    border.color: Theme.borderHairline
                    elevation: "sm"
                    Column {
                        id: reviewColumn
                        x: 40
                        y: 40
                        width: parent.width - 80
                        spacing: 28
                        Column {
                            width: parent.width
                            spacing: 6
                            Controls.PText {
                                ts: Theme.cardTitle
                                text: "Review your order"
                            }
                            Controls.PText {
                                ts: Theme.body
                                color: Theme.textSecondary
                                text: "Please check everything below before placing your order."
                            }
                        }
                        // Ordered products
                        Rectangle {
                            width: parent.width
                            height: reviewItems.height + 2
                            radius: Theme.rPanel
                            color: Theme.white
                            border.width: Theme.borderThin
                            border.color: Theme.borderHairline
                            Column {
                                id: reviewItems
                                y: 1
                                width: parent.width
                                Repeater {
                                    model: checkout.cart.items
                                    delegate: Item {
                                        id: reviewLine
                                        required property var modelData
                                        required property int index
                                        width: parent ? parent.width : 0
                                        height: 96
                                        Controls.Divider {
                                            visible: reviewLine.index > 0
                                            width: parent.width
                                        }
                                        Controls.RoundedImage {
                                            id: reviewThumb
                                            x: 20
                                            y: 16
                                            width: 64
                                            height: 64
                                            radius: Theme.rThumb
                                            source: reviewLine.modelData.image
                                        }
                                        Column {
                                            anchors.left: reviewThumb.right
                                            anchors.leftMargin: 16
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 400
                                            spacing: 3
                                            Controls.PText {
                                                visible: text !== ""
                                                ts: Theme.brandLine
                                                color: Theme.textSecondary
                                                text: reviewLine.modelData.brand
                                            }
                                            Controls.PText {
                                                width: parent.width
                                                ts: Theme.cardLine
                                                elide: Text.ElideRight
                                                text: reviewLine.modelData.name
                                            }
                                            Controls.PText {
                                                ts: Theme.meta12
                                                color: Theme.textSecondary
                                                text: reviewLine.modelData.unitPriceText + " each"
                                                      + (reviewLine.modelData.requiresPrescription ? "  ·  Prescription required" : "")
                                            }
                                        }
                                        Controls.PText {
                                            anchors.right: reviewTotal.left
                                            anchors.rightMargin: 40
                                            anchors.verticalCenter: parent.verticalCenter
                                            ts: Theme.small13
                                            color: Theme.textBody
                                            text: "Qty " + reviewLine.modelData.quantity
                                        }
                                        Controls.PText {
                                            id: reviewTotal
                                            anchors.right: parent.right
                                            anchors.rightMargin: 20
                                            anchors.verticalCenter: parent.verticalCenter
                                            ts: Theme.valueStrong
                                            font.weight: Theme.linkBold.weight
                                            text: reviewLine.modelData.lineTotalText
                                        }
                                    }
                                }
                            }
                        }
                        // Contact + shipping address
                        Row {
                            spacing: 16
                            Repeater {
                                model: [
                                    { icon: "user", title: "Contact", line1: checkout.profile.ok ? checkout.profile.username : "",
                                      line2: checkout.profile.ok ? checkout.profile.email + " · " + checkout.profile.phone : "", edit: false },
                                    { icon: "pin", title: "Shipping address",
                                      line1: (checkout.address.building !== "" ? "Building " + checkout.address.building + ", " : "")
                                             + (checkout.address.apartment !== "" ? "Apt " + checkout.address.apartment + ", " : "")
                                             + checkout.address.street,
                                      line2: checkout.address.city + (checkout.address.postalCode !== "" ? ", " + checkout.address.postalCode : ""),
                                      edit: true, owner: checkout }
                                ]
                                delegate: Rectangle {
                                    id: detailTile
                                    required property var modelData
                                    width: 348
                                    height: tileColumn.height + 40
                                    radius: Theme.rOption
                                    color: Theme.surfaceTint
                                    Column {
                                        id: tileColumn
                                        x: 20
                                        y: 20
                                        width: parent.width - 40
                                        spacing: 10
                                        Item {
                                            width: parent.width
                                            height: 17
                                            Row {
                                                spacing: 8
                                                Controls.Icon {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    name: detailTile.modelData.icon
                                                    size: 16
                                                    color: Theme.royal600
                                                }
                                                Controls.PText {
                                                    ts: Theme.linkBold
                                                    text: detailTile.modelData.title
                                                }
                                            }
                                            Controls.TextLink {
                                                visible: detailTile.modelData.edit
                                                anchors.right: parent.right
                                                text: "Edit"
                                                onClicked: detailTile.modelData.owner.step = 0
                                            }
                                        }
                                        Controls.PText {
                                            width: parent.width
                                            ts: Theme.bodyS
                                            color: Theme.textBody
                                            wrapMode: Text.WordWrap
                                            text: detailTile.modelData.line1 + "\n" + detailTile.modelData.line2
                                        }
                                    }
                                }
                            }
                        }
                        // Totals
                        Column {
                            width: parent.width
                            spacing: 14
                            Controls.SummaryRow {
                                compact: true
                                label: "Subtotal (" + checkout.totals.count + (checkout.totals.count === 1 ? " item)" : " items)")
                                value: checkout.totals.subtotalText
                            }
                            Controls.SummaryRow {
                                visible: checkout.totals.hasDiscount
                                compact: true
                                label: "Discount · " + checkout.totals.promoCode
                                value: checkout.totals.discountText
                                valueColor: Theme.royal600
                            }
                            Controls.Divider {
                                width: parent.width
                            }
                            Item {
                                width: parent.width
                                height: 32
                                Controls.PText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    ts: Theme.h4
                                    text: "Final total"
                                }
                                Controls.PText {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    ts: Theme.totalPrice
                                    text: checkout.totals.totalText
                                }
                            }
                        }
                        Item {
                            width: parent.width
                            height: 64
                            Controls.TextLink {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: 4
                                iconName: "arrowL"
                                spacing: 8
                                color: Theme.textLabel
                                text: "Back to shipping"
                                onClicked: checkout.step = 0
                            }
                            Controls.PcButton {
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 56
                                horizontalPadding: 32
                                enabled: !checkout.placing
                                text: "Place order · " + checkout.totals.totalText
                                iconName: "arrowR"
                                onClicked: checkout.startPlaceOrder()
                            }
                        }
                    }
                }
            }

            // ---------- Order summary ----------
            Controls.ShadowRect {
                width: 440
                height: sideColumn.height + 56
                radius: Theme.rModal
                color: Theme.white
                border.width: Theme.borderThin
                border.color: Theme.borderHairline
                elevation: "sm"
                Column {
                    id: sideColumn
                    x: 28
                    y: 28
                    width: parent.width - 56
                    spacing: 18
                    Item {
                        width: parent.width
                        height: 25
                        Controls.PText {
                            ts: Theme.h4
                            text: "Order summary"
                        }
                        Controls.TextLink {
                            anchors.right: parent.right
                            y: 4
                            text: "Edit bag"
                            onClicked: App.go("cart")
                        }
                    }
                    Repeater {
                        model: checkout.cart.items
                        delegate: Item {
                            id: sideLine
                            required property var modelData
                            width: parent ? parent.width : 0
                            height: 60
                            Item {
                                id: sideThumb
                                width: 60
                                height: 60
                                Controls.RoundedImage {
                                    anchors.fill: parent
                                    radius: Theme.rThumb
                                    source: sideLine.modelData.image
                                }
                                Rectangle {
                                    x: 46
                                    y: -8
                                    width: Math.max(22, qtyText.implicitWidth + 12)
                                    height: 22
                                    radius: height / 2
                                    color: Theme.midnight900
                                    Controls.PText {
                                        id: qtyText
                                        anchors.centerIn: parent
                                        ts: Theme.qtyBubble
                                        color: Theme.white
                                        text: sideLine.modelData.quantity
                                    }
                                }
                            }
                            Column {
                                anchors.left: sideThumb.right
                                anchors.leftMargin: 14
                                anchors.right: sidePrice.left
                                anchors.rightMargin: 14
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                Controls.PText {
                                    width: parent.width
                                    ts: Theme.link
                                    elide: Text.ElideRight
                                    text: sideLine.modelData.name
                                }
                                Controls.PText {
                                    ts: Theme.meta12
                                    color: Theme.textSecondary
                                    text: sideLine.modelData.unitPriceText + " each"
                                }
                            }
                            Controls.PText {
                                id: sidePrice
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.linkBold
                                text: sideLine.modelData.lineTotalText
                            }
                        }
                    }
                    Controls.Divider {
                        width: parent.width
                    }
                    Controls.SummaryRow {
                        compact: true
                        label: "Subtotal"
                        value: checkout.totals.subtotalText
                    }
                    Controls.SummaryRow {
                        visible: checkout.totals.hasDiscount
                        compact: true
                        label: "Discount · " + checkout.totals.promoCode
                        value: checkout.totals.discountText
                        valueColor: Theme.royal600
                    }
                    Controls.Divider {
                        width: parent.width
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
                            text: checkout.totals.totalText
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: 49
                        radius: Theme.rMenu
                        color: Theme.surfaceTint
                        Row {
                            x: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Controls.Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "shield"
                                size: 16
                                color: Theme.royal600
                            }
                            Controls.PText {
                                ts: Theme.caption
                                color: Theme.textLabel
                                text: "Prescription items are confirmed before dispatch"
                            }
                        }
                    }
                }
            }
        }

        // Prescription modal (shown before an order with Rx items is placed)
        Basic.Popup {
            id: prescriptionPopup
            parent: Basic.Overlay.overlay
            anchors.centerIn: parent
            padding: 0
            modal: true
            dim: false
            focus: true
            background: Item {}
            contentItem: PrescriptionModal {
                productNames: App.prescriptionProductNames()
                onCancelled: prescriptionPopup.close()
                onConfirmed: {
                    prescriptionPopup.close()
                    checkout.prescriptionConfirmed = true
                    checkout.placeOrder()
                }
            }
        }

        // Price change dialog (CheckoutStatus::PriceChanged)
        Basic.Popup {
            id: pricePopup
            parent: Basic.Overlay.overlay
            anchors.centerIn: parent
            padding: 0
            modal: true
            dim: false
            focus: true
            background: Item {}
            contentItem: Controls.ModalFrame {
                implicitWidth: 560
                implicitHeight: priceColumn.height + 72
                Column {
                    id: priceColumn
                    x: 36
                    y: 36
                    width: parent.width - 72
                    spacing: 22
                    Controls.PText {
                        ts: Theme.cardTitle
                        text: "Prices have changed"
                    }
                    Controls.PText {
                        width: parent.width
                        ts: Theme.body
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                        text: "Some prices changed since you added these items to your bag. Accept the new prices to place your order."
                    }
                    Repeater {
                        model: checkout.priceChanges
                        delegate: Controls.SummaryRow {
                            required property var modelData
                            compact: true
                            label: modelData.name
                            value: modelData.oldText + "  →  " + modelData.newText
                        }
                    }
                    Row {
                        anchors.right: parent.right
                        spacing: 12
                        Controls.PcButton {
                            variant: "secondary"
                            text: "Back to bag"
                            onClicked: {
                                pricePopup.close()
                                App.go("cart")
                            }
                        }
                        Controls.PcButton {
                            text: "Accept and place order"
                            onClicked: {
                                pricePopup.close()
                                checkout.acceptPriceChanges = true
                                checkout.placeOrder()
                            }
                        }
                    }
                }
            }
        }
    }

    // ===================== PRESCRIPTION MODAL =====================
    // Design: "Prescription required". The backend has no file upload, so the customer confirms instead.
    component PrescriptionModal: Item {
        id: rxModal
        property var productNames: []
        signal confirmed()
        signal cancelled()

        implicitWidth: 560
        implicitHeight: rxColumn.height + 72

        Controls.ModalFrame {
            anchors.fill: parent
        }
        Column {
            id: rxColumn
            x: 36
            y: 36
            width: parent.width - 72
            spacing: 22
            Item {
                width: parent.width
                height: rxTitles.height
                Column {
                    id: rxTitles
                    width: 440
                    spacing: 8
                    Rectangle {
                        width: 52
                        height: 52
                        radius: Theme.rMenu
                        color: Theme.sky100
                        Controls.Icon {
                            anchors.centerIn: parent
                            name: "rx"
                            size: 24
                            color: Theme.royal600
                        }
                    }
                    Controls.PText {
                        ts: Theme.cardTitle
                        text: "Prescription required"
                    }
                    Controls.PText {
                        width: parent.width
                        ts: Theme.body
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                        text: rxModal.productNames.join(", ")
                              + (rxModal.productNames.length === 1 ? " is a prescription-only medicine." : " are prescription-only medicines.")
                              + " Please confirm that you have a valid prescription before placing your order."
                    }
                }
                Controls.IconButton {
                    anchors.right: parent.right
                    iconName: "x"
                    onClicked: rxModal.cancelled()
                }
            }
            Rectangle {
                width: parent.width
                height: 76
                radius: Theme.rPanel
                color: Theme.surfaceTint
                border.width: Theme.borderFocus
                border.color: Theme.royal400
                Controls.FilterCheckbox {
                    id: rxConfirm
                    x: 20
                    width: parent.width - 40
                    anchors.verticalCenter: parent.verticalCenter
                    text: "I confirm I have a valid prescription for these medicines"
                    onToggled: checked = !checked
                }
            }
            Row {
                anchors.right: parent.right
                spacing: 12
                Controls.PcButton {
                    variant: "secondary"
                    text: "Cancel"
                    onClicked: rxModal.cancelled()
                }
                Controls.PcButton {
                    text: "Confirm and place order"
                    iconName: "arrowR"
                    enabled: rxConfirm.checked
                    onClicked: rxModal.confirmed()
                }
            }
        }
    }

    // ===================== ORDER CONFIRMATION =====================
    component ConfirmationPage: Item {
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
                        text: App.currentUserName !== "" ? "Thank you, " + App.currentUserName + "." : "Thank you."
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
                        // Design "Track Order": opens this order in My orders (live status from the backend)
                        Controls.PcButton {
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
                                Controls.StatusTracker {
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
}
