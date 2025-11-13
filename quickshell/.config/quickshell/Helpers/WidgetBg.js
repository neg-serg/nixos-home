.pragma library

const fallbackColor = "rgba(12, 14, 20, 0.2)";

function isColor(value) {
    return typeof value === "string" && value.length > 0;
}

function color(settingsObj, key, fallback) {
    const map = (settingsObj && settingsObj.widgetBackgrounds) || {};
    if (key && isColor(map[key])) return map[key];
    if (isColor(map.default)) return map.default;
    return fallback || fallbackColor;
}
