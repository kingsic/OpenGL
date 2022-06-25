attribute vec4 a_position;
attribute vec4 a_positionColor;

uniform mat4 u_projectionMatrix;
uniform mat4 u_modelViewMatrix;

varying lowp vec4 v_color;


void main() {
    v_color = a_positionColor;
    vec4 vPos = u_projectionMatrix * u_modelViewMatrix * a_position;
    gl_Position = vPos;
}
