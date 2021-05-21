varying vec3 v_vPosition;
varying vec3 v_vNormal;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_sDissolve;

void main()
{
    vec4 colour = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    
    vec4 dissolve = texture2D(u_sDissolve, v_vTexcoord);
    if (length(dissolve.rgb) < (254.0/255.0)) discard;
    
    vec3 lightColour = vec3(0.3);
    lightColour += 0.2*vec3(0.3, 0.5, 1.0)*max(0.0, dot(normalize(v_vNormal), normalize(vec3( 0.0, -1.0, -0.5))));
    lightColour += vec3(1.0, 0.6, 0.3)*max(0.0, dot(normalize(v_vNormal), normalize(vec3(-1.0,  0.2,  0.6))));
    lightColour = min(vec3(1.0), lightColour);
    
    colour.rgb *= lightColour;
    gl_FragColor = colour;
}