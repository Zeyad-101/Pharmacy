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
            drawer.justAdded = true
            drawer.refresh()
            drawerPopup.open()
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
    Controls.HeaderDesktop {
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
            if (App.currentPage === "checkout")
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
                                   : homePage
                }
                Controls.FooterDesktop {
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
        ShopPages.HomePage {}
    }
    Component {
        id: shopPage
        ShopPages.ShopPage {}
    }
    Component {
        id: productPage
        ShopPages.ProductPage {}
    }
    Component {
        id: cartPage
        CheckoutPages.CartPage {}
    }
    Component {
        id: checkoutPage
        CheckoutPages.CheckoutPage {}
    }
    Component {
        id: confirmationPage
        CheckoutPages.ConfirmationPage {}
    }
    Component {
        id: loginPage
        AccountPages.LoginPage {}
    }
    Component {
        id: registerPage
        AccountPages.RegisterPage {}
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
        contentItem: ShopPages.SearchSuggestions {
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
        contentItem: CheckoutPages.CartDrawer {
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
    //       "cart", "cartpromo", "cartlong", "cartempty", "login", "register", "checkout", "confirmation"
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
        } else if (name === "checkout" || name === "confirmation") {
            // Verification only: the default admin account places a demo order on a throwaway data copy
            App.login("admin", "Admin@1234")
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
        } else if (name === "suggest") {
            overlayShot = true
            header.setSearch(arg)
            searchPopup.open()
        } else {
            App.go("home")
        }
    }
    function isOverlayShot(): var {
        return overlayShot
    }
}
