import QtQuick
import qs.Settings
import "../Helpers/CapsuleMetrics.js" as Capsule

QtObject {
    id: root

    property var screen: null
    readonly property real scale: Theme.scale(screen || Screen)
    readonly property var metrics: Capsule.metrics(Theme, scale)
    readonly property real padding: metrics.padding
    readonly property real inner: metrics.inner
    readonly property real height: metrics.height

    function paddingScaleFor(paddingPx) {
        if (!metrics || !metrics.padding) return 1;
        return paddingPx / metrics.padding;
    }
}
