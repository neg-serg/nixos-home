import QtQuick
import qs.Settings
import "../Helpers/Color.js" as Color
import "../Helpers/Utils.js" as Utils

Item {
    id: root
    // Kind can be: "diagonal", "vertical", "horizontal"
    // Use string for simplicity and readability.
    property string kind: "diagonal"

    // DPI awareness: pass screen if available to scale thickness
    property var screen

    // Visual tokens
    property color color: Theme.borderSubtle
    // Generic opacity applied via color alpha (renamed to avoid clashing with Item.opacity)
    property real sepOpacity: Theme.uiSeparatorOpacity
    // Logical thickness before scaling (defaults vary per kind)
    property real thickness: (kind === "diagonal") ? Theme.uiSeparatorDiagonalThickness : Theme.uiSeparatorThickness
    property int radius: Theme.uiSeparatorRadius

    // Diagonal-only tuning
    property real angleDeg: Theme.uiSeparatorDiagonalAngleDeg
    property int inset:Theme.uiSeparatorDiagonalInset

    // Stripe sub-settings (generic)
    property bool stripeEnabled:true
    // 0..1, lower = closer to black
    property real stripeBrightness:Theme.uiSeparatorStripeBrightness
    property color stripeColor: Color.towardsBlack(Theme.accentPrimary, 1 - stripeBrightness)
    property real stripeOpacity:Theme.uiSeparatorStripeOpacity
    // Portion of thickness used by the accent stripe (0..1)
    property real stripeRatio:Utils.clamp(Theme.uiSeparatorStripeRatio, 0, 1)
    // Edge placement for stripe
    // For diagonal/vertical: true = right edge, false = left edge
    property bool stripeOnRight:true
    // For horizontal: true = bottom edge, false = top edge
    property bool stripeOnBottom:true

    // Note: legacy 'alpha' alias removed; use sepOpacity

    // Implicit sizing defaults per kind
    implicitWidth: (kind === "diagonal") ? Theme.uiDiagonalSeparatorImplicitWidth
                  : (kind === "vertical") ? Math.max(1, Math.round(thickness * Theme.scale(root.screen)))
                  : 12
    implicitHeight: (kind === "diagonal") ? Theme.uiDiagonalSeparatorImplicitHeight
                   : (kind === "horizontal") ? Math.max(1, Math.round(thickness * Theme.scale(root.screen)))
                   : 12

    // --- Diagonal ---
    ShaderEffect {
        id: diag
        visible: root.kind === "diagonal"
        anchors.centerIn: parent
        width: Math.max(1, Math.round(root.thickness * Theme.scale(root.screen)))
        height: Math.max(1, Math.round(Math.hypot(root.width, root.height) - root.inset * 2))
        rotation: root.angleDeg
        transformOrigin: Item.Center
        // Base trapezoid parameters
        property color baseColor: Qt.rgba(root.color.r, root.color.g, root.color.b, root.sepOpacity)
        property color accentColor: Qt.rgba(root.stripeColor.r, root.stripeColor.g, root.stripeColor.b, root.stripeOpacity)
        property bool accentEnabled: root.stripeEnabled && root.stripeRatio > 0
        property bool accentOnRight: root.stripeOnRight
        property real accentRatio: Utils.clamp(root.stripeRatio, 0, 1)
        property real topInsetPx: Math.max(0, root.inset)
        property real bottomInsetPx: 0
        property real tiltNorm: Utils.clamp(root.angleDeg / 90.0, -1, 1)
        fragmentShader: "
            uniform lowp vec4 baseColor;
            uniform lowp vec4 accentColor;
            uniform bool accentEnabled;
            uniform bool accentOnRight;
            uniform float accentRatio;
            uniform float topInsetPx;
            uniform float bottomInsetPx;
            uniform float tiltNorm;
            uniform float width;
            uniform float height;
            varying highp vec2 qt_TexCoord0;

            void main() {
                if (width <= 0.0 || height <= 0.0) discard;
                float y = qt_TexCoord0.y * height;
                float progress = y / height;
                float currentInset = mix(topInsetPx, bottomInsetPx, progress);
                currentInset = clamp(currentInset, 0.0, width * 0.49);
                float centerShift = tiltNorm * (progress - 0.5) * width * 0.6;
                float innerWidth = width - (currentInset * 2.0);
                float minX = (width - innerWidth) * 0.5 + centerShift;
                float maxX = (width + innerWidth) * 0.5 + centerShift;
                minX = clamp(minX, 0.0, width);
                maxX = clamp(maxX, 0.0, width);
                if (minX >= maxX) discard;
                float x = qt_TexCoord0.x * width;
                if (x < minX || x > maxX) discard;

                lowp vec4 color = baseColor;
                if (accentEnabled && accentRatio > 0.0) {
                    float inner = max(1e-4, maxX - minX);
                    float stripeWidth = clamp(accentRatio, 0.0, 1.0) * inner;
                    if (accentOnRight) {
                        if (x > maxX - stripeWidth) color = accentColor;
                    } else {
                        if (x < minX + stripeWidth) color = accentColor;
                    }
                }
                gl_FragColor = color;
            }
        "
    }

    // --- Vertical ---
    Rectangle {
        id: vert
        visible: root.kind === "vertical"
        anchors.fill: parent
        width: Math.max(1, Math.round(root.thickness * Theme.scale(root.screen)))
        radius: root.radius
        color: Qt.rgba(root.color.r, root.color.g, root.color.b, root.sepOpacity)
        antialiasing: false
        layer.enabled: false

        Rectangle {
            id: vertStripe
            visible: root.stripeEnabled && root.stripeRatio > 0
            width: Math.max(1, Math.round(vert.width * Utils.clamp(root.stripeRatio, 0, 1)))
            height: parent.height
            color: root.stripeColor
            opacity: root.stripeOpacity
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: root.stripeOnRight ? undefined : parent.left
            anchors.right: root.stripeOnRight ? parent.right : undefined
            antialiasing: false
        }
    }

    // --- Horizontal ---
    Rectangle {
        id: hori
        visible: root.kind === "horizontal"
        anchors.fill: parent
        height: Math.max(1, Math.round(root.thickness * Theme.scale(root.screen)))
        radius: root.radius
        color: Qt.rgba(root.color.r, root.color.g, root.color.b, root.sepOpacity)
        antialiasing: false
        layer.enabled: false

        Rectangle {
            id: horiStripe
            visible: root.stripeEnabled && root.stripeRatio > 0
            height: Math.max(1, Math.round(hori.height * Utils.clamp(root.stripeRatio, 0, 1)))
            width: parent.width
            color: root.stripeColor
            opacity: root.stripeOpacity
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: root.stripeOnBottom ? undefined : parent.top
            anchors.bottom: root.stripeOnBottom ? parent.bottom : undefined
            antialiasing: false
        }
    }
}
