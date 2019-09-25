//Define the vertex format we want to use
//Note that we're not using normals!
vertex_format_begin();
vertex_format_add_position_3d();     //              12
vertex_format_add_colour();          //            +  4
vertex_format_add_texcoord();        //            +  8
vertex_format = vertex_format_end(); //vertex size = 24

//Load our .obj from disk
//We want to ignore normals but keep the texture coordinates
//Additionally, GameMaker has its y-axis (V-component) of texture coordinates upside down so we need to fix that
//Also some .obj files have their triangles defined the opposite way round which intereferes with culling, so we need to fix that too
vertex_buffer = dotobj_load_from_file("plato.obj", vertex_format, false, true, true, true);

//GameMaker's atlased sprites often don't match normalised texture coordinates that are used in .obj files
//This script remaps the .obj UVs to GameMaker's internal UVs
vertex_buffer = vertex_buffer_remap_uvs(vertex_buffer, vertex_format, sprite_get_uvs(spr_texture, 0), 24, 16, true);

//Rowan made the platypus a little small and was using a different coordinate system, so let's fix that
//N.B. If you rotate/scale a vertex buffer then you should also correct the normals
var _matrix = matrix_build(0, 0, 0,   0, 0, 0,   80, -80, 80);
vertex_buffer = vertex_buffer_transform(vertex_buffer, vertex_format, _matrix, 24, 0, true);

//Couple of variables to track rotation of the model
rotation_x = 0;
rotation_y = 0;
rotation_z = 0;