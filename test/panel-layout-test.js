const assert = require("node:assert/strict");
const fs = require("node:fs");

const panel = fs.readFileSync(`${__dirname}/../InputMethodPanel.qml`, "utf8");

assert.match(panel, /text: "↑↓ Select · Enter Apply · C Configure"/);
assert.doesNotMatch(panel, /Right-click bar to toggle/);
assert.match(panel, /text: Model\.methodDescription\(methodRow\.modelData\)/);
assert.doesNotMatch(panel, /text: String\(methodRow\.modelData\.id\)/);
assert.doesNotMatch(panel, /CursorSurface/);
assert.match(panel, /trailingControl: Component/);
assert.match(panel, /ToggleSwitch/);
assert.match(panel, /checked: root\.inputActive/);
assert.match(panel, /busy: root\.actionBusy/);
assert.match(panel, /onToggled: root\.hostWidget\.toggleInput\(\)/);
assert.match(panel, /text: root\.inputActive \? "Turn off input method" : "Turn on input method"/);
assert.match(panel, /iconText: "›"/);
assert.doesNotMatch(panel, /iconText: "⚙"/);

console.log("panel layout tests passed");
