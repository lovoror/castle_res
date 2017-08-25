#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec2 v_texCoord2;

uniform vec4 pp_params;

void main()
{
    vec4 c = texture2D(CC_Texture0, v_texCoord) * v_fragmentColor;
    float sx = pp_params.x * pp_params.z * 40.0f;
    float sy = pp_params.y * pp_params.z * 40.0f;
    vec2 uv = v_texCoord2 + vec2(dot(c.xyz, vec3(sx, sx, sx)), dot(c.xyz, vec3(sy, sy, sy)));
    gl_FragColor = texture2D(CC_Texture1, uv);
}