varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;

void main()
{
    gl_FragColor = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    
    gl_FragColor.rgb *= mix(0.5, 1.0, max(0.0, dot(v_vNormal, normalize(vec3(3.0, 2.0, 1.0)))));
}