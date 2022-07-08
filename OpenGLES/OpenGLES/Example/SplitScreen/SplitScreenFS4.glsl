
precision highp float;
varying vec2 v_texture;
uniform sampler2D u_colorMap;

void main() {
    vec2 var_xy = v_texture.xy;
    
    if (var_xy.x <= 0.5) {
        var_xy.x = var_xy.x * 2.0;
    } else {
        var_xy.x = (var_xy.x - 0.5) * 2.0;
    }
    
    if (var_xy.y <= 0.5) {
        var_xy.y = var_xy.y * 2.0;
    } else {
        var_xy.y = (var_xy.y - 0.5) * 2.0;
    }
    
    gl_FragColor = texture2D(u_colorMap, vec2(var_xy.x, var_xy.y));
}
