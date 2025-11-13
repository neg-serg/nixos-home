import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Components
import qs.Services as Services
import qs.Settings
import "../../Helpers/RichText.js" as Rich
import "../../Helpers/WsIconMap.js" as WsMap
WidgetCapsule {
    id: root
    property string wsName: "?"
    property int wsId: -1
    property string submapName: ""
    // Vertical alignment of submap icon (px; negative moves up)
    property int submapBaselineAdjust: Theme.wsSubmapIconBaselineOffset
    property var submapDynamicMap: ({})
    // Map submap name to icon via helper + overrides + dynamic mapping
    function submapIconName(name) {
        const key = (name || "").toLowerCase().trim();
        if (submapDynamicMap && submapDynamicMap[key]) return submapDynamicMap[key];
        return WsMap.submapIcon(key, Theme.wsSubmapIconOverrides);
    }

    property color iconColor: Theme.accentHover
    property color gothicColor: Theme.textPrimary

    // Icon layout
    property int iconBaselineOffset:Theme.wsIconBaselineOffset
    property int iconSpacing:Theme.wsIconSpacing

    property int horizontalPadding: Math.max(4, Math.round(Theme.panelRowSpacingSmall * capsuleScale))
    property int verticalPadding: capsulePadding
    backgroundKey: "workspaces"
    paddingScale: paddingScaleFor(horizontalPadding)
    verticalPaddingScale: paddingScaleFor(verticalPadding)

    // RichText helpers are provided by Helpers/RichText.js

    function isPUA(cp) { return cp >= 0xE000 && cp <= 0xF8FF; }          // Private Use Area (icon fonts)
    function isOldItalic(cp){ return cp >= 0x10300 && cp <= 0x1034F; }
    // Wrap one char into colored span by category
    function spanForChar(ch) {
        const cp = ch.codePointAt(0);
        if (isPUA(cp)) { return Rich.colorSpan(iconColor, ch); }
        if (isOldItalic(cp)) { return Rich.colorSpan(gothicColor, ch); }
        if (ch === "·") return " ";
        return Rich.esc(ch);
    }

    // Decorate string with category spans
    function decorateName(name) {
        if (!name || typeof name !== "string") return Rich.esc(name || "");
        let out = "";
        for (let i = 0; i < name.length; ) {
            const cp = name.codePointAt(i);
            const ch = String.fromCodePoint(cp);
            out += spanForChar(ch);
            i += (cp > 0xFFFF) ? 2 : 1; // handle surrogate pairs
        }
        return out;
    }

    // Split leading PUA icon
    function leadingIcon(name) {
        if (!name || typeof name !== "string" || name.length === 0) return "";
        const cp = name.codePointAt(0);
        return isPUA(cp) ? String.fromCodePoint(cp) : "";
    }

    function restAfterLeadingIcon(name) {
        if (!name || typeof name !== "string" || name.length === 0) return "";
        const cp = name.codePointAt(0);
        if (!isPUA(cp)) return name;
        const skip = (cp > 0xFFFF) ? 2 : 1;
        // Trim immediate whitespace after icon
        return name.substring(skip).replace(/^\s+/, "");
    }


    // Final values for display
    property string iconGlyph: leadingIcon(wsName)
    property string restName: restAfterLeadingIcon(wsName)

    // Detect terminal workspace
    readonly property var _terminalIcons: ["\uf120", "\ue795", "\ue7a2"]
    property bool isTerminalWs: (function(){
        const rn = (restName || "").toLowerCase().trim();
        if (iconGlyph && _terminalIcons.indexOf(iconGlyph) !== -1) return true;
        if (rn.startsWith("term")) return true;
        if (rn.endsWith("term")) return true; // e.g., names like "dev-term"
        return false;
    })()

    // Fallback to workspace id if name is empty
    property string fallbackText: (wsId >= 0 ? String(wsId) : "?")

    // RichText decoration
    property string decoratedText: (restName && restName.length > 0)
                                   ? decorateName(restName)
                                   : decorateName(fallbackText)

    // UI
    Row {
        id: lineBox
        spacing: iconSpacing

        BaselineAlignedIcon {
            visible: root.submapName && root.submapName.length > 0
            mode: "material"
            labelRef: label
            anchors.verticalCenter: lineBox.verticalCenter
            scale: 0.88
            baselineOffsetToken: submapBaselineAdjust
            alignMode: "baseline"
            alignTarget: wsIcon
            icon: submapIconName(root.submapName)
            color: Theme.wsSubmapIconColor
            screen: Screen
        }

        BaselineAlignedIcon {
            id: wsIcon
            visible: iconGlyph.length > 0
            mode: "text"
            labelRef: label
            anchors.verticalCenter: lineBox.verticalCenter
            scale: 1.40
            baselineOffsetToken: iconBaselineOffset
            alignMode: "baseline"
            text: iconGlyph
            fontFamily: Theme.fontFamily
            color: iconColor
            padding: (root.isTerminalWs ? Theme.uiSpacingNone : Theme.wsIconInnerPadding)
        }

        Label {
            id: label
            textFormat: Text.RichText
            renderType: Text.NativeRendering
            text: decoratedText
            font.family: Theme.fontFamily
            font.weight: Font.Medium
            font.pixelSize: Theme.fontSizeSmall * root.capsuleScale
            color: Theme.textPrimary
            padding: Theme.wsLabelPadding
            leftPadding: (root.isTerminalWs ? Theme.wsLabelLeftPaddingTerminal : Theme.wsLabelLeftPadding)
            anchors.verticalCenter: lineBox.verticalCenter
            anchors.verticalCenterOffset: (wsIcon && wsIcon.currentOffset !== undefined) ? wsIcon.currentOffset : 0
        }
    }

    function updateDynamicMap(binds) {
        try {
            const dyn = {};
            const list = Array.isArray(binds) ? binds : [];
            for (let i = 0; i < list.length; i++) {
                const sub = (list[i] && list[i].submap) ? String(list[i].submap) : "";
                const n = sub.toLowerCase().trim();
                if (!n || n === "default" || n === "reset") continue;
                dyn[n] = submapIconName(n);
            }
            submapDynamicMap = dyn;
            try { const _ = Object.keys(dyn); } catch (_) {}
        } catch (e) {}
    }

    Connections {
        target: Services.HyprlandWatcher
        function onActiveWorkspaceIdChanged() {
            const id = Services.HyprlandWatcher.activeWorkspaceId;
            if (typeof id === "number") root.wsId = id;
        }
        function onActiveWorkspaceNameChanged() {
            root.wsName = Services.HyprlandWatcher.activeWorkspaceName || "";
        }
        function onCurrentSubmapChanged() { root.submapName = Services.HyprlandWatcher.currentSubmap || ""; }
        function onFocusedMonitorEvent() { Services.HyprlandWatcher.refreshWorkspace(); }
        function onBindsChanged() { updateDynamicMap(Services.HyprlandWatcher.binds); }
    }

    Component.onCompleted: {
        root.wsId = Services.HyprlandWatcher.activeWorkspaceId;
        root.wsName = Services.HyprlandWatcher.activeWorkspaceName;
        root.submapName = Services.HyprlandWatcher.currentSubmap;
        updateDynamicMap(Services.HyprlandWatcher.binds);
        Services.HyprlandWatcher.refreshWorkspace();
        Services.HyprlandWatcher.refreshBinds();
    }

    implicitWidth: horizontalPadding * 2 + lineBox.implicitWidth
}
