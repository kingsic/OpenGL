//precision highp float;
varying lowp vec2 varyTextureCoordinate;
// 2D纹理贴图
uniform sampler2D colorMap;

void main() {
    gl_FragColor = texture2D(colorMap, varyTextureCoordinate);
}
