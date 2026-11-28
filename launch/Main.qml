import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQml.Models

ApplicationWindow {
    id: root


    visible: true
    visibility:Window.FullScreen
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    // ── 设计令牌：将来抽成 Theme.qml (pragma Singleton) ──
    QtObject {
        id: theme
        readonly property color glass:      Qt.rgba(1, 1, 1, 0.72)
        readonly property color card:       Qt.rgba(1, 1, 1, 0.42)
        readonly property color cardHover:  Qt.rgba(1, 1, 1, 0.88)
        readonly property color cardActive: Qt.rgba(1, 1, 1, 0.96)
        readonly property color stroke:     Qt.rgba(1, 1, 1, 0.55)
        readonly property color ink:        "#1c1c1e"
        readonly property color inkDim:     Qt.rgba(0, 0, 0, 0.42)
        readonly property color accent:     "#0a84ff"
        readonly property int   rWindow:    24
        readonly property int   rCard:      16
        readonly property int   durFast:    120
        readonly property int   durBase:    180
        readonly property int   cellW:      112
        readonly property int   cellH:      126
    }

    // 键盘选中的行号（GridView.currentIndex 绑定到它）
    property int selIndex: 0

    // ── 玻璃底 ──────────────────────────────────
    Rectangle {
        id: glass
        anchors.fill: parent
        radius: theme.rWindow
        color: theme.glass
        border.width: 1
        border.color: theme.stroke
        clip: true

        // 内侧高光：制造"厚度"，比假模糊有用得多
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            gradient: Gradient {
                GradientStop { position: 0.00; color: Qt.rgba(1, 1, 1, 0.30) }
                GradientStop { position: 0.45; color: Qt.rgba(1, 1, 1, 0.00) }
                GradientStop { position: 1.00; color: Qt.rgba(0, 0, 0, 0.05) }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        // ── 搜索框（打开即焦点）──────────────────
        TextField {
            id: searchInput
            Layout.fillWidth: true
            placeholderText: "搜索应用…"
            font.pixelSize: 17
            color: theme.ink
            leftPadding: 46
            rightPadding: 16
            topPadding: 12
            bottomPadding: 12
            selectByMouse: true
            focus: true

            background: Rectangle {
                radius: 13
                color: Qt.rgba(0, 0, 0, 0.05)
                border.width: 1
                border.color: searchInput.activeFocus
                              ? Qt.rgba(0.04, 0.52, 1.0, 0.55)
                              : Qt.rgba(0, 0, 0, 0.08)
                Behavior on border.color {
                    ColorAnimation { duration: theme.durBase }
                }
            }

            // 放大镜（临时用字形，将来换 SVG）
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "⌕"
                font.pixelSize: 20
                color: theme.inkDim
                opacity: searchInput.text.length ? 0.35 : 0.62
                Behavior on opacity { NumberAnimation { duration: theme.durFast } }
            }

            // 键盘：只拦上下/回车/Esc，左右留给光标
            Keys.onPressed: (e) => {
                const cols = Math.max(1, Math.floor(grid.width / grid.cellWidth))
                if (e.key === Qt.Key_Down) {
                    root.selIndex = Math.min(root.selIndex + cols, grid.count - 1)
                    e.accepted = true
                } else if (e.key === Qt.Key_Up) {
                    root.selIndex = Math.max(root.selIndex - cols, 0)
                    e.accepted = true
                } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                    root.launchAt(root.selIndex)
                    e.accepted = true
                } else if (e.key === Qt.Key_Escape) {
                    root.close()
                    e.accepted = true
                }
            }

            Component.onCompleted: forceActiveFocus()
        }

        // ── 瀑布平铺 ─────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridView {
                id: grid
                anchors.fill: parent
                clip: true
                cellWidth: theme.cellW
                cellHeight: theme.cellH
                model: filtered
                boundsBehavior: Flickable.StopAtBounds

                // 绑定：搜索导致 count 变化时自动夹紧
                currentIndex: Math.min(root.selIndex, count - 1)

                // 过滤重排动画 —— 这一条最值钱
                displaced: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: theme.durBase
                        easing.type: Easing.OutCubic
                    }
                }
                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: theme.durBase }
                }
                remove: Transition {
                    NumberAnimation { property: "opacity"; to: 0; duration: theme.durFast }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 6
                }

                delegate: Item {
                    id: cell

                    // ← 对应 C++ roleNames()，现在就把它们写全
                    required property int    index
                    required property string name
                    required property string icon
                    required property string comment
                    required property string categories
                    required property string groupId

                    width: grid.cellWidth
                    height: grid.cellHeight

                    readonly property bool hovered:  hover.hovered
                    readonly property bool selected: GridView.isCurrentItem

                    Rectangle {
                        id: card
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: theme.rCard

                        color: cell.selected ? theme.cardActive
                             : cell.hovered  ? theme.cardHover
                                             : theme.card
                        border.width: 1
                        border.color: cell.selected
                                      ? Qt.rgba(0.04, 0.52, 1.0, 0.45)
                                      : theme.stroke

                        scale:   cell.hovered ? 1.045 : 1.0
                        opacity: cell.hovered || cell.selected ? 1.0 : 0.94

                        Behavior on scale   { NumberAnimation { duration: theme.durFast; easing.type: Easing.OutQuad } }
                        Behavior on color   { ColorAnimation  { duration: theme.durFast } }
                        Behavior on opacity { NumberAnimation { duration: theme.durFast } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Item {
                                Layout.alignment: Qt.AlignHCenter
                                width: 46
                                height: 46
                                scale: cell.hovered ? 1.06 : 1.0
                                Behavior on scale {
                                    NumberAnimation { duration: theme.durFast; easing.type: Easing.OutQuad }
                                }

                                // 图标底板
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 12
                                    color: Qt.rgba(0, 0, 0, 0.06)
                                }

                                // 真图标：见下方 C++ 侧 image provider
                                Image {
                                    id: appIcon
                                    anchors.centerIn: parent
                                    width: 34
                                    height: 34
                                    sourceSize.width: 68
                                    sourceSize.height: 68
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    smooth: true
                                    // source: "image://theme/" + cell.icon
                                    visible: status === Image.Ready
                                }
                            }

                            Text {
                                text: cell.name
                                font.pixelSize: 12
                                color: theme.ink
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                                Layout.maximumWidth: grid.cellWidth - 24
                            }
                        }
                    }

                    HoverHandler { id: hover }
                    TapHandler { onTapped: root.launchAt(cell.index) }
                }
            }

            // 空结果
            Text {
                anchors.centerIn: parent
                visible: grid.count === 0
                text: "没有匹配的应用"
                font.pixelSize: 15
                color: theme.inkDim
            }
        }
    }

    // 入场淡入
    // opacity: 0
    // Component.onCompleted: fadeIn.start()
    // NumberAnimation {
    //     id: fadeIn
    //     target: root
    //     property: "opacity"
    //     to: 1
    //     duration: 180
    //     easing.type: Easing.OutCubic
    // }
    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14
        opacity: 0
        Component.onCompleted: contentFade.start()
    }

    NumberAnimation {
        id: contentFade
        target: content
        property: "opacity"
        to: 1
        duration: 180
        easing.type: Easing.OutCubic
    }
    function launchAt(i) {
        if (i < 0 || i >= grid.count) return
        // 生产环境换成：backend.launch(i)
        console.log("launch row", i)
    }

    // ── 假数据：结构与 C++ model 一致，将来直接删 ──
    // ── 源数据（将来换成 backend.apps）──
    ListModel {
        id: appModel
        ListElement { name: "Firefox";    icon: "firefox";        comment: "浏览器";     categories: "Network;WebBrowser;";  groupId: "net" }
        ListElement { name: "Terminal";   icon: "utilities-terminal"; comment: "终端";   categories: "System;TerminalEmulator;"; groupId: "sys" }
        ListElement { name: "VS Code";    icon: "vscode";         comment: "编辑器";     categories: "Development;IDE;";     groupId: "dev" }
        ListElement { name: "Files";      icon: "system-file-manager"; comment: "文件";  categories: "System;FileManager;";   groupId: "sys" }
        ListElement { name: "Calculator"; icon: "accessories-calculator"; comment: "计算器"; categories: "Utility;Calculator;"; groupId: "util" }
        ListElement { name: "CLion";      icon: "clion";          comment: "C/C++ IDE";  categories: "Development;IDE;";     groupId: "dev" }
        ListElement { name: "PyCharm";    icon: "pycharm";        comment: "Python IDE"; categories: "Development;IDE;";     groupId: "dev" }
        ListElement { name: "Ollama";     icon: "ollama";         comment: "本地模型";   categories: "Development;";         groupId: "dev" }
        ListElement { name: "Steam";      icon: "steam";          comment: "游戏";       categories: "Game;";                groupId: "game" }
        ListElement { name: "Settings";   icon: "preferences-system"; comment: "设置";   categories: "Settings;";            groupId: "sys" }
    }

    // ── 可见数据：过滤结果，GridView 真正吃的是它 ──
    ListModel { id: visibleModel }

    function rebuildVisible() {
        const q = searchInput.text.trim().toLowerCase()
        visibleModel.clear()
        for (let i = 0; i < appModel.count; ++i) {
            const it = appModel.get(i)
            const hit = (q === "")
                || (it.name.toLowerCase().indexOf(q) !== -1)
                || (it.comment.toLowerCase().indexOf(q) !== -1)
            if (!hit) continue
            visibleModel.append({
                "name":       it.name,
                "icon":       it.icon,
                "comment":    it.comment,
                "categories": it.categories,
                "groupId":    it.groupId
            })
        }
        root.selIndex = 0
    }

    Component.onCompleted: rebuildVisible()

    Connections {
        target: searchInput
        function onTextChanged() { root.rebuildVisible() }
    }

    // 过滤 + 排序，全部靠绑定
    // SortFilterProxyModel {
    //     id: filtered
    //     sourceModel: appModel
    //     filterRoleName: "name"
    //     filterString: searchInput.text.trim()
    //     filterCaseSensitivity: Qt.CaseInsensitive
    //     sortRoleName: "name"
    //     sortOrder: Qt.AscendingOrder
    // }
}