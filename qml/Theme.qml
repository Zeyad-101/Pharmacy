// El file da fih kol el design tokens men el Penpot: el alwan, el fonts, el mesa7at, el radius, wel shadows.
// Owner: Abdelrhman (GUI)
pragma Singleton
import QtQuick

QtObject {
    id: theme

    // ---------- Resources ----------
    readonly property string res: "qrc:/qt/qml/PharmaCare/Resources/"

    // ---------- Layout grid (desktop 1440 · 12 col · 80 margins · 24 gutters) ----------
    readonly property int designWidth: 1440
    readonly property int contentWidth: 1280
    readonly property int sideMargin: 80
    readonly property int gutter: 24
    readonly property int headerHeight: 176
    readonly property int checkoutHeaderHeight: 84

    // ---------- Library colours (28) ----------
    readonly property color midnight950: "#040A1F"
    readonly property color midnight900: "#0A1633"
    readonly property color midnight800: "#0F2148"
    readonly property color midnight700: "#18305F"
    readonly property color midnight600: "#3A4C72"
    readonly property color midnight500: "#5A6B8E"
    readonly property color midnight400: "#8391AE"
    readonly property color midnight300: "#B3BDD1"
    readonly property color midnight200: "#D9DFEA"
    readonly property color midnight100: "#EDF0F6"
    readonly property color royal800: "#14318F"
    readonly property color royal700: "#1A3FB5"
    readonly property color royal600: "#2251D9"
    readonly property color royal500: "#3A67EA"
    readonly property color royal400: "#6A8DF0"
    readonly property color azure600: "#1576E0"
    readonly property color azure500: "#2E8FF5"
    readonly property color azure400: "#5AA9FA"
    readonly property color azure300: "#8FC5FC"
    readonly property color sky300: "#B9DAFF"
    readonly property color sky200: "#D6E9FF"
    readonly property color sky100: "#E8F3FF"
    readonly property color sky50: "#F4F9FF"
    readonly property color white: "#FFFFFF"
    readonly property color success: "#0F9F7A"
    readonly property color successBg: "#E6F6F1"
    readonly property color error: "#D23F57"
    readonly property color errorBg: "#FCECEF"

    // Semantic names used by the components
    readonly property color textPrimary: midnight900
    readonly property color textBody: midnight600
    readonly property color textSecondary: midnight500
    readonly property color textLabel: midnight700
    readonly property color textMuted: midnight400
    readonly property color textDisabled: midnight300
    readonly property color borderHairline: midnight100
    readonly property color borderControl: midnight200
    readonly property color accent: royal600
    readonly property color accentOnDark: azure300
    readonly property color surface: white
    readonly property color surfaceTint: sky50

    // A colour with a different opacity (translucent whites, shadow colours)
    function alpha(c: color, a: real): color {
        return Qt.rgba(c.r, c.g, c.b, a)
    }

    // ---------- Gradients (stops; diagonal = Penpot 0,0 -> 1,1) ----------
    // Penpot geometry: horizontal (0,0.5 -> 1,0.5), diagonal (0,0 -> 1,1), vertical (0.5,0 -> 0.5,1)
    readonly property var gradMidnightDepth: [midnight950, royal700]   // dark hero cards
    readonly property var gradRoyalGlow: [royal600, azure500]          // Buy now, bars, emblem
    readonly property var gradSkyAir: [sky100, white]
    readonly property var gradAnnouncement: [midnight950, royal800]    // announcement bar, promo banner
    readonly property var gradFooter: [midnight950, midnight900]       // footer (vertical)
    readonly property var gradNewsletter: [royal700, midnight950]
    readonly property var gradDarkCard: [midnight900, royal700]        // advice, pharmacist note, estimate, info tile
    readonly property var gradLogoLight: [midnight900, royal600]       // logo mark on white, discount seal
    readonly property var gradLogoDark: [white, sky200]                // logo mark on dark
    readonly property var gradPageHead: [sky50, white]                 // shop page head (vertical)
    readonly property var gradCardPreview: [midnight950, royal600]
    // Home hero card: #E8F3FF 0 -> #F4F9FF 0.55 -> #FFFFFF 1 (diagonal)
    readonly property var gradHero: [sky100, sky50, white]
    readonly property real gradHeroMid: 0.55
    // Category image scrim (vertical): transparent at 0.35 -> Midnight 950 at 78 % (hover 90 %)
    readonly property real scrimStart: 0.35
    readonly property real scrimAlpha: 0.78
    readonly property real scrimAlphaHover: 0.90
    // Testimonials / page backgrounds (vertical): #FFFFFF 0 -> #F4F9FF 0.3 -> #F4F9FF 1
    readonly property real gradSoftMid: 0.3

    // ---------- Fonts (static TTF, SIL OFL) ----------
    readonly property FontLoader frauncesLight: FontLoader { source: theme.res + "fonts/Fraunces-Light.ttf" }
    readonly property FontLoader frauncesRegular: FontLoader { source: theme.res + "fonts/Fraunces-Regular.ttf" }
    readonly property FontLoader frauncesMedium: FontLoader { source: theme.res + "fonts/Fraunces-Medium.ttf" }
    readonly property FontLoader frauncesLightItalic: FontLoader { source: theme.res + "fonts/Fraunces-LightItalic.ttf" }
    readonly property FontLoader frauncesItalic: FontLoader { source: theme.res + "fonts/Fraunces-Italic.ttf" }
    readonly property FontLoader dmRegular: FontLoader { source: theme.res + "fonts/DMSans-Regular.ttf" }
    readonly property FontLoader dmMedium: FontLoader { source: theme.res + "fonts/DMSans-Medium.ttf" }
    readonly property FontLoader dmSemiBold: FontLoader { source: theme.res + "fonts/DMSans-SemiBold.ttf" }
    readonly property FontLoader dmBold: FontLoader { source: theme.res + "fonts/DMSans-Bold.ttf" }
    readonly property FontLoader dmExtraBold: FontLoader { source: theme.res + "fonts/DMSans-ExtraBold.ttf" }
    readonly property FontLoader dmBoldItalic: FontLoader { source: theme.res + "fonts/DMSans-BoldItalic.ttf" }
    readonly property FontLoader dmExtraBoldItalic: FontLoader { source: theme.res + "fonts/DMSans-ExtraBoldItalic.ttf" }

    // The family name of each weight (one name on macOS / DirectWrite, separate names on older Windows engines)
    function fraunces(weight: int): string {
        if (weight <= 300)
            return frauncesLight.font.family
        if (weight >= 500)
            return frauncesMedium.font.family
        return frauncesRegular.font.family
    }
    function dmSans(weight: int): string {
        if (weight >= 800)
            return dmExtraBold.font.family
        if (weight >= 700)
            return dmBold.font.family
        if (weight >= 600)
            return dmSemiBold.font.family
        if (weight >= 500)
            return dmMedium.font.family
        return dmRegular.font.family
    }

    // A text style: family, size (px), weight, line height (x size), letter spacing (px), uppercase
    function style(serif: bool, size: int, weight: int, lineHeight: real, spacing: real, caps: bool): var {
        return {
            family: serif ? fraunces(weight) : dmSans(weight),
            size: size,
            weight: weight,
            lh: lineHeight,
            ls: spacing,
            caps: caps
        }
    }

    // ---------- Library typography (14) ----------
    readonly property var displayXL: style(true, 76, 300, 1.02, -2.2, false)
    readonly property var displayL: style(true, 56, 300, 1.08, -1.6, false)
    readonly property var h1: style(true, 44, 400, 1.1, -1.1, false)
    readonly property var h2: style(true, 36, 400, 1.15, -0.8, false)
    readonly property var h3: style(false, 24, 600, 1.3, -0.4, false)
    readonly property var h4: style(false, 18, 600, 1.35, -0.2, false)
    readonly property var bodyL: style(false, 18, 400, 1.6, 0, false)
    readonly property var body: style(false, 16, 400, 1.6, 0, false)
    readonly property var bodyS: style(false, 14, 400, 1.55, 0, false)
    readonly property var label: style(false, 14, 500, 1.3, 0, false)
    readonly property var button: style(false, 15, 600, 1.2, 0, false)
    readonly property var price: style(false, 18, 700, 1.2, -0.2, false)
    readonly property var caption: style(false, 12, 500, 1.4, 0.2, false)
    readonly property var overline: style(false, 12, 600, 1.3, 1.6, true)

    // ---------- Other text styles used in the boards ----------
    readonly property var heroTitle: style(true, 70, 300, 1.043, -2.2, false)   // Penpot box: 219 px for 3 lines
    readonly property var pageTitle: style(true, 52, 300, 1.08, -1.6, false)
    readonly property var promoTitle: style(true, 52, 300, 1.08, -1.6, false)
    readonly property var whyTitle: style(true, 46, 400, 1.1, -1.1, false)
    readonly property var pdpTitle: style(true, 42, 400, 1.1, -1.1, false)
    readonly property var quickViewTitle: style(true, 32, 400, 1.15, -0.8, false)
    readonly property var cardTitle: style(true, 30, 400, 1.15, -0.8, false)
    readonly property var categoryTitle: style(true, 26, 400, 1.1, -0.8, false)
    readonly property var drawerTitle: style(true, 28, 400, 1.15, -0.8, false)
    readonly property var wordmark: style(true, 24, 500, 1.3, -0.6, false)
    readonly property var wordmarkItalic: style(true, 24, 400, 1.3, -0.6, false)
    readonly property var pdpPrice: style(false, 36, 700, 1.1, -1.1, false)
    readonly property var quickViewPrice: style(false, 28, 700, 1.3, -0.4, false)
    readonly property var totalPrice: style(false, 24, 700, 1.3, -0.4, false)
    readonly property var productName: style(false, 16, 600, 1.35, -0.1, false)
    readonly property var cardLine: style(false, 16, 600, 1.4, -0.1, false)
    readonly property var link: style(false, 13, 600, 1.3, 0, false)
    readonly property var linkBold: style(false, 13, 700, 1.3, 0, false)
    readonly property var small13: style(false, 13, 500, 1.3, 0, false)
    readonly property var small13Regular: style(false, 13, 400, 1.3, 0, false)
    readonly property var brandLine: style(false, 12, 600, 1.4, 1.2, true)
    readonly property var brandAccent: style(false, 13, 600, 1.3, 1.6, true)
    readonly property var chip: style(false, 12, 600, 1.4, 0.2, false)
    readonly property var tiny: style(false, 11, 500, 1.4, 0.2, false)
    readonly property var tinyOverline: style(false, 11, 600, 1.3, 1.6, true)
    readonly property var tinyRegular: style(false, 11, 400, 1.4, 0.2, false)
    readonly property var microBrand: style(false, 10, 600, 1.4, 1, true)
    readonly property var labelStrong: style(false, 14, 600, 1.3, 0, false)
    readonly property var subtotal: style(false, 18, 700, 1.35, -0.2, false)
    readonly property var meta12: style(false, 12, 400, 1.4, 0.2, false)
    readonly property var countBadge: style(false, 12, 700, 1.4, 0.2, false)
    readonly property var cashMark: style(false, 12, 600, 1.4, 0.2, false)
    readonly property var brandLumiere: style(true, 24, 400, 1.15, -0.4, false)
    readonly property var brandNordic: style(false, 16, 700, 1.4, 3, true)
    readonly property var brandDerma: style(false, 22, 600, 1.3, -0.6, false)
    readonly property var brandAqualis: style(true, 28, 300, 1.15, -0.8, false)
    readonly property var brandMedix: style(false, 22, 800, 1.3, 1.5, true)
    readonly property var brandSafeHands: style(false, 20, 500, 1.35, 0, false)

    // ---------- Spacing (8-pt) ----------
    readonly property int s4: 4
    readonly property int s8: 8
    readonly property int s12: 12
    readonly property int s16: 16
    readonly property int s24: 24
    readonly property int s32: 32
    readonly property int s48: 48
    readonly property int s64: 64
    readonly property int s96: 96

    // ---------- Radii ----------
    readonly property int rCross: 1
    readonly property int rCheckbox: 6
    readonly property int rChip: 8
    readonly property int rMenuItem: 10
    readonly property int rThumb: 14
    readonly property int rTile: 12
    readonly property int rInput: 14
    readonly property int rMenu: 16
    readonly property int rOption: 18
    readonly property int rPanel: 20
    readonly property int rCard: 22
    readonly property int rSidebar: 24
    readonly property int rCategory: 26
    readonly property int rModal: 28
    readonly property int rHeroPhoto: 30
    readonly property int rBanner: 32
    readonly property int rHero: 36
    readonly property int rPill: 999

    // ---------- Borders ----------
    readonly property real borderThin: 1
    readonly property real borderFocus: 1.5

    // ---------- Shadows: x, y, blur, spread, colour ----------
    readonly property var shadowSm: ({ x: 0, y: 1, blur: 3, spread: 0, color: alpha(midnight900, 0.10) })
    readonly property var shadowMd: ({ x: 0, y: 10, blur: 30, spread: -4, color: alpha(midnight900, 0.10) })
    readonly property var shadowLg: ({ x: 0, y: 24, blur: 60, spread: -8, color: alpha(midnight900, 0.20) })
    readonly property var shadowGlow: ({ x: 0, y: 10, blur: 28, spread: -6, color: alpha(royal600, 0.40) })
    readonly property color focusRing: alpha(royal600, 0.10)
    readonly property int focusRingWidth: 4

    function shadow(name: string): var {
        if (name === "sm")
            return shadowSm
        if (name === "md")
            return shadowMd
        if (name === "lg")
            return shadowLg
        if (name === "glow")
            return shadowGlow
        return null
    }

    // ---------- Motion ----------
    readonly property int hoverDuration: 180
    readonly property int overlayDuration: 220
    readonly property int toastDuration: 3200
}
