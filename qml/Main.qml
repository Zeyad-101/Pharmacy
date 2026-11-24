// El file da howa el window el asasy: el header wel footer, tagheer el safa7at, el cart drawer, el quick view, el search, wel toasts.
// Owner: Abdelrhman (GUI)
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Basic

Basic.ApplicationWindow {
    id: window
    width: Theme.designWidth
    height: 900
    minimumWidth: 1280
    minimumHeight: 800
    visible: true
    title: "PharmaCare"
    color: Theme.white

    property bool overlayShot: false
    // The checkout uses the reduced header and footer from the design
    readonly property bool checkoutMode: App.currentPage === "checkout"

    // ---------- Navigation helpers ----------
    function closeOverlays() {
        quickViewPopup.close()
        drawerPopup.close()
        searchPopup.close()
    }

    Connections {
        target: App
        function onPageChanged() {
            window.closeOverlays()
            flick.contentY = 0
        }
        function onToastRequested(kind: string, title: string, message: string) {
            toastModel.append({ toastKind: kind, toastTitle: title, toastMessage: message })
        }
        function onCartDrawerRequested() {
            if (App.isAdmin)
                return   // admins do not shop
            drawer.justAdded = true
            drawer.refresh()
            drawerPopup.open()
        }
        function onSessionChanged() {
            if (App.isAdmin)
                drawerPopup.close()
        }
        function onQuickViewRequested(productId: string) {
            quickView.productId = productId
            quickViewPopup.open()
        }
    }

    // ---------- Header (sticky) ----------
    Item {
        id: topBar
        objectName: "shotHeader"
        z: 2
        width: parent.width
        height: window.checkoutMode ? checkoutHeader.height : header.height
        Controls.CheckoutHeader {
            id: checkoutHeader
            visible: window.checkoutMode
            width: parent.width
        }
    HeaderDesktop {
        id: header
        visible: !window.checkoutMode
        width: parent.width
        onSearchEdited: (value) => {
            if (value.trim() === "")
                searchPopup.close()
            else
                searchPopup.open()
        }
        onSearchSubmitted: (value) => {
            searchPopup.close()
            if (value.trim() !== "")
                App.go("shop", { search: value.trim() })
        }
        onSearchEscaped: searchPopup.close()
        onCartClicked: {
            drawer.justAdded = false
            drawer.refresh()
            drawerPopup.open()
        }
        onSignOutRequested: {
            App.logout()
            App.showToast("info", "Signed out", "See you soon.")
            // Pages that need a session (or an admin) are left for the home page
            if (["checkout", "account", "orderDetails", "admin", "confirmation"].indexOf(App.currentPage) !== -1)
                App.go("home")
        }
    }
    }

    // ---------- Page + footer (scrolls under the header) ----------
    Flickable {
        id: flick
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        contentWidth: width
        contentHeight: pageColumn.height
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        Basic.ScrollBar.vertical: Basic.ScrollBar {
            policy: Basic.ScrollBar.AsNeeded
        }

        // Opaque page background, so translucent shadows are grabbed correctly by --shot
        Rectangle {
            objectName: "shotPage"
            width: flick.width
            height: pageColumn.height
            color: Theme.white
            Column {
                id: pageColumn
                width: parent.width
                Loader {
                    id: pageLoader
                    width: parent.width
                    sourceComponent: App.currentPage === "shop" ? shopPage
                                   : App.currentPage === "product" ? productPage
                                   : App.currentPage === "cart" ? cartPage
                                   : App.currentPage === "checkout" ? checkoutPage
                                   : App.currentPage === "confirmation" ? confirmationPage
                                   : App.currentPage === "login" ? loginPage
                                   : App.currentPage === "register" ? registerPage
                                   : App.currentPage === "account" ? accountPage
                                   : App.currentPage === "orderDetails" ? orderDetailsPage
                                   : App.currentPage === "admin" ? adminPage
                                   : homePage
                    // Page change: a short fade-in (Theme.overlayDuration)
                    onLoaded: pageFade.restart()
                    NumberAnimation {
                        id: pageFade
                        target: pageLoader.item
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Theme.overlayDuration
                        easing.type: Easing.OutCubic
                    }
                }
                FooterDesktop {
                    visible: !window.checkoutMode
                    width: parent.width
                }
                Controls.CheckoutFooter {
                    visible: window.checkoutMode
                    width: parent.width
                }
            }
        }
    }

    Component {
        id: homePage
        HomePage {}
    }
    Component {
        id: shopPage
        ShopPage {}
    }
    Component {
        id: productPage
        ProductPage {}
    }
    Component {
        id: cartPage
        CartPage {}
    }
    Component {
        id: checkoutPage
        CheckoutPage {}
    }
    Component {
        id: confirmationPage
        ConfirmationPage {}
    }
    Component {
        id: loginPage
        AccountPages.LoginPage {}
    }
    Component {
        id: registerPage
        AccountPages.RegisterPage {}
    }
    Component {
        id: accountPage
        AccountPages.AccountPage {}
    }
    Component {
        id: orderDetailsPage
        OrderDetailsPage {}
    }
    Component {
        id: adminPage
        AdminPages.AdminPage {}
    }

    // ---------- Search suggestions (under the header search bar) ----------
    Basic.Popup {
        id: searchPopup
        parent: header.searchAnchor
        x: 0
        y: header.searchAnchor.height + 8
        padding: 0
        focus: false
        closePolicy: Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutsideParent
        background: Item {}
        contentItem: SearchSuggestions {
            term: header.searchText.trim()
            onCloseRequested: searchPopup.close()
        }
    }

    // ---------- Quick view (centred) ----------
    Basic.Popup {
        id: quickViewPopup
        focus: true   // so Escape closes it
        anchors.centerIn: parent
        padding: 0
        modal: true
        dim: false
        background: Item {}
        contentItem: ShopPages.QuickView {
            id: quickView
            onCloseRequested: quickViewPopup.close()
        }
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.overlayDuration }
            NumberAnimation { property: "scale"; from: 0.96; to: 1; duration: Theme.overlayDuration; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.overlayDuration }
        }
    }

    // ---------- Cart drawer (right side, under the header) ----------
    Basic.Popup {
        id: drawerPopup
        focus: true   // so Escape closes it
        x: window.width - width
        y: topBar.height
        width: 460
        height: window.height - topBar.height
        padding: 0
        modal: true
        dim: false
        background: Item {}
        contentItem: CartDrawer {
            id: drawer
            onCloseRequested: drawerPopup.close()
        }
        enter: Transition {
            NumberAnimation { property: "x"; from: window.width; to: window.width - 460; duration: Theme.overlayDuration; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "x"; from: window.width - 460; to: window.width; duration: Theme.overlayDuration; easing.type: Easing.InCubic }
        }
    }

    // ---------- Toasts (top-right, close after a delay or on click) ----------
    ListModel {
        id: toastModel
    }
    Column {
        z: 10
        anchors.right: parent.right
        anchors.rightMargin: 24
        y: topBar.height + 24
        spacing: 12
        Repeater {
            model: toastModel
            delegate: Controls.Toast {
                id: toastDelegate
                required property int index
                required property string toastKind
                required property string toastTitle
                required property string toastMessage
                kind: toastKind
                title: toastTitle
                message: toastMessage
                onClosed: toastModel.remove(toastDelegate.index)
                Timer {
                    interval: Theme.toastDuration
                    running: true
                    onTriggered: toastModel.remove(toastDelegate.index)
                }
            }
        }
    }

    // ---------- Verification only (--shot) ----------
    // spec: "home", "shop", "shop:<category>", "search:<term>", "product:<id>", "quickview:<id>", "drawer", "suggest:<term>",
    //       "cart", "cartpromo", "cartlong", "cartempty", "login", "register", "checkout", "confirmation",
    //       "account", "password", "orders", "orderdetails[:index]", "admin", "adminproducts", "adminorders",
    //       "admininventory", "adminform[:<id>]", "adminpdp", "adminorderdetails",
    //       "loginguest", "guestcheckout", "guestconfirmation"
    function prepareShot(spec: var): void {
        const text = String(spec)
        const colon = text.indexOf(":")
        const name = colon === -1 ? text : text.substring(0, colon)
        const arg = colon === -1 ? "" : text.substring(colon + 1)
        overlayShot = false
        if (name === "shop") {
            App.go("shop", arg === "" ? {} : { category: arg })
        } else if (name === "search") {
            App.go("shop", { search: arg })
        } else if (name === "product") {
            App.go("product", { id: arg })
        } else if (name === "quickview") {
            overlayShot = true
            App.go("shop")
            App.openQuickView(arg)
        } else if (name === "drawer") {
            overlayShot = true
            App.addToCart("P004", 1)
            App.addToCart("P009", 1)
            App.addToCart("P001", 1)
            App.openCartDrawer()
        } else if (name === "cart" || name === "cartpromo" || name === "cartlong") {
            App.addToCart("P004", 1)
            App.addToCart("P009", 1)
            App.addToCart("P001", 1)
            if (name === "cartlong")
                App.addToCart("P012", 5)   // 12,250.00 EGP line: long amounts must not crowd the stepper
            if (name === "cartpromo")
                App.applyPromo("WELLNESS15")
            App.go("cart")
        } else if (name === "cartempty") {
            App.go("cart")
        } else if (name === "login" || name === "register") {
            App.go(name)
        } else if (name === "loginguest") {
            // Sign in reached from the checkout: "Continue as guest" under "Sign in"
            App.addToCart("P004", 1)
            App.goToCheckout()
        } else if (name === "guestcheckout" || name === "guestconfirmation") {
            App.addToCart("P004", 1)
            App.addToCart("P009", 1)
            App.addToCart("P001", 1)
            App.applyPromo("WELLNESS15")
            App.continueAsGuest()
            if (name === "guestconfirmation") {
                const placed = App.placeOrder({ phone: "01012345678", city: "Cairo", street: "El Tahrir Street, Downtown",
                                                building: "12", apartment: "4", postalCode: "11511" }, false, false, false)
                App.go("confirmation", { orderId: placed.orderId })
            }
        } else if (name === "checkout" || name === "confirmation") {
            // Verification only (Data/ is restored afterwards): a demo customer places a demo order
            demoCustomer()
            App.addToCart("P004", 1)
            App.addToCart("P009", 1)
            App.addToCart("P001", 1)
            App.applyPromo("WELLNESS15")
            if (name === "checkout") {
                App.go("checkout")
            } else {
                const result = App.placeOrder({ city: "Cairo", street: "El Tahrir Street, Downtown", building: "12", apartment: "4", postalCode: "11511" },
                                              false, false, false)
                App.go("confirmation", { orderId: result.orderId })
            }
        } else if (name === "account" || name === "password" || name === "orders" || name === "orderdetails") {
            const ids = demoOrders()
            demoCustomer()
            if (name === "orderdetails")
                App.go("orderDetails", { orderId: ids[arg === "" ? 1 : parseInt(arg, 10)] })
            else
                App.go("account", { tab: name === "account" ? "profile" : name })
        } else if (name === "admin" || name === "adminproducts" || name === "adminorders" || name === "admininventory"
                   || name === "adminform" || name === "adminpdp" || name === "adminorderdetails") {
            const placed = demoOrders()
            App.login("admin", "Admin@1234")
            if (name === "adminproducts")
                App.go("admin", { tab: "products" })
            else if (name === "adminorders")
                App.go("admin", { tab: "orders" })
            else if (name === "admininventory")
                App.go("admin", { tab: "inventory" })
            else if (name === "adminform") {
                overlayShot = true
                App.go("admin", { tab: "products", edit: arg === "" ? "P004" : arg })
            } else if (name === "adminpdp")
                App.go("product", { id: "P004" })
            else if (name === "adminorderdetails")
                App.go("orderDetails", { orderId: placed[0] })
            else
                App.go("admin")
        } else if (name === "suggest") {
            overlayShot = true
            header.setSearch(arg)
            searchPopup.open()
        } else {
            App.go("home")
        }
    }
    // Verification only: the demo customer (created on first use) and three demo orders in different states
    function demoCustomer(): void {
        if (!App.login("salma", "Salma@2026").ok)
            App.registerCustomer({ username: "salma", email: "salma@example.com", phone: "01012345678", password: "Salma@2026",
                                   city: "Giza", street: "Pyramids Road", building: "7", apartment: "3", postalCode: "12511" })
    }
    function demoOrders(): var {
        demoCustomer()
        const address = { city: "Giza", street: "Pyramids Road", building: "7", apartment: "3", postalCode: "12511" }
        const baskets = [["P004", "P009", "P001"], ["P005", "P011"], ["P012"]]
        const ids = []
        for (let i = 0; i < baskets.length; ++i) {
            for (let j = 0; j < baskets[i].length; ++j)
                App.addToCart(baskets[i][j], 1)
            if (i === 0)
                App.applyPromo("WELLNESS15")
            ids.push(App.placeOrder(address, false, false, false).orderId)
        }
        App.cancelMyOrder(ids[2])
        App.login("admin", "Admin@1234")
        App.updateOrderStatus(ids[0], "confirmed")
        App.updateOrderStatus(ids[0], "processing")
        App.updateOrderStatus(ids[0], "shipped")
        App.logout()
        return ids
    }
    function isOverlayShot(): var {
        return overlayShot
    }
}
