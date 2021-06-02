attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour0;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour1;

varying vec3 v_vPosition;
varying vec3 v_vNormal;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying mat3 v_mTBN;
varying vec3 v_vTangent;
varying vec3 v_vBitangent;

void main()
{
    vec4 wsPos = gm_Matrices[MATRIX_WORLD]*vec4(in_Position, 1.0);
    gl_Position = gm_Matrices[MATRIX_PROJECTION]*gm_Matrices[MATRIX_VIEW]*wsPos;
    
    v_vPosition = wsPos.xyz;
    v_vNormal   = normalize((gm_Matrices[MATRIX_WORLD]*vec4(in_Normal, 0.0)).xyz);
    v_vColour   = in_Colour0;
    v_vTexcoord = in_TextureCoord;
    
	vec4 tangent = vec4(in_Colour1.xyz, 0.0);
	vec4 bitangent = vec4(cross(in_Normal, in_Colour1.xyz) * in_Colour1.w, 0.0);
    vec3 N = normalize((gm_Matrices[MATRIX_WORLD]*vec4(in_Normal, 0.0)).xyz);
	vec3 T = normalize((gm_Matrices[MATRIX_WORLD]*tangent).xyz);
	vec3 B = normalize((gm_Matrices[MATRIX_WORLD]*bitangent).xyz);
	v_mTBN = mat3(T, B, N);
    
    v_vTangent = T;
    v_vBitangent = B;
}