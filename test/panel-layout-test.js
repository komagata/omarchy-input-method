const assert = require("node:assert/strict");
const fs = require("node:fs");

const panel = fs.readFileSync(`${__dirname}/../InputMethodPanel.qml`, "utf8");

assert.match(panel, /text: "↑↓ Select · Enter Apply · C Configure"/);
assert.doesNotMatch(panel, /Right-click bar to toggle/);

console.log("panel layout tests passed");
