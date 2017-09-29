attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec4 v_addColor;

void main()
{
    gl_Position = CC_PMatrix * a_position;
    v_fragmentColor = a_color;

    vec2 c2 = floor(a_texCoord.xy * 0.1);
    vec2 c0 = floor(c2 * 0.001);
    vec2 c1 = (c2 - c0 * 1000.0) / 255.0;
    c0 /= 255.0;

    v_addColor = vec4(c0.x, c1.x, c0.y, c1.y);
    v_texCoord = a_texCoord.xy - c2 * 10.0;
}