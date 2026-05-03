## WarbandComms UI Control Reference

This document captures the XML schema conventions, available control templates, reusable Lua helpers, and the copy-ready reference file for adding new controls to the WarbandComms config window. Reference this at the start of any session involving `config.xml`, `config.lua`, or new UI control additions.

---

### XML Schema

All XML files use `EASystem.xsd` (not the older game-default schema). This is what enables standard WAR control templates to bind correctly.

```xml
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:noNamespaceSchemaLocation="EASystem.xsd"
```

---

### Available Control Templates

**Buttons**
- `EA_Button_Default` — standard clickable button
- `EA_Button_DefaultResizeable` — same, resizable width
- `EA_Button_DefaultCheckBox` — checkbox with label
- `EA_Button_DefaultMinus` — small minus-style button

**Edit boxes**
- `EA_EditBox_DefaultFrame` — text input with a visible frame

**Combo boxes**
- `EA_ComboBox_DefaultResizable` — dropdown, full width
- `EA_ComboBox_DefaultResizableSmall` — dropdown, compact

**Scroll containers**
- `ScrollWindow` + `VerticalScrollbar` using `EA_ScrollBar_DefaultVerticalChain`

---

### Reusable Lua Helpers (in `config.lua`)

These helpers normalize control behavior across template quirks:

| Helper | Purpose |
|---|---|
| `WarbandComms.UIEnsureCheckboxState(name, value)` | Force checkbox visual state to match a boolean without firing the toggle handler |
| `WarbandComms.UIResolveCheckboxToggle(name, settingKey)` | Read current checkbox state and write the toggled value back to settings |
| `WarbandComms.UISetEditBoxTextIfExists(name, text)` | Safe edit box text setter; no-ops if the control doesn't exist yet |
| `WarbandComms.UIPopulateComboBox(name, items, selectedValue)` | Populate a combobox with an item list and pre-select by value |

Tooltip helpers used by config labels:

| Helper | Purpose |
|---|---|
| `WarbandComms.ShowConfigLabelTooltip()` | Shows label tooltip text based on active config label control |
| `WarbandComms.HideConfigLabelTooltip()` | Clears tooltip for the active config label control |

---

### Reference Handlers (wired in `config.lua`)

These are stub handlers connected to the copy-paste templates in `ui-controls-reference.xml`:

| Handler | Trigger |
|---|---|
| `WarbandComms.OnReferenceToggle` | Checkbox toggle |
| `WarbandComms.OnReferenceNumericChanged` | +/- numeric control |
| `WarbandComms.OnReferenceComboChanged` | Combobox selection |
| `WarbandComms.OnReferenceAdd` | Add button in a list |
| `WarbandComms.OnReferenceDelete` | Delete/remove button in a list |

---

### Copy-Ready Templates

`ui-controls-reference.xml` — **not loaded by `WarbandComms.mod`** — contains complete, working XML snippets for:

- Checkbox rows (label + checkbox)
- Numeric input rows (label + value + `[-]`/`[+]` buttons)
- Combobox rows (label + dropdown)
- Add/remove button pairs
- Scroll window shells

To add a new control: copy the relevant block from `ui-controls-reference.xml` into `config.xml`, rename the `$parent` prefix to match the new control's name, add corresponding `InitConfig` label/state setup in `config.lua`, and wire event handlers.

---

### Config Layout Constants (in `config.lua`)

| Constant | Value | Usage |
|---|---|---|
| `leftColumnX` | `20` | Left-side label/control x position |
| `rightColumnX` | `350` | Right-side label/control x position |
| Row spacing | Dynamic | Computed from `baseY` + row index × row height |

Tracker section and notification section each compute their own max row count; window height is set to whichever is taller.

---

### Current UX Conventions

Use these as the default conventions unless a task explicitly asks to change them.

1. Tooltip scope is label-only.
- Add tooltip event handlers to labels, not to value buttons, minus/plus buttons, or checkbox toggles.
- Standard XML wiring on labels:
```xml
<EventHandlers>
	<EventHandler event="OnMouseOver" function="WarbandComms.ShowConfigLabelTooltip" />
	<EventHandler event="OnMouseOverEnd" function="WarbandComms.HideConfigLabelTooltip" />
</EventHandlers>
```

2. Dynamic row labels inherit tooltip behavior from the config template.
- Tracker and notification rows are created from `WarbandCommsConfigTemplate` in `config-template.xml`.
- Keep tooltip handlers on `$parentLabel` in the template so dynamic rows remain consistent.

3. Tooltip text source is centralized in `config.lua`.
- Static settings use `CONFIG_LABEL_TOOLTIPS` keyed by config label suffix.
- Dynamic row labels use fallback placeholder text resolved by suffix matching (`...Label`, `...NOTIFYLabel`).

4. Value text color between `[-]` and `[+]` is white.
- In `ApplyControlLabelStyling()`, value labels use `COLORS.valueWhite`.
- Plus/minus labels are still styled separately.
