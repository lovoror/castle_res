varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec4 v_addColor;

void main()
{
    gl_FragColor = v_fragmentColor * (texture2D(CC_Texture0, v_texCoord) + v_addColor);
}