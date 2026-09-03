const assert = require("node:assert/strict");
const Model = require("../Model.js");

const groupInfo = {
  type: "sssa{sv}a(sssssssbsa{sv})",
  data: ["Default", "mozc", "us", {}, [
    ["keyboard-us", "Keyboard - English (US)", "", "input-keyboard", "en", "en", "keyboard", true, "", {}],
    ["mozc", "Mozc", "", "fcitx_mozc", "あ", "ja", "mozc", true, "", {}],
    ["rime", "Rime", "中州韻", "fcitx-rime", "中", "zh", "rime", true, "", {}]
  ]]
};

const methods = Model.methodsFromGroupInfo(groupInfo);
assert.deepEqual(methods, [
  { id: "keyboard-us", name: "Keyboard - English (US)", nativeName: "", icon: "input-keyboard", label: "en", language: "en", addon: "keyboard", configurable: true },
  { id: "mozc", name: "Mozc", nativeName: "", icon: "fcitx_mozc", label: "あ", language: "ja", addon: "mozc", configurable: true },
  { id: "rime", name: "Rime", nativeName: "中州韻", icon: "fcitx-rime", label: "中", language: "zh", addon: "rime", configurable: true }
]);

assert.equal(Model.displayName(methods[2]), "中州韻");
assert.equal(Model.displayName(methods[1]), "Mozc");
assert.equal(Model.displayLabel(methods[2]), "中");
assert.equal(Model.displayLabel({ id: "future-engine", name: "Future Engine", label: "" }), "FE");

assert.deepEqual(
  Model.triggerKeysFromConfig({ data: [{ data: {
    Hotkey: { data: {
      TriggerKeys: { data: {
        0: { type: "s", data: "Control+space" },
        1: { type: "s", data: "Zenkaku_Hankaku" }
      } }
    } }
  } }] }),
  ["Ctrl+Space", "Zenkaku/Hankaku"]
);

assert.deepEqual(Model.triggerKeysFromConfig({}), []);
assert.equal(Model.isKeyboard({ id: "keyboard-us", addon: "keyboard" }), true);
assert.equal(Model.isKeyboard({ id: "hangul", addon: "hangul" }), false);
assert.equal(Model.methodDescription(methods[0]), "English · Direct input");
assert.equal(Model.methodDescription(methods[1]), "Japanese");
assert.equal(Model.methodDescription(methods[2]), "Chinese");
assert.equal(Model.methodDescription({ language: "ko", addon: "hangul" }), "Korean");
assert.equal(Model.methodDescription({ language: "vi", addon: "unikey" }), "VI");

console.log("model tests passed");
