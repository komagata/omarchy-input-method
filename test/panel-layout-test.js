const assert = require("node:assert/strict");
const fs = require("node:fs");

const panel = fs.readFileSync(`${__dirname}/../InputMethodPanel.qml`, "utf8");

assert.match(panel, /text: "↑↓ Select · Enter Apply · C Configure"/);
assert.doesNotMatch(panel, /Right-click bar to toggle/);
assert.match(panel, /PanelSectionHeader/);
assert.match(panel, /text: "INPUT METHODS"/);
assert.match(panel, /height: Style\.space\(56\)/);
assert.match(panel, /radius: Style\.space\(6\)/);
assert.match(panel, /text: Model\.methodDescription\(methodRow\.modelData\)/);
assert.doesNotMatch(panel, /text: String\(methodRow\.modelData\.id\)/);
assert.doesNotMatch(panel, /CursorSurface/);

console.log("panel layout tests passed");
