attribute vec4 a_position;
attribute vec2 a_texCoord;

#ifdef GL_ES
varying mediump vec2 v_texCoord;
varying mediump vec2 v_texCoord2;
#else
varying vec2 v_texCoord;
varying vec2 v_texCoord2;
#endif

void main()
{
    vec4 pos = CC_MVPMatrix * a_position;
    gl_Position = pos;
    v_texCoord = a_texCoord;
    v_texCoord2 = (pos.xy / pos.w + 1.0) * 0.5;
}