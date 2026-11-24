// Component mancool men ShopPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Item {
        id: home
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: homeColumn.height

        readonly property var categoryCopy: ({
            "Medicines": { title: "Medicines", text: "Pain relief, allergy, cold & flu and prescription care." },
            "Skincare": { title: "Skincare", text: "Dermatologist-backed serums, creams and SPF." },
            "Vitamins & Supplements": { title: "Vitamins & Supplements", text: "Daily essentials for immunity, energy and beauty." },
            "First Aid & Medical Supplies": { title: "First Aid & Medical", text: "Kits, devices and supplies for home care." }
        })
        readonly property var heroProduct: App.product("P004")
        readonly property var categoryModel: App.categories().map((c) => ({
            name: c.name,
            image: c.image,
            count: c.count,
            title: categoryCopy[c.name] !== undefined ? categoryCopy[c.name].title : c.name,
            text: categoryCopy[c.name] !== undefined ? categoryCopy[c.name].text : ""
        }))

        Column {
            id: homeColumn
            width: parent.width

            // ---------- Hero ----------
            Item {
                width: parent.width
                height: 24 + 640
                Item {
                    id: hero
                    y: 24
                    width: Theme.contentWidth
                    height: 640
                    anchors.horizontalCenter: parent.horizontalCenter

                    Controls.Rounded {
                        anchors.fill: parent
                        radius: Theme.rHero
                        Controls.GradientFill {
                            anchors.fill: parent
                            direction: "diagonal"
                            colors: Theme.gradHero
                            midPosition: Theme.gradHeroMid
                        }
                        // Soft glows (layer blur) and the thin ring
                        Controls.Glow { x: 560; y: -120; width: 520; height: 520; color: Theme.alpha(Theme.azure300, 0.6); blurRadius: 120 }
                        Controls.Glow { x: -120; y: 380; width: 420; height: 360; color: Theme.alpha(Theme.sky300, 0.6); blurRadius: 120 }
                        Controls.Glow { x: 980; y: 380; width: 380; height: 300; color: Theme.alpha(Theme.royal400, 0.2); blurRadius: 110 }
                        Rectangle {
                            x: 700
                            y: 40
                            width: 560
                            height: 560
                            radius: height / 2
                            color: "transparent"
                            border.width: 1
                            border.color: Theme.alpha(Theme.royal500, 0.1)
                        }
                    }

                    // Copy
                    Column {
                        x: 64
                        y: 40
                        width: 600
                        spacing: 26

                        Controls.ShadowRect {
                            width: promoRow.implicitWidth + 23
                            height: 42
                            radius: height / 2
                            color: Theme.white
                            elevation: "md"
                            Row {
                                id: promoRow
                                x: 7
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 10
                                Item {
                                    width: 28
                                    height: 28
                                    Controls.GradientFill {
                                        anchors.fill: parent
                                        radius: height / 2
                                        direction: "diagonal"
                                        colors: Theme.gradRoyalGlow
                                    }
                                    Controls.Icon {
                                        anchors.centerIn: parent
                                        name: "sparkle"
                                        size: 14
                                        color: Theme.white
                                    }
                                }
                                Controls.PText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    ts: Theme.link
                                    color: Theme.midnight800
                                    text: "Use code WELLNESS15  ·  15% off your order"
                                }
                            }
                        }
                        Controls.PText {
                            width: 600
                            ts: Theme.heroTitle
                            wrapMode: Text.WordWrap
                            textFormat: Text.StyledText
                            text: "Science-led care, <font color=\"" + Theme.royal600 + "\"><i>beautifully</i></font> delivered."
                        }
                        Controls.PText {
                            width: 500
                            ts: Theme.bodyL
                            color: Theme.textBody
                            wrapMode: Text.WordWrap
                            text: "Pharmacist-approved medicines, clinical skincare and daily wellness — curated by experts and delivered to your door."
                        }
                        Row {
                            spacing: 14
                            Controls.PcButton {
                                text: "Shop Now"
                                iconName: "arrowR"
                                onClicked: App.go("shop")
                            }
                            Controls.PcButton {
                                variant: "secondary"
                                text: "Explore Products"
                                iconName: "arrowR"
                                onClicked: App.go("shop")
                            }
                        }
                    }

                    // Photo, floating product card, chip
                    Controls.ShadowRect {
                        x: 750
                        y: 40
                        width: 470
                        height: 560
                        radius: Theme.rHeroPhoto
                        elevation: "lg"
                        color: Theme.surfaceTint
                        Controls.RoundedImage {
                            anchors.fill: parent
                            radius: Theme.rHeroPhoto
                            source: Theme.res + "images/hero.png"
                        }
                    }
                    Controls.ShadowRect {
                        visible: home.heroProduct.ok === true
                        x: 640
                        y: 470
                        width: 296
                        height: 88
                        radius: Theme.rCard
                        color: Theme.alpha(Theme.white, 0.9)
                        elevation: "lg"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: App.go("product", { id: "P004" })
                        }
                        Controls.RoundedImage {
                            id: floatThumb
                            x: 12
                            y: 12
                            width: 64
                            height: 64
                            radius: Theme.rThumb
                            source: home.heroProduct.ok === true ? home.heroProduct.image : ""
                        }
                        Column {
                            anchors.left: floatThumb.right
                            anchors.leftMargin: 14
                            anchors.right: floatAdd.left
                            anchors.rightMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3
                            Controls.PText {
                                ts: Theme.microBrand
                                color: Theme.textSecondary
                                text: home.heroProduct.ok === true ? home.heroProduct.brand : ""
                            }
                            Controls.PText {
                                width: parent.width
                                ts: Theme.cardLine
                                elide: Text.ElideRight
                                text: home.heroProduct.ok === true ? home.heroProduct.name : ""
                            }
                            Controls.PText {
                                ts: Theme.linkBold
                                text: home.heroProduct.ok === true ? home.heroProduct.priceText : ""
                            }
                        }
                        Controls.IconButton {
                            id: floatAdd
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            fill: Theme.midnight900
                            hoverFill: Theme.royal600
                            iconName: "plus"
                            iconColor: Theme.white
                            visible: !App.isAdmin      // admins do not shop
                            enabled: home.heroProduct.inStock === true
                            onClicked: {
                                const result = App.addToCart("P004", 1)
                                if (result.ok)
                                    App.openCartDrawer()
                                else
                                    App.showToast("error", "Could not add to bag", result.message)
                            }
                        }
                    }
                    Controls.ShadowRect {
                        x: 690
                        y: 120
                        width: chipRow.implicitWidth + 26
                        height: 53
                        radius: height / 2
                        color: Theme.white
                        elevation: "md"
                        Row {
                            id: chipRow
                            x: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Rectangle {
                                width: 32
                                height: 32
                                radius: height / 2
                                color: Theme.sky100
                                Controls.Icon {
                                    anchors.centerIn: parent
                                    name: "shield"
                                    size: 16
                                    color: Theme.royal600
                                }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Controls.PText {
                                    ts: Theme.link
                                    text: "Pharmacist verified"
                                }
                                Controls.PText {
                                    ts: Theme.tinyRegular
                                    color: Theme.textSecondary
                                    text: "Every order checked"
                                }
                            }
                        }
                    }
                }
            }

            // ---------- Benefits strip ----------
            Item {
                width: parent.width
                height: 124
                Row {
                    id: benefits
                    anchors.centerIn: parent
                    width: Theme.contentWidth
                    readonly property var items: [
                        { icon: "shield", title: "Licensed pharmacists", text: "Prescriptions checked before dispatch" },
                        { icon: "clock", title: "Track every order", text: "From placed to delivered" },
                        { icon: "tag", title: "Member offers", text: "15% off with code WELLNESS15" },
                        { icon: "award", title: "100% authentic", text: "From authorised distributors" }
                    ]
                    spacing: (width - 4 * 290) / 3
                    Repeater {
                        model: benefits.items
                        delegate: Row {
                            id: benefit
                            required property var modelData
                            width: 290
                            spacing: 14
                            Rectangle {
                                width: 52
                                height: 52
                                radius: Theme.rMenu
                                color: Theme.surfaceTint
                                border.width: Theme.borderThin
                                border.color: Theme.sky200
                                Controls.Icon {
                                    anchors.centerIn: parent
                                    name: benefit.modelData.icon
                                    size: 22
                                    color: Theme.royal600
                                }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                Controls.PText {
                                    ts: Theme.cardLine
                                    text: benefit.modelData.title
                                }
                                Controls.PText {
                                    ts: Theme.bodyS
                                    color: Theme.textSecondary
                                    text: benefit.modelData.text
                                }
                            }
                        }
                    }
                }
            }

            // ---------- Categories ----------
            Item {
                width: parent.width
                height: 72 + catHeader.height + 40 + 400 + 24
                Item {
                    id: catHeader
                    y: 72
                    width: Theme.contentWidth
                    height: catTitles.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    Column {
                        id: catTitles
                        width: 620
                        spacing: 10
                        Controls.PText {
                            ts: Theme.overline
                            color: Theme.accent
                            text: "Shop by category"
                        }
                        Controls.PText {
                            width: parent.width
                            ts: Theme.h1
                            wrapMode: Text.WordWrap
                            text: "Everything you need, thoughtfully curated"
                        }
                    }
                    Controls.PText {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        width: 420
                        ts: Theme.body
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                        text: "From prescription medicines to clinical skincare — every product is sourced from authorised distributors and checked by our pharmacists."
                    }
                }
                Row {
                    anchors.top: catHeader.bottom
                    anchors.topMargin: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 24
                    Repeater {
                        model: home.categoryModel
                        delegate: Controls.CategoryCard {
                            id: categoryDelegate
                            required property var modelData
                            name: modelData.name
                            title: modelData.title
                            description: modelData.text
                            image: modelData.image
                            count: modelData.count
                            onClicked: App.go("shop", { category: categoryDelegate.modelData.name })
                        }
                    }
                }
            }

            // ---------- Featured products ----------
            Item {
                width: parent.width
                height: 72 + featuredHeader.height + 36 + featuredGrid.height + 24
                Controls.SectionHeader {
                    id: featuredHeader
                    y: 72
                    anchors.horizontalCenter: parent.horizontalCenter
                    overline: "Curated for you"
                    title: "This week's essentials"
                    linkText: "View all"
                    onLinkClicked: App.go("shop")
                }
                Grid {
                    id: featuredGrid
                    anchors.top: featuredHeader.bottom
                    anchors.topMargin: 36
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: 4
                    columnSpacing: 24
                    rowSpacing: 28
                    Repeater {
                        model: App.featuredProducts(8)
                        delegate: Controls.ProductCard {
                            required property var modelData
                            product: modelData
                        }
                    }
                }
            }

            // ---------- Promo banner (real promo code WELLNESS15) ----------
            Item {
                width: parent.width
                height: 72 + 440 + 24
                Item {
                    y: 72
                    width: Theme.contentWidth
                    height: 440
                    anchors.horizontalCenter: parent.horizontalCenter
                    Controls.Rounded {
                        anchors.fill: parent
                        radius: Theme.rBanner
                        Controls.GradientFill {
                            anchors.fill: parent
                            direction: "diagonal"
                            colors: Theme.gradAnnouncement
                        }
                        Image {
                            x: 580
                            width: 700
                            height: 440
                            source: Theme.res + "images/promo_banner.png"
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true
                            mipmap: true
                        }
                        Rectangle {
                            x: 560
                            width: 420
                            height: 440
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Theme.royal800 }
                                GradientStop { position: 1.0; color: Theme.alpha(Theme.royal800, 0) }
                            }
                        }
                        Controls.Glow { x: -100; y: 200; width: 420; height: 420; color: Theme.alpha(Theme.azure500, 0.4); blurRadius: 140 }
                    }
                    Column {
                        x: 64
                        width: 520
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 22
                        Rectangle {
                            width: promoChip.implicitWidth + 28
                            height: 29
                            radius: height / 2
                            color: Theme.alpha(Theme.white, 0.1)
                            border.width: Theme.borderThin
                            border.color: Theme.alpha(Theme.white, 0.2)
                            Row {
                                id: promoChip
                                anchors.centerIn: parent
                                spacing: 8
                                Controls.Icon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: "tag"
                                    size: 14
                                    color: Theme.azure300
                                }
                                Controls.PText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    ts: Theme.chip
                                    color: Theme.white
                                    text: "Promo code · WELLNESS15"
                                }
                            }
                        }
                        Controls.PText {
                            width: 520
                            ts: Theme.promoTitle
                            color: Theme.white
                            wrapMode: Text.WordWrap
                            textFormat: Text.StyledText
                            text: "Immunity essentials, <font color=\"" + Theme.azure300 + "\"><i>15% off</i></font>."
                        }
                        Controls.PText {
                            width: 470
                            ts: Theme.body
                            color: Theme.alpha(Theme.white, 0.7)
                            wrapMode: Text.WordWrap
                            text: "Vitamin C, omega-3 and daily multivitamins — enter WELLNESS15 at checkout for 15% off your whole order."
                        }
                        Controls.PcButton {
                            height: 50
                            horizontalPadding: 26
                            variant: "secondary"
                            text: "Shop the edit"
                            iconName: "arrowR"
                            onClicked: App.go("shop", { category: "Vitamins & Supplements" })
                        }
                    }
                }
            }

            // ---------- Trusted brands (the brands in our catalogue) ----------
            Item {
                width: parent.width
                height: 72 + 16 + 28 + 84 + 96
                Controls.PText {
                    y: 72
                    anchors.horizontalCenter: parent.horizontalCenter
                    ts: Theme.overline
                    color: Theme.textSecondary
                    text: "Trusted healthcare & beauty brands"
                }
                Row {
                    id: brandRow
                    y: 72 + 16 + 28
                    width: Theme.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: (width - 6 * 196) / 5
                    Repeater {
                        model: [
                            { name: "Lumière Labs", style: Theme.brandLumiere, italic: true },
                            { name: "Nordic Vita", style: Theme.brandNordic, italic: false },
                            { name: "Derma·IQ", style: Theme.brandDerma, italic: false },
                            { name: "Aqualis", style: Theme.brandAqualis, italic: false },
                            { name: "Medix", style: Theme.brandMedix, italic: false },
                            { name: "SafeHands", style: Theme.brandSafeHands, italic: false }
                        ]
                        delegate: Rectangle {
                            id: brandTile
                            required property var modelData
                            width: 196
                            height: 84
                            radius: Theme.rPanel
                            color: Theme.white
                            border.width: Theme.borderThin
                            border.color: Theme.borderHairline
                            Controls.PText {
                                anchors.centerIn: parent
                                ts: brandTile.modelData.style
                                font.italic: brandTile.modelData.italic
                                color: Theme.textMuted
                                text: brandTile.modelData.name
                            }
                        }
                    }
                }
            }
        }
    }
