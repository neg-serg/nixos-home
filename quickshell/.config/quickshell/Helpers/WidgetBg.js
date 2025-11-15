.pragma library

const fallbackColor = "rgba(12, 14, 20, 0.8)";

function isColor(value) {
    return typeof value === "string" && value.length > 0;
}

function color(settingsObj, key, fallback) {
    const map = (settingsObj && settingsObj.widgetBackgrounds) || {};
    let resolved;
    if (key && isColor(map[key])) {
        resolved = map[key];
    } else if (isColor(map.default)) {
        resolved = map.default;
    } else {
        resolved = fallback || fallbackColor;
    }
    try {
        console.debug("[WidgetBg.color]", key || "default", resolved);
    } catch (e) {}
    return resolved;
}
