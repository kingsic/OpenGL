
precision highp float;
varying vec2 v_texture;
uniform sampler2D u_colorMap;

void main() {
    vec2 var_xy = v_texture.xy;
    
    if (var_xy.y > 0.0 && var_xy.y < 1.0/3.0) {
        var_xy.y = var_xy.y + 1.0/3.0;
    } else if (var_xy.y > 2.0/3.0 ) {
        var_xy.y = var_xy.y - 1.0/3.0;
    }
    
    gl_FragColor = texture2D(u_colorMap,vec2(var_xy.x, var_xy.y));
}
