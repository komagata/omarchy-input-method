function methodsFromGroupInfo(groupInfo) {
  if (!groupInfo || !Array.isArray(groupInfo.data) || !Array.isArray(groupInfo.data[4])) return []
  return groupInfo.data[4].map(function(entry) {
    return {
      id: String(entry[0] || ""),
      name: String(entry[1] || ""),
      nativeName: String(entry[2] || ""),
      icon: String(entry[3] || ""),
      label: String(entry[4] || ""),
      language: String(entry[5] || ""),
      addon: String(entry[6] || ""),
      configurable: entry[7] === true
    }
  }).filter(function(method) { return method.id !== "" })
}

function displayName(method) {
  if (!method) return "Unknown"
  if (String(method.id || "") === "keyboard-us") return "English (US)"
  return String(method.nativeName || method.name || method.id || "Unknown")
}

function displayLabel(method) {
  if (!method) return "?"
  // Language identifiers, not live conversion-mode indicators.
  var language = String(method.language || "").split(/[-_]/)[0].toLowerCase()
  var symbols = { ja: "あ", zh: "中", ko: "한", en: "A", ru: "Я", ar: "ع", th: "ก" }
  if (Object.prototype.hasOwnProperty.call(symbols, language)) return symbols[language]
  return /^[a-z]{2,3}$/.test(language) ? language : "?"
}

function panelLabel(method) {
  return displayLabel(method)
}

function triggerKeysFromConfig(config) {
  try {
    var rawKeys = config.data[0].data.Hotkey.data.TriggerKeys.data
    var keys = []
    if (Array.isArray(rawKeys)) {
      keys = rawKeys
    } else if (rawKeys && typeof rawKeys === "object") {
      Object.keys(rawKeys).sort(function(a, b) { return Number(a) - Number(b) }).forEach(function(key) {
        var value = rawKeys[key]
        keys.push(value && typeof value === "object" && "data" in value ? value.data : value)
      })
    }
    return keys.map(formatShortcut).filter(function(key) { return key !== "" })
  } catch (e) {
    return []
  }
}

function formatShortcut(value) {
  return String(value || "")
    .replace(/Control/g, "Ctrl")
    .replace(/space/g, "Space")
    .replace(/Zenkaku_Hankaku/g, "Zenkaku/Hankaku")
    .replace(/\+/g, "+")
}

function isKeyboard(method) {
  return !!method && (String(method.addon || "") === "keyboard" || String(method.id || "").indexOf("keyboard-") === 0)
}

function methodDescription(method) {
  if (!method) return ""
  var language = String(method.language || "").split(/[-_]/)[0].toLowerCase()
  var names = { en: "English", ja: "Japanese", zh: "Chinese", ko: "Korean" }
  var name = names[language] || language.toUpperCase()
  return isKeyboard(method) ? (name ? name + " · Direct input" : "Direct input") : name
}

function parseStatus(raw) {
  try {
    var parsed = JSON.parse(String(raw || ""))
    var methods = methodsFromGroupInfo(parsed.groupInfo)
    var current = null
    for (var i = 0; i < methods.length; i++) {
      if (methods[i].id === String(parsed.currentId || "")) current = methods[i]
    }
    return {
      available: parsed.available === true,
      state: Number(parsed.state || 0),
      currentId: String(parsed.currentId || ""),
      current: current,
      methods: methods,
      triggerKeys: triggerKeysFromConfig(parsed.config)
    }
  } catch (e) {
    return { available: false, state: 0, currentId: "", current: null, methods: [], triggerKeys: [] }
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    methodsFromGroupInfo: methodsFromGroupInfo,
    displayName: displayName,
    displayLabel: displayLabel,
    panelLabel: panelLabel,
    triggerKeysFromConfig: triggerKeysFromConfig,
    formatShortcut: formatShortcut,
    isKeyboard: isKeyboard,
    methodDescription: methodDescription,
    parseStatus: parseStatus
  }
}
