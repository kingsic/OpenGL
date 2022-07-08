
precision highp float;
varying lowp vec2 v_texture;
uniform sampler2D u_colorMap;

void main() {
    vec2 var_xy = v_texture.xy;
    
    if (var_xy.y > 0.0 && var_xy.y < 0.5) {
        var_xy.y = var_xy.y + 0.25;
    } else {
        var_xy.y = var_xy.y - 0.25;
    }
    
    gl_FragColor = texture2D(u_colorMap, vec2(var_xy.x, var_xy.y));
    
//    vec2 temp = varyingTextCoordinate;
//    if (temp.x <= 0.5) {
//        temp.x = temp.x + 0.25;
//    } else {
//        temp.x = temp.x - 0.25;
//    }
//    gl_FragColor = texture2D(colorMap, temp);
}
