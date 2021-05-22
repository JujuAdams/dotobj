attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour0;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour1;

varying vec3 v_vPosition;
varying vec3 v_vNormal;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vDummy;

void main()
{
    vec4 wsPos = gm_Matrices[MATRIX_WORLD]*vec4(in_Position, 1.0);
    gl_Position = gm_Matrices[MATRIX_PROJECTION]*gm_Matrices[MATRIX_VIEW]*wsPos;
    
    v_vPosition = wsPos.xyz;
    v_vNormal   = (gm_Matrices[MATRIX_WORLD]*vec4(in_Normal, 0.0)).xyz;
    v_vColour   = in_Colour0;
    v_vTexcoord = in_TextureCoord;
    
    //Not used, but we need to have a reference to avoid optimisation removing it from the attributes
    v_vDummy = in_Colour1;
}