// Component mancool men Controls.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Controls.Basic as Basic

Item {
        id: header
        property bool announcementVisible: true
        readonly property Item searchAnchor: searchBar
        readonly property alias searchText: searchBar.text
        signal searchEdited(string text)
        signal searchSubmitted(string text)
        signal searchEscaped()
        signal cartClicked()
        signal signOutRequested()

        function clearSearch() {
            searchBar.clear()
        }
        function setSearch(value: string) {
            searchBar.text = value
            searchBar.focusField()
        }

        width: parent ? parent.width : Theme.designWidth
        height: (announcementVisible ? 40 : 0) + 84 + 52

        Rectangle {
            anchors.fill: parent
            color: Theme.white
        }

        // Announcement bar (horizontal gradient)
        Item {
            id: announcement
            visible: header.announcementVisible
            width: parent.width
            height: visible ? 40 : 0
            Controls.GradientFill {
                anchors.fill: parent
                direction: "horizontal"
                colors: Theme.gradAnnouncement
            }
            Item {
                width: Theme.contentWidth
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    Controls.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "shield"
                        size: 14
                        color: Theme.azure300
                    }
                    Controls.PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.caption
                        color: Theme.alpha(Theme.white, 0.7)
                        text: "Licensed pharmacy · Every prescription order is checked"
                    }
                }
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Controls.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "sparkle"
                        size: 14
                        color: Theme.azure300
                    }
                    Controls.PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.caption
                        color: Theme.white
                        textFormat: Text.StyledText
                        text: "Use code <font color=\"" + Theme.azure300 + "\">WELLNESS15</font> for 15% off your order"
                    }
                }
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 18
                    Controls.PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.caption
                        color: Theme.alpha(Theme.white, 0.7)
                        text: "EN · EGP"
                    }
                    Controls.IconButton {
                        width: 24
                        height: 24
                        fill: Theme.alpha(Theme.white, 0.1)
                        hoverFill: Theme.alpha(Theme.white, 0.2)
                        iconName: "x"
                        iconSize: 12
                        iconColor: Theme.white
                        onClicked: header.announcementVisible = false
                    }
                }
            }
        }

        // Main nav: logo, search, account, cart
        Item {
            id: mainNav
            anchors.top: announcement.bottom
            width: parent.width
            height: 84
            Item {
                width: Theme.contentWidth
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                Controls.Logo {
                    id: headerLogo
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: App.go("home")
                    }
                }
                Controls.SearchBar {
                    id: searchBar
                    width: 560
                    height: 52
                    // space-between: equal gaps between logo, search and actions
                    x: headerLogo.width + (parent.width - headerLogo.width - width - actions.width) / 2
                    anchors.verticalCenter: parent.verticalCenter
                    onEdited: (value) => header.searchEdited(value)
                    onSubmitted: (value) => header.searchSubmitted(value)
                    onEscaped: header.searchEscaped()
                }
                Row {
                    id: actions
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    // Account pill: guests go to "Sign in"; signed-in users get the account menu
                    Rectangle {
                        id: accountPill
                        width: accountRow.implicitWidth + 18
                        height: 52
                        radius: height / 2
                        color: accountHover.hovered || accountMenu.opened ? Theme.surfaceTint : "transparent"
                        Row {
                            id: accountRow
                            x: 6
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Rectangle {
                                width: 40
                                height: 40
                                radius: height / 2
                                color: Theme.surfaceTint
                                Controls.Icon {
                                    anchors.centerIn: parent
                                    name: "user"
                                    size: 20
                                }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Controls.PText {
                                    ts: Theme.meta12
                                    color: Theme.textSecondary
                                    text: App.isLoggedIn ? "Hello, " + App.currentUserName : "Welcome"
                                }
                                Controls.PText {
                                    ts: Theme.link
                                    text: App.isLoggedIn ? (App.isAdmin ? "Admin" : "My account") : "Sign in"
                                }
                            }
                        }
                        HoverHandler {
                            id: accountHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (App.isLoggedIn)
                                    accountMenu.opened ? accountMenu.close() : accountMenu.open()
                                else
                                    App.go("login")
                            }
                        }
                        Basic.Popup {
                            id: accountMenu
                            y: accountPill.height + 6
                            width: 240
                            padding: 8
                            closePolicy: Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutsideParent
                            background: Controls.ShadowRect {
                                radius: Theme.rMenu
                                color: Theme.white
                                border.width: Theme.borderThin
                                border.color: Theme.borderHairline
                                elevation: "md"
                            }
                            contentItem: Column {
                                spacing: 2
                                Controls.MenuOption {
                                    visible: App.isAdmin
                                    width: parent.width
                                    text: "Admin dashboard"
                                    onClicked: {
                                        accountMenu.close()
                                        App.go("admin")
                                    }
                                }
                                Controls.MenuOption {
                                    width: parent.width
                                    text: "My account"
                                    onClicked: {
                                        accountMenu.close()
                                        App.go("account", { tab: "profile" })
                                    }
                                }
                                Controls.MenuOption {
                                    visible: !App.isAdmin
                                    width: parent.width
                                    text: "My orders"
                                    onClicked: {
                                        accountMenu.close()
                                        App.go("account", { tab: "orders" })
                                    }
                                }
                                Controls.Divider {
                                    width: parent.width
                                }
                                Controls.MenuOption {
                                    width: parent.width
                                    text: "Sign out"
                                    onClicked: {
                                        accountMenu.close()
                                        header.signOutRequested()
                                    }
                                }
                            }
                        }
                    }
                    // Admin pill: admins do not shop, so the cart is replaced by a link to the admin area
                    Rectangle {
                        visible: App.isAdmin
                        width: adminRow.implicitWidth + 32
                        height: 48
                        radius: height / 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: adminHover.hovered || App.currentPage === "admin" ? Theme.royal600 : Theme.midnight900
                        Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
                        Row {
                            id: adminRow
                            x: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Controls.Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "grid"
                                size: 18
                                color: Theme.white
                            }
                            Controls.PText {
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.link
                                color: Theme.white
                                text: "Admin"
                            }
                        }
                        HoverHandler {
                            id: adminHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: App.go("admin")
                        }
                    }
                    // Cart pill
                    Rectangle {
                        visible: !App.isAdmin
                        width: cartRow.implicitWidth + 32
                        height: 48
                        radius: height / 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: cartHover.hovered ? Theme.royal600 : Theme.midnight900
                        Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
                        Row {
                            id: cartRow
                            x: 14
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Controls.Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "bag"
                                size: 20
                                color: Theme.white
                            }
                            Controls.PText {
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.link
                                color: Theme.white
                                text: "Cart"
                            }
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: Math.max(24, cartCountText.implicitWidth + 16)
                                height: 22
                                radius: height / 2
                                color: Theme.azure500
                                Controls.PText {
                                    id: cartCountText
                                    anchors.centerIn: parent
                                    ts: Theme.countBadge
                                    color: Theme.white
                                    text: App.cartCount
                                }
                            }
                        }
                        HoverHandler {
                            id: cartHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: header.cartClicked()
                        }
                    }
                }
            }
        }

        // Category nav
        Rectangle {
            anchors.top: mainNav.bottom
            width: parent.width
            height: 52
            color: Theme.white
            Controls.Divider {
                anchors.top: parent.top
                width: parent.width
            }
            Controls.Divider {
                anchors.bottom: parent.bottom
                width: parent.width
            }
            Row {
                width: Theme.contentWidth
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 34
                Controls.TextLink {
                    iconName: "grid"
                    spacing: 8
                    color: Theme.textPrimary
                    textStyle: Theme.linkBold
                    text: "All Categories"
                    onClicked: App.go("shop")
                }
                Repeater {
                    model: App.categories()
                    delegate: Controls.TextLink {
                        id: categoryLink
                        required property var modelData
                        color: Theme.midnight600
                        textStyle: Theme.small13
                        text: modelData.name
                        onClicked: App.go("shop", { category: categoryLink.modelData.name })
                    }
                }
            }
        }
    }
