
precision highp float;
uniform sampler2D u_colorMap;
varying vec2 v_texture;
uniform float Time;
const float PI = 3.1415926;

float rand(float n)
{
    return fract(sin(n) * 12345.12345);
}

void main() {
    float maxJitter = 0.06;
    float duration = 0.3;
    float colorROffset = 0.01;
    float colorBOffset = -0.025;
    
    float time = mod(Time, duration * 2.0);
    float amplitude = abs(sin(time * (PI / duration)));
    
    float jitter = rand(v_texture.y) * 2.0 - 1.0;
    
    bool needOffset = abs(jitter) < maxJitter * amplitude;
    
    float textureX = v_texture.x + (needOffset ? jitter : (jitter * amplitude * 0.006));
    
    vec2 textureCoords = vec2(textureX, v_texture.y);
    
    vec4 mask = texture2D(u_colorMap, textureCoords);
    vec4 maskR = texture2D(u_colorMap, textureCoords + vec2(colorROffset * amplitude, 0.0));
    vec4 maskB = texture2D(u_colorMap, textureCoords + vec2(colorBOffset * amplitude, 0.0));
    
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
}
