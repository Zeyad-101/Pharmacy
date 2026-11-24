// Component mancool men Controls.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Item {
        id: footer
        width: parent ? parent.width : Theme.designWidth
        height: 80 + columns.height + 40 + 1 + 40 + 30 + 36

        Controls.GradientFill {
            anchors.fill: parent
            direction: "vertical"
            colors: Theme.gradFooter
        }
        Item {
            width: Theme.contentWidth
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter

            Item {
                id: columns
                y: 80
                width: parent.width
                height: Math.max(brandColumn.height, shopColumn.height, contactColumn.height)

                Column {
                    id: brandColumn
                    width: 320
                    spacing: 20
                    Controls.Logo {
                        dark: true
                    }
                    Controls.PText {
                        width: parent.width
                        ts: Theme.bodyS
                        color: Theme.alpha(Theme.white, 0.6)
                        wrapMode: Text.WordWrap
                        text: "A licensed online pharmacy curating clinically proven medicines, skincare and wellness essentials."
                    }
                }
                Column {
                    id: shopColumn
                    x: 385
                    spacing: 14
                    Controls.PText {
                        ts: Theme.overline
                        color: Theme.accentOnDark
                        text: "Shop"
                    }
                    Controls.TextLink {
                        color: Theme.alpha(Theme.white, 0.8)
                        textStyle: Theme.bodyS
                        text: "All Products"
                        onClicked: App.go("shop")
                    }
                    Repeater {
                        model: App.categories()
                        delegate: Controls.TextLink {
                            id: footerLink
                            required property var modelData
                            color: Theme.alpha(Theme.white, 0.8)
                            textStyle: Theme.bodyS
                            text: modelData.name
                            onClicked: App.go("shop", { category: footerLink.modelData.name })
                        }
                    }
                }
                Column {
                    id: contactColumn
                    anchors.right: parent.right
                    width: 260
                    spacing: 14
                    Controls.PText {
                        ts: Theme.overline
                        color: Theme.accentOnDark
                        text: "Stay in touch"
                    }
                    Row {
                        spacing: 10
                        Controls.Icon {
                            name: "pin"
                            size: 16
                            color: Theme.azure300
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Controls.PText {
                            ts: Theme.bodyS
                            color: Theme.alpha(Theme.white, 0.8)
                            text: "Cairo, Egypt"
                        }
                    }
                    Row {
                        spacing: 10
                        Controls.Icon {
                            name: "mail"
                            size: 16
                            color: Theme.azure300
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Controls.PText {
                            ts: Theme.bodyS
                            color: Theme.alpha(Theme.white, 0.8)
                            text: "care@pharmacare.com"
                        }
                    }
                }
            }
            Rectangle {
                id: footerDivider
                anchors.top: columns.bottom
                anchors.topMargin: 40
                width: parent.width
                height: 1
                color: Theme.alpha(Theme.white, 0.1)
            }
            Item {
                anchors.top: footerDivider.bottom
                anchors.topMargin: 40
                width: parent.width
                height: 30
                Controls.PText {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    ts: Theme.meta12
                    color: Theme.alpha(Theme.white, 0.5)
                    text: "© 2026 PharmaCare Pharmacy · Egypt"
                }
                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: cashText.implicitWidth + 24
                    height: 30
                    radius: Theme.rChip
                    color: Theme.white
                    Controls.PText {
                        id: cashText
                        anchors.centerIn: parent
                        ts: Theme.cashMark
                        text: "Cash on Delivery"
                    }
                }
            }
        }
    }
