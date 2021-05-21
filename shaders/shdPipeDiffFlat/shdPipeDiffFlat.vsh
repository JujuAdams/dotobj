attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec3 v_vPosition;
varying vec3 v_vNormal;
varying vec4 v_vColour;

void main()
{
    vec4 wsPos = gm_Matrices[MATRIX_WORLD]*vec4(in_Position, 1.0);
    gl_Position = gm_Matrices[MATRIX_PROJECTION]*gm_Matrices[MATRIX_VIEW]*wsPos;
    
    v_vPosition = wsPos.xyz;
    v_vNormal   = (gm_Matrices[MATRIX_WORLD]*vec4(in_Normal, 0.0)).xyz;
    v_vColour   = in_Colour;
    
    //Not used, but we need to reference in_TextureCoord to avoid optimisation removing it from the attributes
    vec2 dummy = in_TextureCoord;
}