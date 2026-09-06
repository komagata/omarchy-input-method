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
assert.equal(Model.displayName({ id: "keyboard-us", name: "キーボード - 英語 (US)", language: "en", addon: "keyboard" }), "English (US)");
assert.equal(Model.displayLabel(methods[2]), "中");
assert.equal(Model.displayLabel({ id: "future-engine", name: "Future Engine", label: "" }), "?");
for (const [label, language, expected] of [
  ["Hazkey", "ja", "あ"], ["Karukan", "ja_JP", "あ"], ["Zenzai", "ja", "あ"],
  ["あ", "ja", "あ"], ["한", "ko", "한"], ["中", "zh", "中"],
  ["Long Chinese label", "zh-Hant", "中"], ["Long Korean label", "ko", "한"],
  ["en", "en", "A"], ["", "DE_de", "de"], ["", "fil", "fil"],
  ["", "ru", "Я"], ["", "ar", "ع"], ["", "th", "ก"],
  ["", "", "?"], ["", "invalid", "?"], ["<>", "ja", "あ"],
  ["\u200b", "ja", "あ"], ["a\nb", "en", "A"], ["あ", "", "?"]
]) {
  assert.equal(Model.displayLabel({ label, language }), expected);
  assert.equal(Model.panelLabel({ label, language }), expected);
}
assert.equal(Model.displayLabel(null), "?");

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

assert.equal(Model.panelLabel(null), "?");

console.log("model tests passed");
