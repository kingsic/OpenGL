
precision highp float;
uniform sampler2D u_colorMap;
varying vec2 v_texture;

void main() {
    gl_FragColor = texture2D(u_colorMap, vec2(v_texture.x, 1.0 - v_texture.y));
}
