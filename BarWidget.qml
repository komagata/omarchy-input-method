import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

BarWidget {
  id: root
  moduleName: "komagata.input-method"

  property bool alive: true
  property var status: Model.parseStatus("")
  property string statusOutput: ""
  readonly property string pluginPath: Qt.resolvedUrl(".").toString().replace(/^file:\/\//, "").replace(/\/$/, "")
  readonly property string statusHelper: pluginPath + "/bin/input-method-status"
  readonly property string actionHelper: pluginPath + "/bin/input-method-action"
  readonly property var currentMethod: status.current
  readonly property string displayLabel: status.available ? Model.displayLabel(currentMethod) : "?"
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

  function refresh() {
    if (!statusProcess.running) {
      statusOutput = ""
      statusProcess.running = true
    }
  }

  function runAction(args) {
    if (actionProcess.running) return
    actionProcess.command = [root.actionHelper].concat(args)
    actionProcess.running = true
  }

  function selectMethod(id) { runAction(["select", String(id)]) }
  function toggleInput() { runAction(["toggle"]) }
  function configure() { Quickshell.execDetached([root.actionHelper, "configure"]) }
  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function togglePanel() { if (panelLoader.item) panelLoader.item.toggle() }
  function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch() }

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    target.bar = root.bar
    target.anchorItem = button
    target.hostWidget = root
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
  onBarChanged: injectPanel()

  Timer {
    interval: 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Process {
    id: statusProcess
    command: [root.statusHelper]
    stdout: StdioCollector {
      id: statusStdout
      waitForEnd: true
      onStreamFinished: root.statusOutput = text
    }
    onExited: function(exitCode) {
      if (root.alive && exitCode === 0) root.status = Model.parseStatus(statusStdout.text || root.statusOutput)
    }
  }

  Process {
    id: actionProcess
    onExited: if (root.alive) refreshDelay.restart()
  }

  Timer { id: refreshDelay; interval: 100; onTriggered: root.refresh() }

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("InputMethodPanel.qml?v=0.1.1")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.displayLabel
    labelVisible: true
    hasVisualContent: true
    tooltipText: root.status.available
      ? "Input method: " + Model.displayName(root.currentMethod)
      : "Fcitx 5 is unavailable"
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) root.toggleInput()
      else root.togglePanel()
    }
  }

  Component.onDestruction: {
    alive = false
    statusProcess.running = false
    actionProcess.running = false
  }
}
