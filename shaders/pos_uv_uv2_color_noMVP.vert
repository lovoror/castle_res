attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
varying mediump vec2 v_texCoord2;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec2 v_texCoord2;
#endif

void main()
{
    vec4 pos = CC_PMatrix * a_position;
    gl_Position = pos;
    v_fragmentColor = a_color;
    v_texCoord = a_texCoord;
    v_texCoord2 = (pos.xy / pos.w + 1.0) * 0.5;
}