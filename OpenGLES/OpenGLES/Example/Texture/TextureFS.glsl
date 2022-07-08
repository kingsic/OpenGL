// 指定float的默认精度
precision highp float;
// 纹理坐标
varying lowp vec2 varyTextCoord;
// 纹理采样器（获取对应的纹理ID）
uniform sampler2D colorMap;

void main() {
    // texture2D(纹理采样器，纹理坐标)，获取对应坐标纹素
    // 纹理坐标添加到对应像素点上，即将读取的纹素赋值给内建变量 gl_FragColor
    gl_FragColor = texture2D(colorMap, varyTextCoord);
}
