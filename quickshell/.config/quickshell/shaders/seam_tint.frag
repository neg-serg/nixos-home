#version 440 core
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform qt_ubuf {
    vec4 tintColor;
    vec4 params0; // x=leftTop, y=leftBottom, z=rightTop, w=rightBottom
    vec4 params1; // x=featherLeft, y=featherRight, z=opacity
};

float edgeMask(float coord, float edge, float feather, bool isLeftEdge) {
    float featherWidth = max(feather, 1e-4);
    if (isLeftEdge) {
        return smoothstep(edge - featherWidth, edge + featherWidth, coord);
    }
    return 1.0 - smoothstep(edge - featherWidth, edge + featherWidth, coord);
}

void main() {
    float y = clamp(qt_TexCoord0.y, 0.0, 1.0);
    float leftEdge = mix(params0.x, params0.y, y);
    float rightEdge = mix(params0.z, params0.w, y);

    if (leftEdge >= rightEdge) {
        discard;
    }

    float x = clamp(qt_TexCoord0.x, 0.0, 1.0);
    float leftFeather = clamp(params1.x, 1e-4, 0.25);
    float rightFeather = clamp(params1.y, 1e-4, 0.25);
    float opacity = clamp(params1.z, 0.0, 1.0);

    float leftMask = edgeMask(x, leftEdge, leftFeather, true);
    float rightMask = edgeMask(x, rightEdge, rightFeather, false);
    float mask = clamp(min(leftMask, rightMask), 0.0, 1.0);

    float alpha = tintColor.a * opacity * mask;
    if (alpha <= 0.0001) {
        discard;
    }

    fragColor = vec4(tintColor.rgb, alpha);
}
