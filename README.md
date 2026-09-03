# Omarchy Input Methods

An Omarchy bar widget for the input methods already configured in Fcitx 5. It shows the current input method, opens a keyboard-accessible switcher, displays the configured trigger keys, and launches the Fcitx configuration tool.

The list comes from the active Fcitx group rather than a hardcoded language list. Mozc, Hazkey, Rime, Hangul, and future engines can therefore share the same interface.

This plugin manages switching and visibility. Installing input engines and making them available immediately after a fresh Omarchy installation are separate setup concerns.

## Requirements

- Omarchy Quattro
- Fcitx 5
- `busctl` and `jq` (included with Omarchy)
- `fcitx5-configtool` for the Configure button

## Install

```bash
omarchy plugin add https://github.com/komagata/omarchy-input-method.git
omarchy plugin enable komagata.input-method
```

## Use

- Left-click the bar label to open the input-method list.
- Right-click the bar label to toggle Fcitx.
- Use Up/Down and Enter in the panel to select an input method.
- Press `C` in the panel to open Fcitx configuration.

## Remove

```bash
omarchy plugin remove komagata.input-method
```

## Development

```bash
./test/run
omarchy plugin validate .
qmllint -I "$OMARCHY_PATH/shell" ./*.qml
```

## Prior art

This project was informed by [Praveensenpai/omarchy-japanese-ime](https://github.com/Praveensenpai/omarchy-japanese-ime), [eric8810/omarchy-input-method](https://github.com/eric8810/omarchy-input-method), and [ddload87/omarchy-input-method](https://github.com/ddload87/omarchy-input-method). It uses a separate implementation and a namespaced plugin ID so it can coexist with earlier plugins.

## License

MIT
