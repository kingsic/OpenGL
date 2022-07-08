
precision highp float;
uniform sampler2D u_colorMap;
varying vec2 v_texture;
const float PI = 3.14159265;
const float uD = 180.0;
const float uR = 0.5;

void main() {
    ivec2 ires = ivec2(512, 512);
    float Res = float(ires.s);
    
    vec2 st = v_texture;
    float Radius = Res * uR;
    
    vec2 xy = st * Res;
    
    vec2 dxy = xy - vec2(Res/2.0, Res/2.0);
    float r = length(dxy);
    
    float beta = atan(dxy.y, dxy.x) + radians(uD) * 2.0 * (1.0-(r/Radius)*(r/Radius));
    
    if (r <= Radius)
    {
        xy = Res/2.0 + r * vec2(cos(beta), sin(beta));
    }
    
    st = xy/Res;

    vec3 irgb = texture2D(u_colorMap, st).rgb;
    
    gl_FragColor = vec4(irgb, 1.0);
}
