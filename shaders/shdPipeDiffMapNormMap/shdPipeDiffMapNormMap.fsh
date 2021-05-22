#extension GL_OES_standard_derivatives : enable

varying vec3 v_vPosition;
varying vec3 v_vNormal;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying mat3 v_mTBN;

uniform sampler2D u_sNormal;
uniform float u_fNoNormalMap;

vec3 getNormal()
{
    //if (u_fNoNormalMap >= 0.5)
    //{
    //    return normalize(v_mTBN * vec3(0.0, 0.0, 1.0));
    //}
    //else
    {
        vec3 n = texture2D(u_sNormal, v_vTexcoord).rgb;
        return normalize(v_mTBN * (2.0*n - 1.0));
    }
}

//vec3 getNormal()
//{
//    vec3 pos_dx = dFdx( v_vPosition );
//    vec3 pos_dy = dFdy( v_vPosition );
//    vec3 tex_dx = dFdx(vec3( v_vTexcoord, 0.0 ));
//    vec3 tex_dy = dFdy(vec3( v_vTexcoord, 0.0 ));
//    vec3 t = ( tex_dy.t * pos_dx - tex_dx.t * pos_dy ) / ( tex_dx.s * tex_dy.t - tex_dy.s * tex_dx.t );
//    vec3 ng = normalize( v_vNormal );
//    t = normalize( t - ng * dot(ng, t) );
//    vec3 b = normalize(cross( ng, t) );
//    mat3 tbn = mat3( t, b, ng );
//    vec3 n = texture2D( u_sNormal, v_vTexcoord ).rgb;
//    n = normalize( tbn * ((2.0 * n - 1.0) ));
//    
//    if (u_fNoNormalMap >= 0.5)
//    {
//        n = normalize(tbn * vec3(0.0, 0.0, 1.0));
//    }
//    
//    return n;
//}

void main()
{
    vec4 colour = v_vColour*texture2D(gm_BaseTexture, v_vTexcoord);
    
    vec3 n = getNormal();
    
    vec3 lightColour = vec3(0.2);
    //lightColour += 0.2*vec3(0.3, 0.5, 1.0)*max(0.0, dot(n, normalize(vec3( 0.0, -1.0, -0.5))));
    lightColour += vec3(0.8, 0.6, 0.4)*max(0.0, dot(n, normalize(vec3(0.0,  -1.0,  0.0))));
    lightColour = min(vec3(1.0), lightColour);
    
    colour.rgb *= lightColour;
    gl_FragColor = colour;
    
    //gl_FragColor = vec4(vec3(max(0.0, dot(n, normalize(vec3(0.0,  0.0,  1.0))))), 1.0);
    
    //gl_FragColor = texture2D(u_sNormal, v_vTexcoord);
    
    //gl_FragColor.rgb = normalize(0.5 + 0.5*vec3(v_mTBN[1][0], v_mTBN[1][1], v_mTBN[1][2]));
}