#version 440 core
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform qt_ubuf {
    vec4 baseColor;
    vec4 params0; // x=tiltSign (-1 left, +1 right), y=taperTop, z=taperBottom, w=opacity
};

void main() {
    float tiltSign = params0.x;
    float taperTop = params0.y;
    float taperBottom = params0.z;
    float effectOpacity = params0.w;

    float y = clamp(qt_TexCoord0.y, 0.0, 1.0);
    float frac = clamp(mix(taperTop, taperBottom, y), 1e-3, 1.0);
    float x = clamp(qt_TexCoord0.x, 0.0, 1.0);

    if (tiltSign > 0.0) {
        if (x < 1.0 - frac) discard;
    } else {
        if (x > frac) discard;
    }

    fragColor = baseColor * effectOpacity;
}
