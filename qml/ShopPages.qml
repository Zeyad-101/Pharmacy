// El file da fih safa7at el tasawok: el Home, el Shop (categories / search / sort), safhet el product, el Quick View, wel search suggestions.
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Controls.Basic as Basic

QtObject {

    // ===================== HOME =====================
    component HomePage: Item {
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

            // ---------- Why PharmaCare ----------
            Item {
                width: parent.width
                height: 96 + 620 + 24
                Row {
                    y: 96
                    width: Theme.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 72
                    Item {
                        width: 560
                        height: 620
                        Controls.RoundedImage {
                            width: 520
                            height: 600
                            anchors.verticalCenter: parent.verticalCenter
                            radius: Theme.rBanner
                            source: Theme.res + "images/pharmacist.png"
                        }
                    }
                    Column {
                        width: 620
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 24
                        Controls.PText {
                            ts: Theme.overline
                            color: Theme.accent
                            text: "Why PharmaCare"
                        }
                        Controls.PText {
                            width: 600
                            ts: Theme.whyTitle
                            wrapMode: Text.WordWrap
                            text: "Your health, in expert and caring hands."
                        }
                        Controls.PText {
                            width: 580
                            ts: Theme.bodyL
                            color: Theme.textBody
                            wrapMode: Text.WordWrap
                            text: "We combine the rigour of a clinical pharmacy with the experience of a luxury boutique — so every order is safe, considered and beautifully delivered."
                        }
                        Row {
                            spacing: 20
                            Repeater {
                                model: [
                                    { icon: "award", title: "100% authentic", text: "Sourced only from authorised distributors and manufacturers." },
                                    { icon: "rx", title: "Prescriptions made easy", text: "Prescription medicines are confirmed with you before every order." }
                                ]
                                delegate: Rectangle {
                                    id: feature
                                    required property var modelData
                                    width: 300
                                    height: 175
                                    radius: Theme.rCard
                                    color: Theme.surfaceTint
                                    Column {
                                        x: 22
                                        y: 22
                                        width: parent.width - 44
                                        spacing: 10
                                        Rectangle {
                                            width: 44
                                            height: 44
                                            radius: Theme.rThumb
                                            color: Theme.white
                                            Controls.Icon {
                                                anchors.centerIn: parent
                                                name: feature.modelData.icon
                                                size: 22
                                                color: Theme.royal600
                                            }
                                        }
                                        Controls.PText {
                                            ts: Theme.cardLine
                                            text: feature.modelData.title
                                        }
                                        Controls.PText {
                                            width: parent.width
                                            ts: Theme.bodyS
                                            color: Theme.textSecondary
                                            wrapMode: Text.WordWrap
                                            text: feature.modelData.text
                                        }
                                    }
                                }
                            }
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

    // ===================== SHOP (all / category / search) =====================
    component ShopPage: Item {
        id: shop
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: shopColumn.height

        readonly property string category: App.pageParams.category !== undefined ? App.pageParams.category : ""
        readonly property string search: App.pageParams.search !== undefined ? App.pageParams.search : ""
        property string sort: "featured"
        property var selectedBrands: []
        property bool inStockOnly: false

        readonly property var result: App.products(category, search, sort, selectedBrands, inStockOnly)
        readonly property var brandList: App.brands(category, search)
        readonly property var categoryList: App.categories()

        readonly property var subtitles: ({
            "": "Pharmacist-curated medicines, clinical skincare, supplements and medical essentials — all authentic.",
            "Medicines": "Trusted pain relief, allergy, cold & flu care and prescription medicines — dispensed by licensed pharmacists.",
            "Skincare": "Dermatologist-backed serums, cleansers and barrier creams for calm, healthy, luminous skin.",
            "Vitamins & Supplements": "Clinically dosed daily essentials for immunity, energy, beauty and long-term wellbeing.",
            "First Aid & Medical Supplies": "Professional kits, home-care devices and soothing essentials for every household."
        })
        readonly property var sortLabels: ({ "featured": "Featured", "priceAsc": "Price: Low to High", "priceDesc": "Price: High to Low" })

        // Delegate models: each row carries what it shows, plus "owner" for its action
        readonly property var tabModel: categoryList.map((c) => ({
            name: c.name,
            count: c.count,
            selected: search === "" && category === c.name
        }))
        readonly property var brandModel: brandList.map((b) => ({
            name: b.name,
            count: b.count,
            checked: selectedBrands.indexOf(b.name) !== -1,
            owner: shop
        }))
        readonly property var sortModel: ["featured", "priceAsc", "priceDesc"].map((key) => ({
            key: key,
            label: sortLabels[key],
            selected: sort === key,
            owner: shop
        }))

        function selectSort(key: string) {
            sort = key
            sortMenu.close()
        }

        Connections {
            target: App
            function onPageChanged() {
                shop.clearFilters()
            }
        }

        function toggleBrand(name: string) {
            const list = selectedBrands.slice()
            const index = list.indexOf(name)
            if (index === -1)
                list.push(name)
            else
                list.splice(index, 1)
            selectedBrands = list
        }
        function clearFilters() {
            selectedBrands = []
            inStockOnly = false
            sort = "featured"
        }

        Column {
            id: shopColumn
            width: parent.width

            // ---------- Page head ----------
            Item {
                width: parent.width
                height: 40 + headTitles.height + 36
                Controls.GradientFill {
                    anchors.fill: parent
                    direction: "vertical"
                    colors: Theme.gradPageHead
                }
                Item {
                    y: 40
                    width: Theme.contentWidth
                    height: headTitles.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    Column {
                        id: headTitles
                        width: 560
                        spacing: 12
                        Controls.Breadcrumb {
                            crumbs: [{ label: "Home", page: "home", params: {} }, { label: "Shop", page: "shop", params: {} }]
                            current: shop.search !== "" ? "Search: “" + shop.search + "”"
                                   : shop.category !== "" ? shop.category : "All Products"
                        }
                        Controls.PText {
                            width: parent.width
                            ts: Theme.pageTitle
                            wrapMode: Text.WordWrap
                            text: shop.search !== "" ? "Results for “" + shop.search + "”"
                                : shop.category !== "" ? shop.category : "Shop all products"
                        }
                        Controls.PText {
                            width: parent.width
                            ts: Theme.body
                            color: Theme.textSecondary
                            wrapMode: Text.WordWrap
                            text: shop.search !== ""
                                  ? shop.result.total + (shop.result.total === 1 ? " product found." : " products found.")
                                  : (shop.subtitles[shop.category] !== undefined ? shop.subtitles[shop.category] : "")
                        }
                    }
                    Controls.SearchBar {
                        id: withinSearch
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        width: 380
                        height: 52
                        placeholder: "Search within products…"
                        onSubmitted: (value) => {
                            if (value.trim() !== "")
                                App.go("shop", { search: value.trim() })
                        }
                    }
                }
            }

            // ---------- Category tabs ----------
            Item {
                width: parent.width
                height: 41 + 28
                Row {
                    width: Theme.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    Controls.CategoryTab {
                        text: "All Products"
                        count: App.allProductsCount()
                        selected: shop.category === "" && shop.search === ""
                        onClicked: App.go("shop")
                    }
                    Repeater {
                        model: shop.tabModel
                        delegate: Controls.CategoryTab {
                            id: tabDelegate
                            required property var modelData
                            text: modelData.name
                            count: modelData.count
                            selected: modelData.selected
                            onClicked: App.go("shop", { category: tabDelegate.modelData.name })
                        }
                    }
                }
            }

            // ---------- Body: sidebar + results ----------
            Item {
                width: parent.width
                height: 8 + Math.max(sidebar.height, results.height) + 80
                Row {
                    y: 8
                    width: Theme.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 40

                    // Sidebar filters
                    Rectangle {
                        id: sidebar
                        width: 280
                        height: sidebarColumn.height + 48
                        radius: Theme.rSidebar
                        color: Theme.white
                        border.width: Theme.borderThin
                        border.color: Theme.borderHairline
                        Column {
                            id: sidebarColumn
                            x: 24
                            y: 24
                            width: parent.width - 48
                            Item {
                                width: parent.width
                                height: 25 + 18
                                Row {
                                    spacing: 8
                                    Controls.Icon {
                                        anchors.verticalCenter: parent.verticalCenter
                                        name: "sliders"
                                        size: 18
                                    }
                                    Controls.PText {
                                        ts: Theme.h4
                                        text: "Filters"
                                    }
                                }
                                Controls.TextLink {
                                    anchors.right: parent.right
                                    y: 4
                                    text: "Clear all"
                                    onClicked: shop.clearFilters()
                                }
                            }
                            // Brand
                            Controls.FilterGroup {
                                visible: shop.brandList.length > 0
                                width: parent.width
                                title: "Brand"
                                Repeater {
                                    model: shop.brandModel
                                    delegate: Controls.FilterCheckbox {
                                        id: brandBox
                                        required property var modelData
                                        width: 232
                                        text: modelData.name
                                        countText: modelData.count
                                        checked: modelData.checked
                                        onToggled: brandBox.modelData.owner.toggleBrand(brandBox.modelData.name)
                                    }
                                }
                            }
                            // Availability
                            Controls.FilterGroup {
                                width: parent.width
                                title: "Availability"
                                Controls.FilterCheckbox {
                                    width: 232
                                    text: "In stock"
                                    countText: shop.result.inStockCount
                                    checked: shop.inStockOnly
                                    onToggled: shop.inStockOnly = !shop.inStockOnly
                                }
                            }
                        }
                    }

                    // Results
                    Column {
                        id: results
                        width: 960
                        spacing: 24
                        Item {
                            width: parent.width
                            height: 44
                            Controls.PText {
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.label
                                color: Theme.textBody
                                text: "Showing " + shop.result.count + " of " + shop.result.total
                                      + (shop.result.total === 1 ? " product" : " products")
                            }
                            Controls.SortTrigger {
                                id: sortTrigger
                                anchors.right: parent.right
                                value: shop.sortLabels[shop.sort]
                                open: sortMenu.opened
                                onClicked: sortMenu.opened ? sortMenu.close() : sortMenu.open()
                            }
                            // Sort menu (overlay under the trigger)
                            Basic.Popup {
                                id: sortMenu
                                x: sortTrigger.x
                                y: sortTrigger.y + sortTrigger.height + 6
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
                                    Repeater {
                                        model: shop.sortModel
                                        delegate: Controls.MenuOption {
                                            id: sortOption
                                            required property var modelData
                                            text: modelData.label
                                            selected: modelData.selected
                                            onClicked: sortOption.modelData.owner.selectSort(sortOption.modelData.key)
                                        }
                                    }
                                }
                            }
                        }
                        Grid {
                            visible: shop.result.count > 0
                            columns: 3
                            columnSpacing: 27
                            rowSpacing: 28
                            Repeater {
                                model: shop.result.items
                                delegate: Controls.ProductCard {
                                    required property var modelData
                                    product: modelData
                                }
                            }
                        }
                        Controls.EmptyState {
                            visible: shop.result.count === 0
                            width: parent.width
                            iconName: "search"
                            title: "No products found"
                            message: shop.search !== ""
                                     ? "Nothing matches “" + shop.search + "”. Try another name or product code."
                                     : "No products match these filters."
                            actionText: shop.search !== "" ? "Show all products" : "Clear filters"
                            onAction: {
                                if (shop.search !== "")
                                    App.go("shop")
                                else
                                    shop.clearFilters()
                            }
                        }
                    }
                }
            }
        }
    }

    // ===================== PRODUCT DETAILS =====================
    component ProductPage: Item {
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
                    Controls.Breadcrumb {
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
                        // Buy row
                        Row {
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
                        Controls.SpecTable {
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

    // ===================== QUICK VIEW (overlay) =====================
    component QuickView: Item {
        id: quickView
        property string productId: ""
        readonly property var product: App.product(productId)
        readonly property bool found: product.ok === true
        readonly property bool rx: found && product.requiresPrescription === true
        property int quantity: 1
        signal closeRequested()

        implicitWidth: 960
        implicitHeight: 560
        onProductIdChanged: quantity = 1

        Controls.ModalFrame {
            anchors.fill: parent
        }
        Controls.RoundedImage {
            width: 460
            height: 560
            radius: Theme.rModal
            leftOnly: true
            source: quickView.found ? quickView.product.image : ""
        }
        Controls.ProductBadge {
            x: 20
            y: 20
            product: quickView.product
        }
        Item {
            x: 460
            width: 500
            height: 560
            Item {
                id: qvTop
                x: 40
                y: 40
                width: 420
                height: 40
                Controls.PText {
                    anchors.verticalCenter: parent.verticalCenter
                    ts: Theme.overline
                    color: Theme.accent
                    text: quickView.found ? quickView.product.brand : ""
                }
                Controls.IconButton {
                    anchors.right: parent.right
                    iconName: "x"
                    onClicked: quickView.closeRequested()
                }
            }
            Column {
                anchors.top: qvTop.bottom
                anchors.topMargin: 16
                x: 40
                width: 420
                spacing: 16
                Controls.PText {
                    width: parent.width
                    ts: Theme.quickViewTitle
                    wrapMode: Text.WordWrap
                    text: quickView.found ? quickView.product.name : ""
                }
                Controls.PText {
                    ts: Theme.quickViewPrice
                    text: quickView.found ? quickView.product.priceText : ""
                }
                Controls.PText {
                    width: parent.width
                    ts: Theme.bodyS
                    color: Theme.textBody
                    wrapMode: Text.WordWrap
                    text: quickView.found ? quickView.product.description : ""
                }
                Row {
                    visible: quickView.rx || (quickView.found && quickView.product.inStock !== true)
                    spacing: 8
                    Controls.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: quickView.rx ? "rx" : "info"
                        size: 16
                        color: quickView.rx ? Theme.royal600 : Theme.error
                    }
                    Controls.PText {
                        ts: Theme.link
                        color: quickView.rx ? Theme.textPrimary : Theme.error
                        text: quickView.rx ? "Prescription required at checkout"
                                           : (quickView.product.expired === true ? "Expired · not available to order" : "Out of stock")
                    }
                }
            }
            Column {
                x: 40
                width: 420
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 36
                spacing: 16
                Row {
                    spacing: 12
                    Controls.QuantitySelector {
                        value: quickView.quantity
                        maximum: quickView.found ? Math.max(1, quickView.product.stock) : 1
                        enabled: quickView.found && quickView.product.inStock === true
                        onStepped: (newValue) => quickView.quantity = newValue
                    }
                    Controls.PcButton {
                        width: 420 - 136 - 12
                        text: "Add to Cart"
                        iconName: "bag"
                        iconFirst: true
                        enabled: quickView.found && quickView.product.inStock === true
                        onClicked: {
                            const result = App.addToCart(quickView.productId, quickView.quantity)
                            if (result.ok) {
                                quickView.closeRequested()
                                App.openCartDrawer()
                            } else {
                                App.showToast("error", "Could not add to bag", result.message)
                            }
                        }
                    }
                }
                Controls.TextLink {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.textPrimary
                    iconName: "arrowR"
                    iconAfter: true
                    iconSize: 15
                    spacing: 8
                    text: "View full product details"
                    onClicked: {
                        quickView.closeRequested()
                        App.go("product", { id: quickView.productId })
                    }
                }
            }
        }
    }

    // ===================== SEARCH SUGGESTIONS (overlay under the header search) =====================
    component SearchSuggestions: Item {
        id: suggestions
        property string term: ""
        readonly property var result: App.searchSuggestions(term, 3)
        readonly property var allMatches: App.searchSuggestions(term, 100)
        signal closeRequested()

        // The categories that contain matches become the suggestion rows ("vitamin — in Skincare")
        readonly property var categoryRows: {
            const names = []
            const items = allMatches.items
            for (let i = 0; i < items.length && names.length < 3; ++i) {
                if (names.indexOf(items[i].category) === -1)
                    names.push(items[i].category)
            }
            return names.map((name) => ({ category: name, term: term }))
        }

        implicitWidth: 560
        implicitHeight: content.height + 48

        Controls.ShadowRect {
            anchors.fill: parent
            radius: Theme.rSidebar
            color: Theme.white
            border.width: Theme.borderThin
            border.color: Theme.borderHairline
            elevation: "lg"
        }
        Column {
            id: content
            x: 24
            y: 24
            width: parent.width - 48
            spacing: 18

            Controls.PText {
                visible: suggestions.result.total === 0
                width: parent.width
                ts: Theme.bodyS
                color: Theme.textSecondary
                wrapMode: Text.WordWrap
                text: "No products match “" + suggestions.term + "”. Try a product name or code."
            }

            Controls.PText {
                visible: suggestions.categoryRows.length > 0
                ts: Theme.tinyOverline
                color: Theme.textMuted
                text: "Suggestions"
            }
            Column {
                visible: suggestions.categoryRows.length > 0
                width: parent.width
                spacing: 2
                Repeater {
                    model: suggestions.categoryRows
                    delegate: Rectangle {
                        id: suggestionRow
                        required property var modelData
                        required property int index
                        width: parent ? parent.width : 0
                        height: 39
                        radius: Theme.rTile
                        color: index === 0 || rowHover.hovered ? Theme.surfaceTint : "transparent"
                        Controls.Icon {
                            id: rowIcon
                            x: 12
                            anchors.verticalCenter: parent.verticalCenter
                            name: "search"
                            size: 16
                            color: Theme.textMuted
                        }
                        Row {
                            anchors.left: rowIcon.right
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12
                            Controls.PText {
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.label
                                text: suggestionRow.modelData.term
                            }
                            Controls.PText {
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.meta12
                                color: Theme.textMuted
                                text: "in " + suggestionRow.modelData.category
                            }
                        }
                        Controls.Icon {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            name: "arrowUR"
                            size: 14
                            color: Theme.midnight300
                        }
                        HoverHandler {
                            id: rowHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: App.go("shop", { search: suggestionRow.modelData.term, category: suggestionRow.modelData.category })
                        }
                    }
                }
            }

            Controls.PText {
                visible: suggestions.result.total > 0
                ts: Theme.tinyOverline
                color: Theme.textMuted
                text: "Products"
            }
            Row {
                visible: suggestions.result.total > 0
                spacing: 12
                Repeater {
                    model: suggestions.result.items
                    delegate: Rectangle {
                        id: match
                        required property var modelData
                        width: 162
                        height: 183
                        radius: Theme.rMenu
                        color: matchHover.hovered ? Theme.surfaceTint : Theme.white
                        border.width: Theme.borderThin
                        border.color: Theme.borderHairline
                        Column {
                            x: 10
                            y: 10
                            width: parent.width - 20
                            spacing: 8
                            Controls.RoundedImage {
                                width: parent.width
                                height: 96
                                radius: Theme.rMenuItem
                                source: match.modelData.image
                            }
                            Controls.PText {
                                width: parent.width
                                height: 34
                                ts: Theme.chip
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignTop
                                text: match.modelData.name
                            }
                            Controls.PText {
                                ts: Theme.countBadge
                                color: Theme.textPrimary
                                text: match.modelData.priceText
                            }
                        }
                        HoverHandler {
                            id: matchHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: App.go("product", { id: match.modelData.id })
                        }
                    }
                }
            }

            Rectangle {
                visible: suggestions.result.total > 0
                width: parent.width
                height: 48
                radius: Theme.rInput
                color: seeAllHover.hovered ? Theme.royal600 : Theme.midnight900
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Controls.PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.link
                        color: Theme.white
                        text: "See all " + suggestions.result.total + (suggestions.result.total === 1 ? " result" : " results")
                              + " for “" + suggestions.term + "”"
                    }
                    Controls.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "arrowR"
                        size: 15
                        color: Theme.white
                    }
                }
                HoverHandler {
                    id: seeAllHover
                    cursorShape: Qt.PointingHandCursor
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        suggestions.closeRequested()
                        App.go("shop", { search: suggestions.term })
                    }
                }
            }
        }
    }
}
