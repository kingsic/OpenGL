
attribute vec4 a_position;
attribute vec2 a_texture;
varying vec2 v_texture;
uniform float Time;
const float PI = 3.1415926;

void main() {
    float duration = 0.6;
    float maxAmplitude = 0.3;
    
    float time = mod(Time, duration);
    
    float amplitude = 1.0 + maxAmplitude * abs(sin(time * (PI / duration)));
    
    gl_Position = vec4(a_position.x * amplitude, a_position.y * amplitude, a_position.zw);
  
    v_texture = a_texture;
}
