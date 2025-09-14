// Feather disable all

function __DotobjSystem()
{
    static _system = undefined;
    if (_system != undefined)
    {
        return _system;
    }
    
    _system = {};
    with(_system)
    {
        //Define the vertex formats we want to use
        vertex_format_begin();
        vertex_format_add_position_3d();          //              12
        vertex_format_add_normal();               //            + 12
        vertex_format_add_colour();               //            +  4
        vertex_format_add_texcoord();             //            +  8
        __vertexFormatPNCT = vertex_format_end(); //vertex size = 36
        
        //Define the vertex formats we want to use
        vertex_format_begin();
        vertex_format_add_position_3d();                                   //        12
        vertex_format_add_normal();                                        //      + 12
        vertex_format_add_colour();                                        //      +  4
        vertex_format_add_texcoord();                                      //      +  8
        vertex_format_add_custom(vertex_type_float4, vertex_usage_colour); //      + 16    //I don't think vertex_usage_tangent works...
        __vertexFormatPNCTTan = vertex_format_end();                       //vertex size = 52
    
    
    
        //Create a global map to store all our material definitions
        global.__dotobjMtlFileLoaded   = ds_map_create();
        global.__dotobjMaterialLibrary = ds_map_create();
        global.__dotobjSpriteMap       = ds_map_create();
        
        //State variables
        __flipTexcoordV    = false;
        __reverseTriangles = false;
        __writeTangents    = false;
        __forceTangentCalc = false;
        __wireframe        = false;
        __transformOnLoad  = false;
        
        //Create a default material
        __DotobjEnsureMaterial(DOTOBJ_DEFAULT_MATERIAL_LIBRARY, DOTOBJ_DEFAULT_MATERIAL);
    }
    
    return _system;
}
