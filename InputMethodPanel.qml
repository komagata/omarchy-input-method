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
  readonly property color accent: Color.accent
  readonly property color dim: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.65)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  // One left edge for everything. PanelHero indents its labels by this much
  // past the (empty) icon slot, so method names, the configure button, and
  // the footer all sit on the same vertical line as the title.
  readonly property int inset: Style.space(14)
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
          spacing: 0

          Item { width: 1; height: Style.space(4) }

          // No icon in the hero: the bar already shows the current label and
          // every row carries its own, so a display-size glyph up here only
          // repeated what sits directly beneath it.
          PanelHero {
            id: hero
            width: parent.width
            title: "Input Methods"
            meta: root.inputActive ? "Input method enabled" : "Direct input"
            foreground: root.foreground
            fontFamily: root.fontFamily
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

          Item { width: 1; height: Style.space(16) }

          PanelSeparator {
            width: parent.width
            foreground: root.foreground
          }

          Item { width: 1; height: Style.space(10) }

          Text {
            visible: root.methods.length === 0
            width: parent.width
            leftPadding: root.inset
            rightPadding: root.inset
            text: "No configured input methods found"
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            wrapMode: Text.Wrap
          }

          Column {
            id: methodList
            width: parent.width
            spacing: Style.space(4)

            Repeater {
              model: root.methods

              // Rows paint with the kit's state tokens so the two highlights
              // read differently: the keyboard/mouse cursor gets the
              // hover-cursor fill and border, while the current method keeps
              // the selected fill, a bold selected-color name, and a caption.
              BorderSurface {
                id: methodRow
                required property var modelData
                required property int index
                readonly property bool hasCursor: root.cursorIndex === index
                readonly property bool current: String(modelData.id) === root.currentId
                width: methodList.width
                height: Math.max(Style.space(56), methodContent.implicitHeight + Style.space(24))
                radius: Style.cornerRadius
                color: methodArea.pressed ? Style.pressedFillFor(root.foreground, root.accent)
                  : hasCursor ? Style.hoverFillFor(root.foreground, root.accent)
                  : current ? Style.selectedFillFor(root.foreground, root.accent)
                  : "transparent"
                borderSpec: hasCursor ? Border.controlSpec("hover-cursor", root.foreground, root.accent)
                  : (current && Border.controlHasWidth("selected")) ? Border.controlSpec("selected", root.foreground, root.accent)
                  : Border.none()

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
                  anchors.leftMargin: root.inset
                  anchors.rightMargin: root.inset
                  spacing: Style.spacing.controlGap

                  ColumnLayout {
                    id: methodContent
                    Layout.fillWidth: true
                    spacing: Style.space(3)

                    Text {
                      Layout.fillWidth: true
                      text: Model.displayName(methodRow.modelData)
                      textFormat: Text.PlainText
                      color: methodRow.current ? Style.selectedStateColor(root.foreground, root.accent) : root.foreground
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.title
                      font.bold: methodRow.current
                      elide: Text.ElideRight
                    }

                    Text {
                      Layout.fillWidth: true
                      visible: text !== ""
                      text: Model.methodDescription(methodRow.modelData)
                      textFormat: Text.PlainText
                      color: root.dim
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.bodySmall
                      elide: Text.ElideRight
                    }
                  }

                  Text {
                    visible: methodRow.current
                    text: "Current"
                    textFormat: Text.PlainText
                    color: root.dim
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    font.bold: true
                    font.letterSpacing: 1.2
                    font.capitalization: Font.AllUppercase
                  }

                  Text {
                    Layout.preferredWidth: Style.space(32)
                    text: Model.displayLabel(methodRow.modelData)
                    textFormat: Text.PlainText
                    color: methodRow.current ? root.foreground : root.dim
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.title
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                  }
                }
              }
            }
          }

          Item { width: 1; height: Style.space(12) }

          PanelSeparator {
            width: parent.width
            foreground: root.foreground
          }

          Item { width: 1; height: Style.space(6) }

          Button {
            width: parent.width
            text: "Configure Fcitx 5"
            iconText: "›"
            foreground: root.foreground
            fontFamily: root.fontFamily
            bordered: false
            leftAlign: true
            horizontalPadding: root.inset
            onClicked: { root.hostWidget.configure(); root.close() }
          }

          Item { width: 1; height: Style.space(10) }

          Text {
            id: shortcutLabel
            visible: root.shortcuts.length > 0
            width: parent.width
            leftPadding: root.inset
            text: "Toggle input"
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          Item { width: 1; height: root.shortcuts.length > 0 ? Style.space(6) : 0 }

          Flow {
            id: shortcutRow
            visible: root.shortcuts.length > 0
            width: parent.width
            leftPadding: root.inset
            rightPadding: root.inset
            spacing: Style.space(6)
            readonly property int chipHeight: shortcutLabel.implicitHeight + Style.space(10)
            readonly property int chipMaxWidth: width - leftPadding - rightPadding

            Repeater {
              model: root.shortcuts

              BorderSurface {
                id: shortcutBadge
                required property string modelData
                width: Math.min(shortcutText.implicitWidth + Style.space(16), shortcutRow.chipMaxWidth)
                height: Math.max(shortcutRow.chipHeight, shortcutText.implicitHeight + Style.space(10))
                radius: Style.cornerRadius
                color: Style.normalFillFor(root.foreground, root.accent)
                borderSpec: Border.controlSpec("normal", root.foreground, root.accent)

                Text {
                  id: shortcutText
                  anchors.centerIn: parent
                  width: Math.min(implicitWidth, shortcutRow.chipMaxWidth - Style.space(16))
                  text: shortcutBadge.modelData
                  textFormat: Text.PlainText
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  wrapMode: Text.Wrap
                  horizontalAlignment: Text.AlignHCenter
                }
              }
            }
          }

          Item { width: 1; height: Style.space(10) }

          Text {
            width: parent.width
            leftPadding: root.inset
            rightPadding: root.inset
            text: "↑↓ Select · Enter Apply · C Configure"
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
          }

          Item { width: 1; height: Style.space(4) }
        }
      }
    }
  }
}
