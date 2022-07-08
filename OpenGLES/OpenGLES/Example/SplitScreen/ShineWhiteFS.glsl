
precision highp float;
uniform sampler2D u_colorMap;
varying vec2 v_texture;
uniform float Time;
const float PI = 3.1415926;

void main() {
    float duration = 0.6;
    float time = mod(Time, duration);
    vec4 whiteMask = vec4(1.0, 1.0, 1.0, 0.1);
    float amplitude = abs(sin(time * (PI / duration)));
    vec4 mask = texture2D(u_colorMap, v_texture);
    
    gl_FragColor = mask * (1.0 - amplitude) + whiteMask * amplitude;
}
