varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec4 v_addColor;

void main()
{
    vec4 c = texture2D(CC_Texture0, v_texCoord);
    float a = c.w * v_fragmentColor.w;
    
    c.xyz += v_addColor.xyz * a;
    c.w += v_addColor.w;

    gl_FragColor = v_fragmentColor * c;
}