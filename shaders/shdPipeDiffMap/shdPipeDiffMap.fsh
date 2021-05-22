varying vec3 v_vPosition;
varying vec3 v_vNormal;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 colour = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    
    vec3 lightColour = vec3(0.2);
    lightColour += 0.2*vec3(0.3, 0.5, 1.0)*max(0.0, dot(normalize(v_vNormal), normalize(vec3( 0.0, -1.0, -0.5))));
    lightColour += vec3(0.8, 0.6, 0.4)*max(0.0, dot(normalize(v_vNormal), normalize(vec3(-1.0,  0.2,  0.6))));
    lightColour = min(vec3(1.0), lightColour);
    
    colour.rgb *= lightColour;
    gl_FragColor = colour;
}