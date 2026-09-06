pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "komagata.input-method"
  ipcTarget: "komagata.input-method"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root
  readonly property var methods: hostWidget ? hostWidget.status.methods : []
  readonly property string currentId: hostWidget ? hostWidget.status.currentId : ""
  readonly property var currentMethod: hostWidget ? hostWidget.status.current : null
  readonly property bool inputActive: hostWidget ? hostWidget.status.state === 2 : false
  readonly property bool actionBusy: hostWidget ? hostWidget.actionBusy : false
  readonly property var shortcuts: hostWidget ? hostWidget.status.triggerKeys : []
  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color dim: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.65)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  property int cursorIndex: 0

  function open() {
    if (hostWidget) hostWidget.refresh()
    var current = 0
    for (var i = 0; i < methods.length; i++) if (methods[i].id === currentId) current = i
    cursorIndex = current
    controller.show()
  }

  function close() { controller.hide() }
  function toggle() { if (opened) close(); else open() }
  function moveCursor(dy) {
    if (methods.length === 0 || dy === 0) return
    cursorIndex = (cursorIndex + (dy > 0 ? 1 : -1) + methods.length) % methods.length
  }
  function select(index) {
    if (index < 0 || index >= methods.length || !hostWidget) return
    hostWidget.selectMethod(methods[index].id)
    close()
  }
  function switchPanel(direction) {
    if (bar && typeof bar.switchPanelFrom === "function") return bar.switchPanelFrom(barIdentity, direction)
    return false
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    padding: Style.space(20)
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(content.implicitHeight, Style.space(520))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onMoveRequested: function(dx, dy) { root.moveCursor(dy) }
      onActivateRequested: root.select(root.cursorIndex)
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "c" || t === "C") { root.hostWidget.configure(); root.close() }
        else if (t === "t" || t === "T") root.hostWidget.toggleInput()
      }

      Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: content.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
          id: content
          width: parent.width
          spacing: Style.space(6)

          Item { width: 1; height: Style.space(4) }

          PanelHero {
            id: hero
            width: parent.width
            title: "Input Methods"
            meta: root.inputActive ? "Input method enabled" : "Direct input"
            foreground: root.foreground
            fontFamily: root.fontFamily
            iconComponent: Component {
              Text {
                text: root.hostWidget ? root.hostWidget.displayLabel : "?"
                textFormat: Text.PlainText
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
                font.bold: true
              }
            }
            trailingControl: Component {
              ToggleSwitch {
                id: powerSwitch
                checked: root.inputActive
                busy: root.actionBusy
                foreground: hero.foreground
                onToggled: root.hostWidget.toggleInput()

                PanelToolTip {
                  visible: powerSwitch.containsMouse
                  text: root.inputActive ? "Turn off input method" : "Turn on input method"
                  fontFamily: hero.fontFamily
                }
              }
            }
          }

          Item { width: 1; height: Style.space(12) }

          Text {
            visible: root.methods.length === 0
            width: parent.width
            text: "No configured input methods found"
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
          }

          PanelSeparator {
            visible: root.methods.length > 0
            width: parent.width
            foreground: root.foreground
          }

          Item { width: 1; height: Style.space(4) }

          Repeater {
            model: root.methods

            Rectangle {
              id: methodRow
              required property var modelData
              required property int index
              width: content.width
              height: Math.max(Style.space(60), methodContent.implicitHeight + Style.space(24))
              radius: Style.space(6)
              readonly property bool hasCursor: root.cursorIndex === index
              readonly property bool current: String(modelData.id) === root.currentId
              color: methodArea.containsMouse
                ? Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.15)
                : (hasCursor || current
                    ? Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.08)
                    : "transparent")

              MouseArea {
                id: methodArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.cursorIndex = methodRow.index
                onClicked: root.select(methodRow.index)
              }

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Style.space(14)
                anchors.rightMargin: Style.space(14)
                spacing: Style.spacing.controlGap

                Text {
                  text: Model.displayLabel(methodRow.modelData)
                  textFormat: Text.PlainText
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.title
                  font.bold: true
                  Layout.preferredWidth: Style.space(32)
                  horizontalAlignment: Text.AlignHCenter
                }

                ColumnLayout {
                  id: methodContent
                  Layout.fillWidth: true
                  spacing: Style.space(4)
                  Text {
                    Layout.fillWidth: true
                    text: Model.displayName(methodRow.modelData)
                    textFormat: Text.PlainText
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                    elide: Text.ElideRight
                  }
                  Text {
                    Layout.fillWidth: true
                    text: Model.methodDescription(methodRow.modelData)
                    textFormat: Text.PlainText
                    color: root.dim
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    elide: Text.ElideRight
                  }
                }

                Text {
                  visible: methodRow.current
                  text: "✓"
                  textFormat: Text.PlainText
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.title
                }
              }
            }
          }

          Item { width: 1; height: Style.space(8) }

          PanelSeparator {
            width: parent.width
            foreground: root.foreground
          }

          Button {
            width: parent.width
            text: "Configure Fcitx 5"
            iconText: "›"
            foreground: root.foreground
            fontFamily: root.fontFamily
            bordered: false
            leftAlign: true
            onClicked: { root.hostWidget.configure(); root.close() }
          }

          Text {
            visible: root.shortcuts.length > 0
            width: parent.width
            text: "Toggle input"
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            horizontalAlignment: Text.AlignHCenter
          }

          Flow {
            width: parent.width
            spacing: Style.space(6)
            Repeater {
              model: root.shortcuts
              Rectangle {
                id: shortcutBadge
                required property string modelData
                width: Math.min(shortcutText.implicitWidth + Style.space(16), content.width)
                height: shortcutText.implicitHeight + Style.space(10)
                radius: Style.space(4)
                color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.06)
                Text {
                  id: shortcutText
                  anchors.centerIn: parent
                  width: Math.min(implicitWidth, content.width - Style.space(16))
                  text: shortcutBadge.modelData
                  textFormat: Text.PlainText
                  color: root.dim
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  wrapMode: Text.Wrap
                }
              }
            }
          }

          Text {
            width: parent.width
            text: "↑↓ Select · Enter Apply · C Configure"
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            horizontalAlignment: Text.AlignHCenter
          }

          Item { width: 1; height: Style.space(4) }
        }
      }
    }
  }
}
