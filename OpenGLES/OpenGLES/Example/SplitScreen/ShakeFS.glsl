
precision highp float;
uniform sampler2D u_colorMap;
varying vec2 v_texture;
uniform float Time;

void main() {
    float duration = 0.7;
    float maxScale = 1.1;
    float offset = 0.02;
    
    float progress = mod(Time, duration) / duration;
    vec2 offsetCoords = vec2(offset, offset) * progress;
    float scale = 1.0 + (maxScale - 1.0) * progress;
    
    float weakX = 0.5 + (v_texture.x - 0.5) / scale;
    float weakY = 0.5 + (v_texture.y - 0.5) / scale;
    vec2 weakTextureCoords = vec2(weakX, weakY);
    
    vec4 maskR = texture2D(u_colorMap, weakTextureCoords + offsetCoords);
    vec4 maskB = texture2D(u_colorMap, weakTextureCoords - offsetCoords);
    vec4 mask = texture2D(u_colorMap, weakTextureCoords);
    
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
}
