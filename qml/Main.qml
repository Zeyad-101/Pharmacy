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
    Controls.HeaderDesktop {
        id: header
        objectName: "shotHeader"
        z: 2
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
    }

    // ---------- Page + footer (scrolls under the header) ----------
    Flickable {
        id: flick
        anchors.top: header.bottom
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

        Column {
            id: pageColumn
            objectName: "shotPage"
            width: flick.width
            Loader {
                id: pageLoader
                width: parent.width
                sourceComponent: App.currentPage === "shop" ? shopPage
                               : App.currentPage === "product" ? productPage
                               : homePage
            }
            Controls.FooterDesktop {
                width: parent.width
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
        y: header.height
        width: 460
        height: window.height - header.height
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
        y: header.height + 24
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
    // spec: "home", "shop", "shop:<category>", "search:<term>", "product:<id>", "quickview:<id>", "drawer", "suggest:<term>"
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
