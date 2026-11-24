// Component mancool men CheckoutPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Controls.Basic as Basic

Item {
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

        readonly property bool guest: App.isGuestCheckout
        readonly property var address: ({
            phone: guestPhoneField.text,
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
            } else if (result.status === "invalidPhone") {
                // Guest checkout: back to the details with the backend's phone message
                step = 0
                missing = ["phone"]
                bannerText = result.message
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
                CheckoutStepper {
                    width: 780
                    steps: ["Shipping address", "Review"]
                    current: checkout.step
                }
                Controls.ErrorBanner {
                    visible: checkout.bannerText !== ""
                    width: parent.width
                    text: checkout.bannerText
                }

                // Guest checkout: sign-in is optional; offer it at the top of the first step
                Controls.InlineNotice {
                    visible: checkout.step === 0 && checkout.guest
                    width: parent.width
                    text: "Already have an account?"
                    actionText: "Sign in"
                    onAction: App.go("login", { next: "checkout" })
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
                                text: checkout.guest ? "Checking out as a guest: a phone number for the delivery, then the address."
                                                     : "Where should we deliver your order?"
                            }
                        }
                        // Guest checkout: the backend keeps the phone with the order (no email or name is stored)
                        Row {
                            visible: checkout.guest
                            spacing: 24
                            Controls.FormInput {
                                id: guestPhoneField
                                width: 344
                                label: "Phone number"
                                placeholder: "01XXXXXXXXX"
                                maximumLength: 11
                                status: checkout.missing.indexOf("phone") !== -1 ? "error" : ""
                                helper: status === "error" ? "Phone number must be 11 digits and start with 01." : ""
                                onAccepted: checkout.continueToReview()
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
                            visible: !checkout.guest      // a guest has no account to save it to
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
                                    { icon: "user", title: "Contact",
                                      line1: checkout.guest ? "Guest" : checkout.profile.ok ? checkout.profile.username : "",
                                      line2: checkout.guest ? guestPhoneField.text
                                           : checkout.profile.ok ? checkout.profile.email + " · " + checkout.profile.phone : "",
                                      edit: checkout.guest, owner: checkout },
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
            contentItem: CheckoutPages.PrescriptionModal {
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
