// El file da fih kol el components el mota3adda (zay el Components Library fel Penpot): buttons, inputs, badges, cards, header, footer.
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Effects
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

QtObject {

    // ===================== Text =====================
    // Every text uses a Theme style object: family, size, weight, line height, letter spacing, caps
    component PText: Text {
        property var ts: Theme.body
        font.family: ts.family
        font.pixelSize: ts.size
        font.weight: ts.weight
        font.letterSpacing: ts.ls
        font.capitalization: ts.caps ? Font.AllUppercase : Font.MixedCase
        lineHeightMode: Text.FixedHeight
        lineHeight: Math.round(ts.size * ts.lh)
        // The box is exactly lines x line height (like Penpot / CSS); the glyphs are centred in it
        height: Math.max(1, lineCount) * Math.round(ts.size * ts.lh)
        color: Theme.textPrimary
        verticalAlignment: Text.AlignVCenter
    }

    // ===================== Icon =====================
    // One of the 54 SVG icons, recoloured exactly by the C++ side
    component Icon: Image {
        property string name: ""
        property color color: Theme.textPrimary
        property int size: 24
        width: size
        height: size
        sourceSize: Qt.size(size * 2, size * 2)
        fillMode: Image.PreserveAspectFit
        smooth: true
        source: name === "" ? "" : App.iconSource(name, color)
    }

    // ===================== Surfaces =====================
    // A rectangle with one of the design shadows (sm, md, lg, glow); "" = no shadow.
    // The shape is drawn by the MultiEffect (shape + shadow); children are drawn on top.
    component ShadowRect: Item {
        id: shadowRect
        property string elevation: ""
        property alias color: shape.color
        property alias radius: shape.radius
        property alias border: shape.border
        readonly property var shadowSpec: Theme.shadow(elevation)
        readonly property bool hasShadow: shadowSpec !== null

        Rectangle {
            id: shape
            anchors.fill: parent
            antialiasing: true
            visible: !shadowRect.hasShadow
            layer.enabled: shadowRect.hasShadow
        }
        MultiEffect {
            visible: shadowRect.hasShadow
            anchors.fill: shape
            source: shape
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: shadowRect.hasShadow ? shadowRect.shadowSpec.color : "transparent"
            shadowHorizontalOffset: shadowRect.hasShadow ? shadowRect.shadowSpec.x : 0
            shadowVerticalOffset: shadowRect.hasShadow ? shadowRect.shadowSpec.y : 0
            blurMax: shadowRect.hasShadow ? Math.max(1, shadowRect.shadowSpec.blur) : 1
            shadowBlur: 1.0
            shadowScale: shadowRect.hasShadow && shadowRect.width > 0
                         ? (shadowRect.width + 2 * shadowRect.shadowSpec.spread) / shadowRect.width : 1.0
        }
    }

    // Clips its visual children to a rounded rectangle (optionally only the top corners)
    component Rounded: Item {
        id: rounded
        property real radius: 0
        property bool topOnly: false
        property bool leftOnly: false
        default property alias content: holder.data

        Item {
            id: holder
            anchors.fill: parent
            layer.enabled: true
            visible: false
        }
        Item {
            id: maskShape
            anchors.fill: parent
            layer.enabled: true
            layer.smooth: true
            visible: false
            Rectangle {
                anchors.fill: parent
                radius: rounded.radius
                antialiasing: true
            }
            Rectangle {
                visible: rounded.topOnly
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height / 2
            }
            Rectangle {
                visible: rounded.leftOnly
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: parent.width / 2
            }
        }
        MultiEffect {
            anchors.fill: parent
            source: holder
            maskEnabled: true
            maskSource: maskShape
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }
    }

    // A linear gradient with the exact Penpot geometry: "horizontal", "vertical" or "diagonal" (0,0 -> 1,1)
    component GradientFill: Item {
        id: gradientFill
        property var colors: Theme.gradDarkCard
        property real midPosition: 0.5
        property string direction: "diagonal"
        property real radius: 0

        readonly property color c0: colors[0]
        readonly property color c1: colors[1]
        readonly property color c2: colors.length > 2 ? colors[2] : colors[1]
        readonly property real p1: colors.length > 2 ? midPosition : 1.0

        Rectangle {
            visible: gradientFill.direction !== "diagonal"
            anchors.fill: parent
            radius: gradientFill.radius
            antialiasing: true
            gradient: Gradient {
                orientation: gradientFill.direction === "horizontal" ? Gradient.Horizontal : Gradient.Vertical
                GradientStop { position: 0.0; color: gradientFill.c0 }
                GradientStop { position: gradientFill.p1; color: gradientFill.c1 }
                GradientStop { position: 1.0; color: gradientFill.c2 }
            }
        }
        Rounded {
            visible: gradientFill.direction === "diagonal"
            anchors.fill: parent
            radius: gradientFill.radius
            Item {
                anchors.fill: parent
                clip: true
                Rectangle {
                    // s = (x/w + y/h) / 2 goes from 0 (top-left) to 1 (bottom-right)
                    readonly property real w: gradientFill.width
                    readonly property real h: gradientFill.height
                    width: w > 0 && h > 0 ? 2 * w * h / Math.sqrt(w * w + h * h) : 0
                    height: w + h
                    anchors.centerIn: parent
                    rotation: Math.atan2(w, h) * 180 / Math.PI
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: gradientFill.c0 }
                        GradientStop { position: gradientFill.p1; color: gradientFill.c1 }
                        GradientStop { position: 1.0; color: gradientFill.c2 }
                    }
                }
            }
        }
    }

    // An image that covers its box, clipped to a radius, with an optional zoom (hover)
    component RoundedImage: Item {
        id: roundedImage
        property string source: ""
        property real radius: 0
        property bool topOnly: false
        property bool leftOnly: false
        property real zoom: 1.0
        property color placeholderColor: Theme.surfaceTint
        property string placeholderIcon: "pill"

        Rounded {
            anchors.fill: parent
            radius: roundedImage.radius
            topOnly: roundedImage.topOnly
            leftOnly: roundedImage.leftOnly
            Rectangle {
                anchors.fill: parent
                color: roundedImage.placeholderColor
            }
            Image {
                anchors.fill: parent
                source: roundedImage.source
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                mipmap: true
                scale: roundedImage.zoom
                Behavior on scale { NumberAnimation { duration: Theme.hoverDuration * 2; easing.type: Easing.OutCubic } }
            }
        }
        // Neutral placeholder when the product has no image file
        Icon {
            visible: roundedImage.source === ""
            anchors.centerIn: parent
            name: roundedImage.placeholderIcon
            color: Theme.midnight300
            size: Math.max(24, Math.min(roundedImage.width, roundedImage.height) / 5)
        }
    }

    // A soft blurred glow (the decorative ellipses with layer blur in the design)
    component Glow: Item {
        id: glow
        property color color: Theme.azure300
        property real blurRadius: 120
        Rectangle {
            id: glowShape
            anchors.fill: parent
            radius: Math.min(width, height) / 2
            color: glow.color
            visible: false
            layer.enabled: true
        }
        MultiEffect {
            anchors.fill: glowShape
            source: glowShape
            autoPaddingEnabled: true
            blurEnabled: true
            blur: 1.0
            blurMax: 64
            // Penpot's layer blur spreads like a CSS blur (about 2.5x its value in pixels)
            blurMultiplier: Math.max(0, glow.blurRadius * 2.5 / 64 - 1)
        }
    }

    // A filter group in the shop sidebar: divider, title with chevron, then its options
    component FilterGroup: Item {
        id: filterGroup
        property string title: ""
        default property alias content: groupItems.data
        height: 1 + 20 + 23 + 14 + groupItems.height + 20

        Divider {
            width: parent.width
        }
        PText {
            y: 21
            ts: Theme.cardLine
            text: filterGroup.title
        }
        Icon {
            y: 24.5
            anchors.right: parent.right
            name: "chevU"
            size: 16
            color: Theme.midnight500
        }
        Column {
            id: groupItems
            y: 21 + 23 + 14
            width: parent.width
            spacing: 14
        }
    }

    // Empty state (no results, empty bag …): built from the design system (sky 50 card, Fraunces title)
    component EmptyState: Rectangle {
        id: emptyState
        property string iconName: "info"
        property string title: ""
        property string message: ""
        property string actionText: ""
        signal action()

        height: emptyColumn.height + 96
        radius: Theme.rSidebar
        color: Theme.surfaceTint

        Column {
            id: emptyColumn
            width: Math.min(parent.width - 64, 520)
            anchors.centerIn: parent
            spacing: 16
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 52
                height: 52
                radius: Theme.rMenu
                color: Theme.white
                Icon {
                    anchors.centerIn: parent
                    name: emptyState.iconName
                    size: 22
                    color: Theme.royal600
                }
            }
            PText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                ts: Theme.cardTitle
                text: emptyState.title
            }
            PText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                ts: Theme.body
                color: Theme.textSecondary
                wrapMode: Text.WordWrap
                text: emptyState.message
            }
            PcButton {
                visible: emptyState.actionText !== ""
                anchors.horizontalCenter: parent.horizontalCenter
                variant: "secondary"
                text: emptyState.actionText
                onClicked: emptyState.action()
            }
        }
    }

    // A 1 px divider
    component Divider: Rectangle {
        height: 1
        color: Theme.borderHairline
    }

    // ===================== Brand =====================
    // Logo: gradient mark with the white cross + "Pharma" (Fraunces 500) "Care" (Fraunces 400 italic)
    component Logo: Row {
        id: logo
        property bool dark: false
        spacing: 10
        height: 38

        Item {
            width: 38
            height: 38
            GradientFill {
                anchors.fill: parent
                radius: Theme.rTile
                direction: "diagonal"
                colors: logo.dark ? Theme.gradLogoDark : Theme.gradLogoLight
            }
            // The rounded plus (15 x 15, bars 6 px) centred in a 20 x 20 box
            Rectangle {
                width: 6
                height: 15
                radius: Theme.rCross
                anchors.centerIn: parent
                color: logo.dark ? Theme.midnight900 : Theme.white
            }
            Rectangle {
                width: 15
                height: 6
                radius: Theme.rCross
                anchors.centerIn: parent
                color: logo.dark ? Theme.midnight900 : Theme.white
            }
        }
        Row {
            anchors.verticalCenter: parent.verticalCenter
            PText {
                ts: Theme.wordmark
                color: logo.dark ? Theme.white : Theme.textPrimary
                text: "Pharma"
            }
            PText {
                ts: Theme.wordmarkItalic
                font.italic: true
                color: logo.dark ? Theme.azure300 : Theme.royal600
                text: "Care"
            }
        }
    }

    // ===================== Buttons =====================
    // Button: "primary" (dark pill) or "secondary" (white outline); default / hover / disabled
    component PcButton: Item {
        id: button
        property string text: ""
        property string variant: "primary"
        property string iconName: ""
        property bool iconFirst: false
        property int horizontalPadding: 28
        property var textStyle: Theme.button
        property int iconSize: 18
        property bool gradient: false
        signal clicked()

        readonly property bool hovered: buttonHover.hovered && enabled
        readonly property bool primary: variant === "primary"

        implicitWidth: buttonRow.implicitWidth + 2 * horizontalPadding
        implicitHeight: 52

        // Keyboard: Tab reaches the button (focus ring), Enter / Space press it
        activeFocusOnTab: enabled && visible
        Keys.onReturnPressed: if (enabled) button.clicked()
        Keys.onEnterPressed: if (enabled) button.clicked()
        Keys.onSpacePressed: if (enabled) button.clicked()

        Rectangle {
            visible: button.activeFocus
            anchors.fill: parent
            anchors.margins: -Theme.focusRingWidth
            radius: height / 2
            color: Theme.focusRing
        }
        ShadowRect {
            anchors.fill: parent
            radius: height / 2
            elevation: button.primary && (button.hovered || button.gradient) && button.enabled ? "glow" : ""
            color: !button.enabled ? (button.primary ? Theme.midnight200 : Theme.white)
                 : button.primary ? (button.hovered ? Theme.royal600 : Theme.midnight900)
                 : (button.hovered ? Theme.surfaceTint : Theme.white)
            border.width: button.primary ? 0 : Theme.borderThin
            border.color: !button.enabled ? Theme.borderHairline
                        : button.hovered ? Theme.royal600 : Theme.borderControl
            Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
        }
        GradientFill {
            visible: button.gradient && button.enabled
            anchors.fill: parent
            radius: height / 2
            direction: "horizontal"
            colors: Theme.gradRoyalGlow
        }
        Row {
            id: buttonRow
            anchors.centerIn: parent
            spacing: 10
            Icon {
                visible: button.iconName !== "" && button.iconFirst
                anchors.verticalCenter: parent.verticalCenter
                name: button.iconFirst ? button.iconName : ""
                size: button.iconSize
                color: buttonLabel.color
            }
            PText {
                id: buttonLabel
                anchors.verticalCenter: parent.verticalCenter
                ts: button.textStyle
                text: button.text
                color: !button.enabled ? (button.primary ? Theme.midnight400 : Theme.midnight300)
                     : button.primary ? Theme.white
                     : (button.hovered ? Theme.royal600 : Theme.textPrimary)
            }
            Icon {
                visible: button.iconName !== "" && !button.iconFirst
                anchors.verticalCenter: parent.verticalCenter
                name: button.iconFirst ? "" : button.iconName
                size: button.iconSize
                color: buttonLabel.color
            }
        }
        HoverHandler {
            id: buttonHover
            cursorShape: button.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
        MouseArea {
            anchors.fill: parent
            enabled: button.enabled
            onClicked: button.clicked()
        }
    }

    // A round icon-only button (close, quantity, explore …)
    component IconButton: Item {
        id: iconButton
        property string iconName: "x"
        property int iconSize: 18
        property color fill: Theme.surfaceTint
        property color hoverFill: Theme.sky100
        property color iconColor: Theme.textPrimary
        property color borderColor: Theme.borderHairline
        property bool outlined: false
        property string elevation: ""
        signal clicked()

        implicitWidth: 40
        implicitHeight: 40

        ShadowRect {
            anchors.fill: parent
            radius: width / 2
            elevation: iconButton.elevation
            color: iconHover.hovered && iconButton.enabled ? iconButton.hoverFill : iconButton.fill
            border.width: iconButton.outlined ? Theme.borderThin : 0
            border.color: iconButton.borderColor
            Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
        }
        Icon {
            anchors.centerIn: parent
            name: iconButton.iconName
            size: iconButton.iconSize
            color: iconButton.iconColor
            opacity: iconButton.enabled ? 1.0 : 0.4
        }
        HoverHandler {
            id: iconHover
            cursorShape: iconButton.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
        MouseArea {
            anchors.fill: parent
            enabled: iconButton.enabled
            onClicked: iconButton.clicked()
        }
    }

    // A text link with an optional icon ("Back to results", "Clear all" …)
    component TextLink: Row {
        id: textLink
        property string text: ""
        property string iconName: ""
        property bool iconAfter: false
        property color color: Theme.royal600
        property var textStyle: Theme.link
        property int iconSize: 16
        signal clicked()
        spacing: 6

        Icon {
            visible: textLink.iconName !== "" && !textLink.iconAfter
            anchors.verticalCenter: parent.verticalCenter
            name: textLink.iconAfter ? "" : textLink.iconName
            size: textLink.iconSize
            color: textLink.color
        }
        PText {
            anchors.verticalCenter: parent.verticalCenter
            ts: textLink.textStyle
            text: textLink.text
            color: textLink.color
            font.underline: linkHover.hovered
        }
        Icon {
            visible: textLink.iconName !== "" && textLink.iconAfter
            anchors.verticalCenter: parent.verticalCenter
            name: textLink.iconAfter ? textLink.iconName : ""
            size: textLink.iconSize
            color: textLink.color
        }
        HoverHandler {
            id: linkHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: textLink.clicked()
        }
    }

    // ===================== Commerce atoms =====================
    // Badge: "rx" (Rx required), "low" (Only N left), "out" (Out of stock)
    component Badge: Rectangle {
        id: badge
        property string type: "rx"
        property string text: ""
        height: 27
        width: badgeRow.implicitWidth + 20
        radius: height / 2
        color: type === "rx" ? Theme.midnight900 : Theme.errorBg

        Row {
            id: badgeRow
            anchors.centerIn: parent
            spacing: 5
            Icon {
                visible: badge.type === "rx"
                anchors.verticalCenter: parent.verticalCenter
                name: badge.type === "rx" ? "rx" : ""
                size: 12
                color: Theme.white
            }
            PText {
                anchors.verticalCenter: parent.verticalCenter
                ts: Theme.chip
                text: badge.text
                color: badge.type === "rx" ? Theme.white : Theme.error
            }
        }
    }

    // The badge a product should show (Rx first, then stock problems), or none
    component ProductBadge: Item {
        id: productBadge
        property var product: ({})
        readonly property string badgeType: product.requiresPrescription === true ? "rx"
                                          : product.inStock === false ? "out"
                                          : product.lowStock === true ? "low" : ""
        width: inner.width
        height: inner.height
        visible: badgeType !== ""
        Badge {
            id: inner
            type: productBadge.badgeType === "rx" ? "rx" : "low"
            text: productBadge.badgeType === "rx" ? "Rx required"
                : productBadge.badgeType === "out" ? (productBadge.product.expired === true ? "Expired" : "Out of stock")
                : "Only " + productBadge.product.stock + " left"
        }
    }

    // Quantity selector: "large" (136 x 52) or "small" (112 x 40)
    component QuantitySelector: Rectangle {
        id: quantity
        property int value: 1
        property int minimum: 1
        property int maximum: 99
        property bool large: true
        signal stepped(int newValue)

        width: large ? 136 : 112
        height: large ? 52 : 40
        radius: height / 2
        color: Theme.white
        border.width: Theme.borderThin
        border.color: Theme.borderControl

        Row {
            anchors.centerIn: parent
            spacing: 4
            IconButton {
                width: quantity.large ? 40 : 28
                height: width
                iconName: "minus"
                iconSize: 16
                enabled: quantity.value > quantity.minimum
                onClicked: quantity.stepped(quantity.value - 1)
            }
            PText {
                width: 36
                height: 23
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                ts: Theme.cardLine
                text: quantity.value
            }
            IconButton {
                width: quantity.large ? 40 : 28
                height: width
                iconName: "plus"
                iconSize: 16
                enabled: quantity.value < quantity.maximum
                onClicked: quantity.stepped(quantity.value + 1)
            }
        }
    }

    // ===================== Navigation atoms =====================
    // Category tab: default / hover / selected
    component CategoryTab: Rectangle {
        id: tab
        property string text: ""
        property int count: 0
        property bool selected: false
        signal clicked()
        readonly property bool hovered: tabHover.hovered && !selected

        height: 41
        width: tabRow.implicitWidth + 40
        radius: height / 2
        color: selected ? Theme.midnight900 : hovered ? Theme.surfaceTint : Theme.white
        border.width: selected ? 0 : Theme.borderThin
        border.color: hovered ? Theme.sky300 : Theme.borderControl
        Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }

        Row {
            id: tabRow
            anchors.centerIn: parent
            spacing: 8
            PText {
                anchors.verticalCenter: parent.verticalCenter
                ts: tab.selected ? Theme.labelStrong : Theme.label
                text: tab.text
                color: tab.selected ? Theme.white : tab.hovered ? Theme.royal700 : Theme.midnight700
            }
            PText {
                anchors.verticalCenter: parent.verticalCenter
                ts: Theme.caption
                text: tab.count
                color: tab.selected ? Theme.azure300 : Theme.textMuted
            }
        }
        HoverHandler {
            id: tabHover
            cursorShape: Qt.PointingHandCursor
        }
        MouseArea {
            anchors.fill: parent
            onClicked: tab.clicked()
        }
    }

    // Search bar: default / focused, with the round submit button
    component SearchBar: Item {
        id: searchBar
        property alias text: field.text
        property string placeholder: "Search medicines, skincare, vitamins…"
        readonly property bool focused: field.activeFocus
        signal submitted(string text)
        signal edited(string text)
        signal escaped()

        implicitWidth: 560
        implicitHeight: 52

        function clear() {
            field.text = ""
        }
        function focusField() {
            field.forceActiveFocus()
        }

        Rectangle {
            visible: searchBar.focused
            anchors.fill: parent
            anchors.margins: -Theme.focusRingWidth
            radius: height / 2
            color: Theme.focusRing
        }
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: searchBar.focused ? Theme.white : Theme.surfaceTint
            border.width: searchBar.focused ? Theme.borderFocus : Theme.borderThin
            border.color: searchBar.focused ? Theme.royal600 : Theme.borderHairline
        }
        Icon {
            id: searchIcon
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            name: "search"
            size: 20
            color: searchBar.focused ? Theme.royal600 : Theme.midnight500
        }
        Basic.TextField {
            id: field
            anchors.left: searchIcon.right
            anchors.leftMargin: 12
            anchors.right: submit.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            height: 40
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            verticalAlignment: TextInput.AlignVCenter
            font.family: Theme.body.family
            font.pixelSize: Theme.body.size
            font.weight: Theme.body.weight
            color: Theme.textPrimary
            placeholderText: searchBar.placeholder
            placeholderTextColor: Theme.textMuted
            selectByMouse: true
            selectionColor: Theme.sky300
            selectedTextColor: Theme.textPrimary
            background: Item {}
            onTextEdited: searchBar.edited(text)
            onAccepted: searchBar.submitted(text)
            Keys.onEscapePressed: searchBar.escaped()
        }
        IconButton {
            id: submit
            anchors.right: parent.right
            anchors.rightMargin: 7
            anchors.verticalCenter: parent.verticalCenter
            width: 38
            height: 38
            fill: Theme.midnight900
            hoverFill: Theme.royal600
            iconName: "arrowR"
            iconSize: 16
            iconColor: Theme.white
            onClicked: searchBar.submitted(field.text)
        }
    }

    // Sort dropdown trigger ("Sort by: Featured")
    component SortTrigger: Rectangle {
        id: sortTrigger
        property string value: "Featured"
        property bool open: false
        signal clicked()

        width: 240
        height: 44
        radius: height / 2
        color: Theme.white
        border.width: Theme.borderThin
        border.color: open ? Theme.royal600 : Theme.borderControl

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            PText {
                anchors.verticalCenter: parent.verticalCenter
                ts: Theme.small13Regular
                color: Theme.textSecondary
                text: "Sort by:"
            }
            PText {
                anchors.verticalCenter: parent.verticalCenter
                ts: Theme.link
                text: sortTrigger.value
            }
        }
        Icon {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            name: sortTrigger.open ? "chevU" : "chevD"
            size: 16
        }
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
        MouseArea {
            anchors.fill: parent
            onClicked: sortTrigger.clicked()
        }
    }

    // One option row in a menu (sort menu)
    component MenuOption: Rectangle {
        id: option
        property string text: ""
        property bool selected: false
        signal clicked()
        width: 224
        height: 40
        radius: Theme.rMenuItem
        color: selected || optionHover.hovered ? Theme.surfaceTint : "transparent"

        PText {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            ts: option.selected ? Theme.link : Theme.small13
            text: option.text
            color: option.selected ? Theme.royal700 : Theme.midnight700
        }
        Icon {
            visible: option.selected
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            name: "check"
            size: 16
            color: Theme.royal700
        }
        HoverHandler {
            id: optionHover
            cursorShape: Qt.PointingHandCursor
        }
        MouseArea {
            anchors.fill: parent
            onClicked: option.clicked()
        }
    }

    // Filter checkbox: unchecked / checked / disabled
    component FilterCheckbox: Item {
        id: checkbox
        property string text: ""
        property string countText: ""
        property bool checked: false
        signal toggled()

        implicitWidth: 232
        implicitHeight: 22

        Rectangle {
            id: box
            width: 20
            height: 20
            radius: Theme.rCheckbox
            anchors.verticalCenter: parent.verticalCenter
            color: checkbox.checked ? Theme.royal600 : Theme.white
            border.width: checkbox.checked ? 0 : Theme.borderThin
            border.color: checkbox.enabled ? Theme.midnight300 : Theme.borderHairline
            Icon {
                visible: checkbox.checked
                anchors.centerIn: parent
                name: "check"
                size: 14
                color: Theme.white
            }
        }
        PText {
            anchors.left: box.right
            anchors.leftMargin: 12
            anchors.right: count.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            ts: Theme.bodyS
            text: checkbox.text
            color: checkbox.enabled ? Theme.midnight800 : Theme.midnight300
            elide: Text.ElideRight
        }
        PText {
            id: count
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            ts: Theme.caption
            text: checkbox.countText
            color: checkbox.enabled ? Theme.textMuted : Theme.midnight300
        }
        HoverHandler {
            cursorShape: checkbox.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
        MouseArea {
            anchors.fill: parent
            enabled: checkbox.enabled
            onClicked: checkbox.toggled()
        }
    }

    // Breadcrumb: crumbs = [{ label, page, params }], then the current page label
    component Breadcrumb: Row {
        id: breadcrumb
        property var crumbs: []
        property string current: ""
        spacing: 8

        Repeater {
            model: breadcrumb.crumbs
            delegate: Row {
                id: crumbRow
                required property var modelData
                spacing: 8
                PText {
                    ts: Theme.small13
                    text: crumbRow.modelData.label
                    color: crumbHover.hovered ? Theme.royal600 : Theme.textSecondary
                    HoverHandler {
                        id: crumbHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: App.go(crumbRow.modelData.page, crumbRow.modelData.params)
                    }
                }
                PText {
                    ts: Theme.small13
                    text: "/"
                    color: Theme.midnight300
                }
            }
        }
        PText {
            ts: Theme.link
            text: breadcrumb.current
        }
    }

    // Section header: overline + Fraunces title, optional "View all" pill on the right
    component SectionHeader: Item {
        id: sectionHeader
        property string overline: ""
        property string title: ""
        property string linkText: ""
        signal linkClicked()

        implicitWidth: Theme.contentWidth
        implicitHeight: titles.height

        Column {
            id: titles
            spacing: 10
            PText {
                ts: Theme.overline
                color: Theme.accent
                text: sectionHeader.overline
            }
            PText {
                ts: Theme.h1
                text: sectionHeader.title
            }
        }
        PcButton {
            visible: sectionHeader.linkText !== ""
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            variant: "secondary"
            height: 41
            horizontalPadding: 20
            textStyle: Theme.link
            iconName: "arrowR"
            iconSize: 16
            text: sectionHeader.linkText
            onClicked: sectionHeader.linkClicked()
        }
    }

    // ===================== Cards =====================
    // Product card (302 wide): default / hover (lift, lg shadow, image zoom, "Quick view" pill)
    component ProductCard: Item {
        id: card
        property var product: ({})
        readonly property bool hovered: cardHover.hovered

        width: 302
        height: 300 + info.height

        HoverHandler {
            id: cardHover
        }
        ShadowRect {
            anchors.fill: parent
            radius: Theme.rCard
            color: Theme.white
            elevation: card.hovered ? "lg" : ""
        }
        // Media
        Item {
            id: media
            width: parent.width
            height: 300
            RoundedImage {
                anchors.fill: parent
                radius: Theme.rCard
                topOnly: true
                source: card.product.image !== undefined ? card.product.image : ""
                zoom: card.hovered ? 1.093 : 1.0
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: App.openQuickView(card.product.id)
            }
            ProductBadge {
                x: 14
                y: 14
                product: card.product
            }
            // "Quick view" pill, shown on hover
            ShadowRect {
                id: quickViewPill
                anchors.horizontalCenter: parent.horizontalCenter
                y: 244
                width: quickRow.implicitWidth + 36
                height: 37
                radius: height / 2
                color: Theme.white
                elevation: "md"
                opacity: card.hovered ? 1.0 : 0.0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: Theme.hoverDuration } }
                Row {
                    id: quickRow
                    anchors.centerIn: parent
                    spacing: 8
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "eye"
                        size: 16
                    }
                    PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.link
                        text: "Quick view"
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: App.openQuickView(card.product.id)
                }
            }
        }
        // Info
        Item {
            id: info
            anchors.top: media.bottom
            width: parent.width
            height: infoColumn.height + 18 + 20
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: App.go("product", { id: card.product.id })
            }
            Column {
                id: infoColumn
                x: 20
                y: 18
                width: parent.width - 40
                spacing: 8
                PText {
                    ts: Theme.brandLine
                    color: Theme.textSecondary
                    text: card.product.brand !== undefined ? card.product.brand : ""
                    visible: text !== ""
                }
                PText {
                    width: parent.width
                    ts: Theme.productName
                    text: card.product.name !== undefined ? card.product.name : ""
                    elide: Text.ElideRight
                }
                Item {
                    width: parent.width
                    height: 37
                    PText {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.price
                        text: card.product.priceText !== undefined ? card.product.priceText : ""
                    }
                    PcButton {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 37
                        horizontalPadding: 14
                        textStyle: Theme.link
                        iconName: "bag"
                        iconSize: 16
                        iconFirst: true
                        text: "Add"
                        visible: !App.isAdmin      // admins do not shop
                        enabled: card.product.inStock === true
                        onClicked: {
                            const result = App.addToCart(card.product.id, 1)
                            if (result.ok)
                                App.openCartDrawer()
                            else
                                App.showToast("error", "Could not add to bag", result.message)
                        }
                    }
                }
            }
        }
        // Hairline border on top (sky 200 on hover)
        Rectangle {
            anchors.fill: parent
            radius: Theme.rCard
            color: "transparent"
            border.width: Theme.borderThin
            border.color: card.hovered ? Theme.sky200 : Theme.borderHairline
            antialiasing: true
        }
    }

    // Category card (302 x 400): default / hover (image zoom, darker scrim, blue explore button)
    component CategoryCard: Item {
        id: categoryCard
        property string name: ""
        property string title: name
        property string description: ""
        property string image: ""
        property int count: 0
        readonly property bool hovered: categoryHover.hovered
        signal clicked()

        width: 302
        height: 400

        Rounded {
            anchors.fill: parent
            radius: Theme.rCategory
            Rectangle {
                anchors.fill: parent
                color: Theme.midnight900
            }
            Image {
                anchors.fill: parent
                source: categoryCard.image
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                mipmap: true
                scale: categoryCard.hovered ? 1.13 : 1.0
                Behavior on scale { NumberAnimation { duration: Theme.hoverDuration * 2; easing.type: Easing.OutCubic } }
            }
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.alpha(Theme.midnight950, 0) }
                    GradientStop { position: Theme.scrimStart; color: Theme.alpha(Theme.midnight950, 0) }
                    GradientStop {
                        position: 1.0
                        color: Theme.alpha(Theme.midnight950, categoryCard.hovered ? Theme.scrimAlphaHover : Theme.scrimAlpha)
                    }
                }
            }
        }
        // Count chip
        Rectangle {
            x: 22
            y: 22
            height: 29
            width: countText.implicitWidth + 24
            radius: height / 2
            color: Theme.alpha(Theme.white, 0.2)
            border.width: Theme.borderThin
            border.color: Theme.alpha(Theme.white, 0.3)
            PText {
                id: countText
                anchors.centerIn: parent
                ts: Theme.chip
                color: Theme.white
                text: categoryCard.count + (categoryCard.count === 1 ? " product" : " products")
            }
        }
        // Title, description, explore button
        Item {
            x: 22
            width: parent.width - 44
            height: textColumn.height
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 22
            Column {
                id: textColumn
                width: 200
                spacing: 6
                PText {
                    width: parent.width
                    ts: Theme.categoryTitle
                    color: Theme.white
                    text: categoryCard.title
                    wrapMode: Text.WordWrap
                }
                PText {
                    width: 196
                    ts: Theme.bodyS
                    color: Theme.alpha(Theme.white, 0.8)
                    text: categoryCard.description
                    wrapMode: Text.WordWrap
                }
            }
            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: 46
                height: 46
                radius: height / 2
                color: categoryCard.hovered ? Theme.royal600 : Theme.white
                Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
                Icon {
                    anchors.centerIn: parent
                    name: "arrowUR"
                    size: 18
                    color: categoryCard.hovered ? Theme.white : Theme.textPrimary
                }
            }
        }
        HoverHandler {
            id: categoryHover
            cursorShape: Qt.PointingHandCursor
        }
        MouseArea {
            anchors.fill: parent
            onClicked: categoryCard.clicked()
        }
    }

    // A small product row (recently viewed): thumb, name, price
    component MiniProductCard: Rectangle {
        id: mini
        property var product: ({})
        width: 308
        height: 96
        radius: Theme.rPanel
        color: miniHover.hovered ? Theme.surfaceTint : Theme.white
        border.width: Theme.borderThin
        border.color: Theme.borderHairline

        RoundedImage {
            id: miniThumb
            x: 12
            y: 12
            width: 72
            height: 72
            radius: Theme.rThumb
            source: mini.product.image !== undefined ? mini.product.image : ""
        }
        Column {
            anchors.left: miniThumb.right
            anchors.leftMargin: 14
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            PText {
                width: parent.width
                ts: Theme.link
                text: mini.product.name !== undefined ? mini.product.name : ""
                wrapMode: Text.WordWrap
                maximumLineCount: 2
            }
            PText {
                ts: Theme.linkBold
                text: mini.product.priceText !== undefined ? mini.product.priceText : ""
            }
        }
        HoverHandler {
            id: miniHover
            cursorShape: Qt.PointingHandCursor
        }
        MouseArea {
            anchors.fill: parent
            onClicked: App.go("product", { id: mini.product.id })
        }
    }

    // ===================== Content blocks =====================
    // Accordion: open (sky 50 + minus) / closed (white + plus)
    component Accordion: Rectangle {
        id: accordion
        property string title: ""
        property string body: ""
        property bool open: false

        width: 480
        height: open ? 20 + 30 + 12 + bodyText.height + 20 : 70
        radius: Theme.rPanel
        color: open ? Theme.surfaceTint : Theme.white
        border.width: Theme.borderThin
        border.color: open ? Theme.sky200 : Theme.borderHairline
        clip: true
        Behavior on height { NumberAnimation { duration: Theme.overlayDuration; easing.type: Easing.OutCubic } }

        Item {
            id: head
            x: 22
            y: 20
            width: parent.width - 44
            height: 30
            PText {
                anchors.verticalCenter: parent.verticalCenter
                ts: Theme.cardLine
                text: accordion.title
            }
            Rectangle {
                anchors.right: parent.right
                width: 30
                height: 30
                radius: height / 2
                color: accordion.open ? Theme.white : Theme.surfaceTint
                Icon {
                    anchors.centerIn: parent
                    name: accordion.open ? "minus" : "plus"
                    size: 15
                }
            }
        }
        PText {
            id: bodyText
            x: 22
            anchors.top: head.bottom
            anchors.topMargin: 12
            width: parent.width - 44
            ts: Theme.bodyS
            color: Theme.textBody
            text: accordion.body
            wrapMode: Text.WordWrap
            opacity: accordion.open ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: Theme.overlayDuration } }
        }
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
        MouseArea {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 70
            onClicked: accordion.open = !accordion.open
        }
    }

    // Specification table: rows = [{ label, value }], striped sky 50 / white
    component SpecTable: Rectangle {
        id: specTable
        property var rows: []
        width: 736
        height: rowsColumn.height + 2
        radius: Theme.rPanel
        color: Theme.white
        border.width: Theme.borderThin
        border.color: Theme.borderHairline

        Rounded {
            anchors.fill: parent
            anchors.margins: 1
            radius: Theme.rPanel - 1
            Column {
                id: rowsColumn
                width: parent.width
                Repeater {
                    model: specTable.rows
                    delegate: Rectangle {
                        id: specRow
                        required property var modelData
                        required property int index
                        width: parent ? parent.width : 0
                        height: 49
                        color: index % 2 === 0 ? Theme.surfaceTint : Theme.white
                        PText {
                            x: 22
                            width: 220
                            anchors.verticalCenter: parent.verticalCenter
                            ts: Theme.small13
                            color: Theme.textSecondary
                            text: specRow.modelData.label
                        }
                        PText {
                            x: 242
                            anchors.verticalCenter: parent.verticalCenter
                            ts: Theme.link
                            text: specRow.modelData.value
                        }
                    }
                }
            }
        }
    }

    // ===================== Feedback =====================
    // Toast: "success", "error" or "info"
    component Toast: Item {
        id: toast
        property string kind: "success"
        property string title: ""
        property string message: ""
        signal closed()

        width: 380
        height: 74

        ShadowRect {
            anchors.fill: parent
            radius: Theme.rOption
            color: Theme.white
            border.width: Theme.borderThin
            border.color: Theme.borderHairline
            elevation: "lg"
        }
        Rectangle {
            id: toastIcon
            x: 18
            anchors.verticalCenter: parent.verticalCenter
            width: 36
            height: 36
            radius: height / 2
            color: toast.kind === "error" ? Theme.errorBg : toast.kind === "info" ? Theme.sky100 : Theme.successBg
            Icon {
                anchors.centerIn: parent
                name: toast.kind === "error" ? "x" : toast.kind === "info" ? "info" : "check"
                size: 18
                color: toast.kind === "error" ? Theme.error : toast.kind === "info" ? Theme.royal600 : Theme.success
            }
        }
        Column {
            anchors.left: toastIcon.right
            anchors.leftMargin: 14
            anchors.right: closeIcon.left
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            PText {
                width: parent.width
                ts: Theme.cardLine
                text: toast.title
                elide: Text.ElideRight
            }
            PText {
                width: parent.width
                ts: Theme.meta12
                color: Theme.textSecondary
                text: toast.message
                elide: Text.ElideRight
            }
        }
        Icon {
            id: closeIcon
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            name: "x"
            size: 16
            color: Theme.textMuted
        }
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
        MouseArea {
            anchors.fill: parent
            onClicked: toast.closed()
        }
    }

    // The white frame used by modals and the quick view (radius 28, lg shadow)
    component ModalFrame: ShadowRect {
        radius: Theme.rModal
        color: Theme.white
        elevation: "lg"
    }

    // ===================== Forms =====================
    // Form input: label, 52 px field and helper; states default / focus / filled / error / success / disabled
    component FormInput: Column {
        id: formInput
        property string label: ""
        property alias text: field.text
        property string placeholder: ""
        property string helper: ""
        property string status: ""          // "", "error" or "success"
        property bool password: false
        property int maximumLength: 120
        readonly property bool focused: field.activeFocus
        signal accepted()

        function focusField() {
            field.forceActiveFocus()
        }

        width: 360
        spacing: 8

        PText {
            visible: formInput.label !== ""
            ts: Theme.link
            color: Theme.textLabel
            text: formInput.label
        }
        Item {
            width: parent.width
            height: 52
            Rectangle {
                visible: formInput.focused && formInput.status === ""
                anchors.fill: parent
                anchors.margins: -Theme.focusRingWidth
                radius: Theme.rInput + Theme.focusRingWidth
                color: Theme.focusRing
            }
            Rectangle {
                anchors.fill: parent
                radius: Theme.rInput
                color: formInput.enabled ? Theme.white : Theme.midnight100
                border.width: formInput.focused && formInput.status === "" ? Theme.borderFocus : Theme.borderThin
                border.color: !formInput.enabled ? Theme.midnight100
                            : formInput.status === "error" ? Theme.error
                            : formInput.status === "success" ? Theme.success
                            : formInput.focused ? Theme.royal600 : Theme.borderControl
            }
            Basic.TextField {
                id: field
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: statusIcon.visible ? statusIcon.left : parent.right
                anchors.rightMargin: statusIcon.visible ? 10 : 16
                anchors.verticalCenter: parent.verticalCenter
                height: 40
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0
                verticalAlignment: TextInput.AlignVCenter
                // Explicit: digit-only text ("1900.00", "30") would otherwise be laid out right-aligned
                horizontalAlignment: TextInput.AlignLeft
                font.family: Theme.body.family
                font.pixelSize: Theme.body.size
                font.weight: Theme.body.weight
                color: formInput.enabled ? Theme.textPrimary : Theme.midnight300
                placeholderText: formInput.placeholder
                placeholderTextColor: Theme.textMuted
                echoMode: formInput.password ? TextInput.Password : TextInput.Normal
                maximumLength: formInput.maximumLength
                selectByMouse: true
                selectionColor: Theme.sky300
                selectedTextColor: Theme.textPrimary
                background: Item {}
                onAccepted: formInput.accepted()
            }
            Icon {
                id: statusIcon
                visible: formInput.status !== ""
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                name: formInput.status === "error" ? "info" : "check"
                size: 18
                color: formInput.status === "error" ? Theme.error : Theme.success
            }
        }
        PText {
            visible: formInput.helper !== ""
            width: parent.width
            ts: Theme.caption
            color: formInput.status === "error" ? Theme.error
                 : formInput.status === "success" ? Theme.success : Theme.textSecondary
            wrapMode: Text.WordWrap
            text: formInput.helper
        }
    }

    // Error banner ("Please fix 2 fields before continuing.")
    component ErrorBanner: Rectangle {
        id: errorBanner
        property string text: ""
        property bool success: false       // same banner in the success colours ("Your details have been saved.")
        height: Math.max(46, bannerText.height + 28)
        radius: Theme.rMenu
        color: success ? Theme.successBg : Theme.errorBg
        border.width: Theme.borderThin
        border.color: Theme.alpha(success ? Theme.success : Theme.error, 0.4)
        Icon {
            id: bannerIcon
            x: 18
            anchors.verticalCenter: parent.verticalCenter
            name: errorBanner.success ? "check" : "info"
            size: 18
            color: errorBanner.success ? Theme.success : Theme.error
        }
        PText {
            id: bannerText
            anchors.left: bannerIcon.right
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            ts: Theme.link
            color: errorBanner.success ? Theme.success : Theme.error
            wrapMode: Text.WordWrap
            text: errorBanner.text
        }
    }

    // Inline notice in the bag ("… quantity updated to 2." with Dismiss / Undo)
    component InlineNotice: Rectangle {
        id: notice
        property string text: ""
        property string actionText: ""
        signal action()
        height: 46
        radius: Theme.rMenu
        color: Theme.surfaceTint
        border.width: Theme.borderThin
        border.color: Theme.sky200
        Icon {
            id: noticeIcon
            x: 18
            anchors.verticalCenter: parent.verticalCenter
            name: "info"
            size: 18
            color: Theme.royal600
        }
        PText {
            anchors.left: noticeIcon.right
            anchors.leftMargin: 12
            anchors.right: noticeAction.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            ts: Theme.small13
            color: Theme.midnight800
            elide: Text.ElideRight
            text: notice.text
        }
        TextLink {
            id: noticeAction
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            textStyle: Theme.linkBold
            text: notice.actionText
            onClicked: notice.action()
        }
    }

    // A label / value row in an order summary
    component SummaryRow: Item {
        id: summaryRow
        property string label: ""
        property string value: ""
        property color valueColor: Theme.textPrimary
        property bool compact: false
        width: parent ? parent.width : 376
        height: compact ? 22 : 26
        PText {
            anchors.verticalCenter: parent.verticalCenter
            ts: summaryRow.compact ? Theme.bodyS : Theme.body
            color: Theme.textBody
            text: summaryRow.label
        }
        PText {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            ts: summaryRow.compact ? Theme.link : Theme.valueStrong
            color: summaryRow.valueColor
            text: summaryRow.value
        }
    }

    // Promo code field: default (Apply) / applied (green, Remove)
    component PromoField: Column {
        id: promoField
        property string appliedCode: ""
        property string successText: ""
        readonly property bool applied: appliedCode !== ""
        signal applyRequested(string code)
        signal removeRequested()

        function clear() {
            promoInput.text = ""
        }

        width: 376
        spacing: 8

        Rectangle {
            width: parent.width
            height: 52
            radius: height / 2
            color: promoField.applied ? Theme.successBg : Theme.surfaceTint
            border.width: Theme.borderThin
            border.color: promoField.applied ? Theme.success : Theme.borderHairline
            Icon {
                id: tagIcon
                x: 18
                anchors.verticalCenter: parent.verticalCenter
                name: "tag"
                size: 16
                color: promoField.applied ? Theme.success : Theme.textMuted
            }
            PText {
                visible: promoField.applied
                anchors.left: tagIcon.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                ts: Theme.promoCode
                text: promoField.appliedCode
            }
            Basic.TextField {
                id: promoInput
                visible: !promoField.applied
                anchors.left: tagIcon.right
                anchors.leftMargin: 10
                anchors.right: applyButton.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                height: 40
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0
                verticalAlignment: TextInput.AlignVCenter
                font.family: Theme.body.family
                font.pixelSize: Theme.body.size
                font.weight: Theme.body.weight
                color: Theme.textPrimary
                placeholderText: "Promo code"
                placeholderTextColor: Theme.textMuted
                maximumLength: 30
                selectByMouse: true
                background: Item {}
                onAccepted: promoField.applyRequested(text)
            }
            PcButton {
                id: applyButton
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                height: 40
                horizontalPadding: 18
                textStyle: Theme.link
                variant: promoField.applied ? "secondary" : "primary"
                text: promoField.applied ? "Remove" : "Apply"
                onClicked: promoField.applied ? promoField.removeRequested() : promoField.applyRequested(promoInput.text)
            }
        }
        Row {
            visible: promoField.applied && promoField.successText !== ""
            spacing: 6
            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "check"
                size: 14
                color: Theme.success
            }
            PText {
                ts: Theme.chip
                color: Theme.success
                text: promoField.successText
            }
        }
    }

    // Checkout stepper: numbered dots joined by connectors (current = dark, done = blue with a check)
    component CheckoutStepper: RowLayout {
        id: stepper
        property var steps: []
        property int current: 0
        // One entry per dot and per connector, so the delegates only read their own data
        readonly property var cells: {
            const list = []
            for (let i = 0; i < steps.length; ++i) {
                if (i > 0)
                    list.push({ connector: true, done: i <= current, label: "", number: 0, active: false })
                list.push({ connector: false, done: i < current, active: i === current, label: steps[i], number: i + 1 })
            }
            return list
        }
        spacing: 10
        height: 32

        Repeater {
            model: stepper.cells
            delegate: Item {
                id: stepCell
                required property var modelData
                Layout.fillWidth: modelData.connector
                Layout.preferredWidth: modelData.connector ? 40 : stepRow.implicitWidth
                Layout.preferredHeight: 32
                Rectangle {
                    visible: stepCell.modelData.connector
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 2
                    radius: height / 2
                    color: stepCell.modelData.done ? Theme.royal600 : Theme.borderControl
                }
                Row {
                    id: stepRow
                    visible: !stepCell.modelData.connector
                    spacing: 10
                    Rectangle {
                        width: 32
                        height: 32
                        radius: height / 2
                        color: stepCell.modelData.done ? Theme.royal600 : stepCell.modelData.active ? Theme.midnight900 : Theme.white
                        border.width: stepCell.modelData.done || stepCell.modelData.active ? 0 : Theme.borderThin
                        border.color: Theme.borderControl
                        Icon {
                            visible: stepCell.modelData.done
                            anchors.centerIn: parent
                            name: "check"
                            size: 16
                            color: Theme.white
                        }
                        PText {
                            visible: !stepCell.modelData.done
                            anchors.centerIn: parent
                            ts: Theme.linkBold
                            color: stepCell.modelData.active ? Theme.white : Theme.textMuted
                            text: stepCell.modelData.number
                        }
                    }
                    PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: stepCell.modelData.active ? Theme.linkBold : Theme.small13
                        color: stepCell.modelData.active ? Theme.textPrimary
                             : stepCell.modelData.done ? Theme.textLabel : Theme.textMuted
                        text: stepCell.modelData.label
                    }
                }
            }
        }
    }

    // Order status tracker: placed -> pharmacist check -> packed & dispatched -> delivered
    component StatusTracker: Item {
        id: tracker
        property string status: "pending"
        property string placedText: ""
        // Backend statuses on the 4 design steps (horizontal tracker, as in the Order Confirmation board):
        // pending -> pharmacist check in progress; confirmed / processing -> packing; shipped -> on the way; delivered -> all done
        readonly property bool cancelled: status === "cancelled"
        readonly property int done: status === "delivered" ? 4
                                  : status === "shipped" ? 3
                                  : status === "confirmed" || status === "processing" ? 2 : 1
        readonly property int current: cancelled || status === "delivered" ? -1 : done
        readonly property string currentText: status === "confirmed" ? "Up next"
                                            : status === "shipped" ? "On the way" : "In progress"
        readonly property var stepsModel: {
            const labels = ["Order placed", "Pharmacist check", "Packed & dispatched", "Delivered"]
            const icons = ["bag", "shield", "bag", "home"]   // as in the Order Confirmation board
            const list = []
            for (let i = 0; i < 4; ++i) {
                const finished = i < done
                const isCurrent = i === current
                list.push({
                    index: i,
                    label: labels[i],
                    icon: finished ? "check" : icons[i],
                    finished: finished,
                    current: isCurrent,
                    detail: i === 0 ? placedText : isCurrent ? currentText : (finished ? "Done" : ""),
                    // the connector after this step is blue when it leads to a finished or the current step
                    lineDone: i < done && (i + 1 < done || i + 1 === current),
                    last: i === 3
                })
            }
            return list
        }
        implicitHeight: stepsRow.height + (cancelled ? cancelNote.height + 20 : 0)

        Row {
            id: stepsRow
            width: parent.width
            Repeater {
                model: tracker.stepsModel
                delegate: Item {
                    id: trackStep
                    required property var modelData
                    width: parent ? parent.width / 4 : 0
                    height: 100
                    // connector to the next step, through the dot centres
                    Rectangle {
                        visible: !trackStep.modelData.last
                        x: 44 + 8
                        y: 21
                        width: trackStep.width - 44 - 16
                        height: 2
                        radius: 1
                        color: trackStep.modelData.lineDone ? Theme.royal600 : Theme.borderControl
                    }
                    // focus halo around the current step
                    Rectangle {
                        visible: trackStep.modelData.current
                        x: -Theme.focusRingWidth
                        y: -Theme.focusRingWidth
                        width: 44 + 2 * Theme.focusRingWidth
                        height: width
                        radius: width / 2
                        color: Theme.focusRing
                    }
                    Rectangle {
                        width: 44
                        height: 44
                        radius: height / 2
                        color: trackStep.modelData.finished ? Theme.royal600
                             : trackStep.modelData.current ? Theme.midnight900 : Theme.surfaceTint
                        border.width: trackStep.modelData.finished || trackStep.modelData.current ? 0 : Theme.borderThin
                        border.color: Theme.sky200
                        Icon {
                            anchors.centerIn: parent
                            name: trackStep.modelData.icon
                            size: 18
                            color: trackStep.modelData.finished || trackStep.modelData.current ? Theme.white : Theme.textMuted
                        }
                    }
                    Column {
                        y: 56
                        width: parent.width - 12
                        spacing: 4
                        PText {
                            width: parent.width
                            ts: Theme.cardLine
                            color: trackStep.modelData.finished || trackStep.modelData.current ? Theme.textPrimary : Theme.textMuted
                            elide: Text.ElideRight
                            text: trackStep.modelData.label
                        }
                        PText {
                            visible: text !== ""
                            ts: trackStep.modelData.current ? Theme.chip : Theme.meta12
                            color: trackStep.modelData.current ? Theme.royal600 : Theme.textSecondary
                            text: trackStep.modelData.detail
                        }
                    }
                }
            }
        }
        // Cancelled orders keep "Order placed" and say so underneath
        Rectangle {
            id: cancelNote
            visible: tracker.cancelled
            y: stepsRow.height + 20
            width: parent.width
            height: 48
            radius: Theme.rOption
            color: Theme.errorBg
            Row {
                x: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "x"
                    size: 16
                    color: Theme.error
                }
                PText {
                    anchors.verticalCenter: parent.verticalCenter
                    ts: Theme.link
                    color: Theme.error
                    text: "This order was cancelled. The items went back into stock."
                }
            }
        }
    }

    // Order status chip for lists (pending, confirmed, processing, shipped, delivered, cancelled)
    component StatusChip: Rectangle {
        id: statusChip
        property string status: "pending"
        property string text: ""
        readonly property color tone: status === "cancelled" ? Theme.error
                                    : status === "delivered" ? Theme.success
                                    : status === "pending" ? Theme.textSecondary : Theme.royal600
        width: chipLabel.implicitWidth + 24
        height: 26
        radius: height / 2
        color: status === "cancelled" ? Theme.errorBg
             : status === "delivered" ? Theme.successBg
             : status === "pending" ? Theme.midnight100 : Theme.sky100
        PText {
            id: chipLabel
            anchors.centerIn: parent
            ts: Theme.chip
            color: statusChip.tone
            text: statusChip.text
        }
    }

    // ===================== Account / admin building blocks (not in the Penpot file; built from the tokens) =====================
    // Page head: breadcrumb, Fraunces title and a subtitle (same rhythm as the Cart head)
    component PageHead: Column {
        id: pageHead
        property var crumbs: [{ label: "Home", page: "home", params: {} }]
        property string current: ""
        property string title: ""
        property string subtitle: ""
        width: Theme.contentWidth
        spacing: 16
        Breadcrumb {
            crumbs: pageHead.crumbs
            current: pageHead.current
        }
        PText {
            ts: Theme.pageTitle
            text: pageHead.title
        }
        PText {
            visible: text !== ""
            width: parent.width
            ts: Theme.bodyL
            color: Theme.textSecondary
            wrapMode: Text.WordWrap
            text: pageHead.subtitle
        }
    }

    // Side navigation row (icon + label); selected = Sky 50 fill and Royal text, like a selected menu option
    component NavItem: Rectangle {
        id: navItem
        property string text: ""
        property string iconName: "user"
        property bool selected: false
        property bool danger: false
        signal clicked()
        width: 248
        height: 48
        radius: Theme.rInput
        color: selected ? Theme.sky100 : navHover.hovered ? Theme.sky50 : "transparent"
        border.width: activeFocus ? Theme.borderFocus : 0
        border.color: Theme.royal600
        activeFocusOnTab: true
        Keys.onReturnPressed: navItem.clicked()
        Keys.onSpacePressed: navItem.clicked()
        Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
        Row {
            x: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: navItem.iconName
                size: 18
                color: navItem.danger ? Theme.error : navItem.selected ? Theme.royal600 : Theme.textSecondary
            }
            PText {
                anchors.verticalCenter: parent.verticalCenter
                ts: navItem.selected ? Theme.labelStrong : Theme.label
                color: navItem.danger ? Theme.error : navItem.selected ? Theme.royal700 : Theme.textPrimary
                text: navItem.text
            }
        }
        HoverHandler {
            id: navHover
            cursorShape: Qt.PointingHandCursor
        }
        MouseArea {
            anchors.fill: parent
            onClicked: navItem.clicked()
        }
    }

    // White card with the hairline border (account / admin panels)
    component Panel: Rectangle {
        radius: Theme.rModal
        color: Theme.white
        border.width: Theme.borderThin
        border.color: Theme.borderHairline
    }

    // Dashboard number tile
    component StatCard: Rectangle {
        id: statCard
        property string iconName: "bag"
        property string label: ""
        property string value: ""
        property string note: ""
        property bool warning: false
        signal clicked()
        height: 132
        radius: Theme.rPanel
        color: statHover.hovered ? Theme.sky50 : Theme.white
        border.width: Theme.borderThin
        border.color: statHover.hovered ? Theme.sky200 : Theme.borderHairline
        Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
        Rectangle {
            x: 20
            y: 20
            width: 40
            height: 40
            radius: Theme.rInput
            color: statCard.warning ? Theme.errorBg : Theme.surfaceTint
            Icon {
                anchors.centerIn: parent
                name: statCard.iconName
                size: 20
                color: statCard.warning ? Theme.error : Theme.royal600
            }
        }
        Column {
            x: 20
            y: 72
            width: parent.width - 40
            spacing: 2
            PText {
                width: parent.width
                ts: Theme.totalPrice
                elide: Text.ElideRight
                text: statCard.value
            }
            PText {
                width: parent.width
                ts: Theme.small13
                color: Theme.textSecondary
                elide: Text.ElideRight
                text: statCard.label + (statCard.note !== "" ? " · " + statCard.note : "")
            }
        }
        HoverHandler {
            id: statHover
            cursorShape: Qt.PointingHandCursor
        }
        MouseArea {
            anchors.fill: parent
            onClicked: statCard.clicked()
        }
    }

    // Dropdown form field: label + trigger (Form Input look) + menu of options (Sort Menu look)
    component SelectField: Column {
        id: selectField
        property string label: ""
        property string value: ""
        property string placeholder: "Choose…"
        property var options: []
        property string status: ""
        property string helper: ""
        signal picked(string value)
        function choose(option: string) {
            selectMenu.close()
            picked(option)
        }
        width: 360
        spacing: 8
        PText {
            visible: selectField.label !== ""
            ts: Theme.link
            color: Theme.textLabel
            text: selectField.label
        }
        Rectangle {
            id: selectTrigger
            width: parent.width
            height: 52
            radius: Theme.rInput
            color: Theme.white
            border.width: selectMenu.opened || selectTrigger.activeFocus ? Theme.borderFocus : Theme.borderThin
            border.color: selectField.status === "error" ? Theme.error
                        : selectMenu.opened || selectTrigger.activeFocus ? Theme.royal600 : Theme.borderControl
            activeFocusOnTab: true
            Keys.onReturnPressed: selectMenu.open()
            Keys.onSpacePressed: selectMenu.open()
            PText {
                x: 16
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 56
                ts: Theme.body
                elide: Text.ElideRight
                color: selectField.value === "" ? Theme.textMuted : Theme.textPrimary
                text: selectField.value === "" ? selectField.placeholder : selectField.value
            }
            Icon {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                name: selectMenu.opened ? "chevU" : "chevD"
                size: 18
                color: Theme.textSecondary
            }
            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
            MouseArea {
                anchors.fill: parent
                onClicked: selectMenu.opened ? selectMenu.close() : selectMenu.open()
            }
            Basic.Popup {
                id: selectMenu
                y: selectTrigger.height + 6
                width: selectTrigger.width
                padding: 8
                closePolicy: Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutsideParent
                background: ShadowRect {
                    radius: Theme.rMenu
                    color: Theme.white
                    border.width: Theme.borderThin
                    border.color: Theme.borderHairline
                    elevation: "md"
                }
                contentItem: Column {
                    width: selectTrigger.width - 16
                    spacing: 2
                    Repeater {
                        // each option carries its field ("owner"), so the delegate needs no outer ids
                        model: selectField.options.map((option) => ({ text: option, owner: selectField }))
                        delegate: MenuOption {
                            required property var modelData
                            width: parent ? parent.width : 0
                            text: modelData.text
                            selected: modelData.text === modelData.owner.value
                            onClicked: modelData.owner.choose(modelData.text)
                        }
                    }
                }
            }
        }
        PText {
            visible: selectField.helper !== ""
            ts: Theme.caption
            color: selectField.status === "error" ? Theme.error : Theme.textSecondary
            text: selectField.helper
        }
    }

    // Confirmation before a destructive action (remove product, cancel order); built on the Modal frame
    component ConfirmDialog: Basic.Popup {
        id: confirmDialog
        property string title: ""
        property string message: ""
        property string confirmText: "Confirm"
        property string cancelText: "Keep it"
        signal confirmed()
        parent: Basic.Overlay.overlay
        anchors.centerIn: parent
        width: 520
        padding: 0
        modal: true
        focus: true
        closePolicy: Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutside
        Basic.Overlay.modal: Rectangle {
            color: Theme.alpha(Theme.midnight900, 0.45)
        }
        background: ModalFrame {}
        contentItem: Column {
            padding: 36
            spacing: 20
            Rectangle {
                width: 52
                height: 52
                radius: Theme.rMenu
                color: Theme.errorBg
                Icon {
                    anchors.centerIn: parent
                    name: "info"
                    size: 22
                    color: Theme.error
                }
            }
            PText {
                width: 520 - 72
                ts: Theme.cardTitle
                wrapMode: Text.WordWrap
                text: confirmDialog.title
            }
            PText {
                width: 520 - 72
                ts: Theme.body
                color: Theme.textSecondary
                wrapMode: Text.WordWrap
                text: confirmDialog.message
            }
            Row {
                spacing: 12
                PcButton {
                    variant: "secondary"
                    text: confirmDialog.cancelText
                    onClicked: confirmDialog.close()
                }
                PcButton {
                    id: confirmButton
                    text: confirmDialog.confirmText
                    onClicked: {
                        confirmDialog.close()
                        confirmDialog.confirmed()
                    }
                }
            }
        }
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.overlayDuration }
            NumberAnimation { property: "scale"; from: 0.96; to: 1; duration: Theme.overlayDuration; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.overlayDuration }
        }
        onOpened: confirmButton.forceActiveFocus()
    }

    // ===================== Header =====================
    component HeaderDesktop: Item {
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
            GradientFill {
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
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "shield"
                        size: 14
                        color: Theme.azure300
                    }
                    PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.caption
                        color: Theme.alpha(Theme.white, 0.7)
                        text: "Licensed pharmacy · Every prescription order is checked"
                    }
                }
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "sparkle"
                        size: 14
                        color: Theme.azure300
                    }
                    PText {
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
                    PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.caption
                        color: Theme.alpha(Theme.white, 0.7)
                        text: "EN · EGP"
                    }
                    IconButton {
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
                Logo {
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
                SearchBar {
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
                                Icon {
                                    anchors.centerIn: parent
                                    name: "user"
                                    size: 20
                                }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                PText {
                                    ts: Theme.meta12
                                    color: Theme.textSecondary
                                    text: App.isLoggedIn ? "Hello, " + App.currentUserName : "Welcome"
                                }
                                PText {
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
                            background: ShadowRect {
                                radius: Theme.rMenu
                                color: Theme.white
                                border.width: Theme.borderThin
                                border.color: Theme.borderHairline
                                elevation: "md"
                            }
                            contentItem: Column {
                                spacing: 2
                                MenuOption {
                                    visible: App.isAdmin
                                    width: parent.width
                                    text: "Admin dashboard"
                                    onClicked: {
                                        accountMenu.close()
                                        App.go("admin")
                                    }
                                }
                                MenuOption {
                                    width: parent.width
                                    text: "My account"
                                    onClicked: {
                                        accountMenu.close()
                                        App.go("account", { tab: "profile" })
                                    }
                                }
                                MenuOption {
                                    visible: !App.isAdmin
                                    width: parent.width
                                    text: "My orders"
                                    onClicked: {
                                        accountMenu.close()
                                        App.go("account", { tab: "orders" })
                                    }
                                }
                                Divider {
                                    width: parent.width
                                }
                                MenuOption {
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
                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "grid"
                                size: 18
                                color: Theme.white
                            }
                            PText {
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
                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "bag"
                                size: 20
                                color: Theme.white
                            }
                            PText {
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
                                PText {
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
            Divider {
                anchors.top: parent.top
                width: parent.width
            }
            Divider {
                anchors.bottom: parent.bottom
                width: parent.width
            }
            Row {
                width: Theme.contentWidth
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 34
                TextLink {
                    iconName: "grid"
                    spacing: 8
                    color: Theme.textPrimary
                    textStyle: Theme.linkBold
                    text: "All Categories"
                    onClicked: App.go("shop")
                }
                Repeater {
                    model: App.categories()
                    delegate: TextLink {
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

    // ===================== Footer =====================
    component FooterDesktop: Item {
        id: footer
        width: parent ? parent.width : Theme.designWidth
        height: 80 + columns.height + 40 + 1 + 40 + 30 + 36

        GradientFill {
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
                    Logo {
                        dark: true
                    }
                    PText {
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
                    PText {
                        ts: Theme.overline
                        color: Theme.accentOnDark
                        text: "Shop"
                    }
                    TextLink {
                        color: Theme.alpha(Theme.white, 0.8)
                        textStyle: Theme.bodyS
                        text: "All Products"
                        onClicked: App.go("shop")
                    }
                    Repeater {
                        model: App.categories()
                        delegate: TextLink {
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
                    PText {
                        ts: Theme.overline
                        color: Theme.accentOnDark
                        text: "Stay in touch"
                    }
                    Row {
                        spacing: 10
                        Icon {
                            name: "pin"
                            size: 16
                            color: Theme.azure300
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        PText {
                            ts: Theme.bodyS
                            color: Theme.alpha(Theme.white, 0.8)
                            text: "Cairo, Egypt"
                        }
                    }
                    Row {
                        spacing: 10
                        Icon {
                            name: "mail"
                            size: 16
                            color: Theme.azure300
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        PText {
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
                PText {
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
                    PText {
                        id: cashText
                        anchors.centerIn: parent
                        ts: Theme.cashMark
                        text: "Cash on Delivery"
                    }
                }
            }
        }
    }

    // ===================== Checkout header / footer =====================
    component CheckoutHeader: Rectangle {
        width: parent ? parent.width : Theme.designWidth
        height: Theme.checkoutHeaderHeight
        color: Theme.white
        Divider {
            anchors.bottom: parent.bottom
            width: parent.width
        }
        Item {
            width: Theme.contentWidth
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            Logo {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: App.go("home")
                }
            }
            Rectangle {
                anchors.centerIn: parent
                width: secureRow.implicitWidth + 32
                height: 33
                radius: height / 2
                color: Theme.successBg
                Row {
                    id: secureRow
                    anchors.centerIn: parent
                    spacing: 8
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "lock"
                        size: 16
                        color: Theme.success
                    }
                    PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.linkBold
                        color: Theme.success
                        text: "Secure checkout"
                    }
                }
            }
        }
    }

    component CheckoutFooter: Rectangle {
        width: parent ? parent.width : Theme.designWidth
        height: 64
        color: Theme.white
        PText {
            x: (parent.width - Theme.contentWidth) / 2
            anchors.verticalCenter: parent.verticalCenter
            ts: Theme.meta12
            color: Theme.textMuted
            text: "© 2026 PharmaCare Pharmacy · Egypt"
        }
    }
}
