// 顶点坐标
attribute vec4 position;
// 纹理坐标
attribute vec2 textCoordinate;
// 纹理坐标
varying lowp vec2 varyTextCoord;

void main(){
    // 通过 varying 修饰的 varyTextCoord, 将纹理坐标传递到片元着色器
    varyTextCoord = textCoordinate;
    // 给内建变量 gl_Position 赋值
    gl_Position = position;
}
