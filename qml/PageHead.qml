// Component mancool le file lewa7do 3ashan ne-kasar el cyclic dependency (QML maby2balsh file ye3temed 3ala file beye3temed 3aleh).
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Effects
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts

Column {
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
        Controls.PText {
            ts: Theme.pageTitle
            text: pageHead.title
        }
        Controls.PText {
            visible: text !== ""
            width: parent.width
            ts: Theme.bodyL
            color: Theme.textSecondary
            wrapMode: Text.WordWrap
            text: pageHead.subtitle
        }
    }
