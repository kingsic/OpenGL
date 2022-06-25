attribute vec4 position;
attribute vec2 textureCoordinate;
uniform mat4 rotateMatrix;
varying lowp vec2 varyTextureCoordinate;


void main() {
    varyTextureCoordinate = textureCoordinate;
    
    gl_Position = position * rotateMatrix;
}
