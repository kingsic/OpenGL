
precision highp float;
uniform sampler2D u_colorMap;
varying vec2 v_texture;

void main() {
    vec4 mask = texture2D(u_colorMap, v_texture);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
