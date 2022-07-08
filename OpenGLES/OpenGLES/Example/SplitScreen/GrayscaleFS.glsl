
precision highp float;
uniform sampler2D u_colorMap;
varying vec2 v_texture;
const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main() {
    vec4 mask = texture2D(u_colorMap, v_texture);
    float luminance = dot(mask.rgb, W);
    gl_FragColor = vec4(vec3(luminance), 1.0);
}
