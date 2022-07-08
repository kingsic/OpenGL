precision highp float;
uniform sampler2D u_colorMap;
varying vec2 v_texture;
uniform float Time;

void main() {
    float duration = 0.7;
    float maxAlpha = 0.4;
    float maxScale = 1.8;
    
    float progress = mod(Time, duration) / duration;
    float alpha = maxAlpha * (1.0 - progress);
    float scale = 1.0 + (maxScale - 1.0) * progress;
    
    float weakX = 0.5 + (v_texture.x - 0.5) / scale;
    float weakY = 0.5 + (v_texture.y - 0.5) / scale;
    vec2 weakTextureCoords = vec2(weakX, weakY);
    
    vec4 weakMask = texture2D(u_colorMap, weakTextureCoords);
    
    vec4 mask = texture2D(u_colorMap, v_texture);
    
    gl_FragColor = mask * (1.0 - alpha) + weakMask * alpha;
}
