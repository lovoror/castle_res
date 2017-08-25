#ifdef GL_ES
precision lowp float;
#endif

varying vec2 v_texCoord;

uniform vec4 global_color;

void main()
{
    gl_FragColor = texture2D(CC_Texture0, v_texCoord) * global_color;
}