//Turn on z-writing, z-testing, and backface (clockwise) culling, ready for 3D rendering
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_cullmode(cull_clockwise);

//Set our rotation matrix
matrix_set(matrix_world, matrix_build(room_width/2, room_height/2, 0,   rotation_x, rotation_y, rotation_z,   1,1,1));

//Draw the vertex buffer
vertex_submit(vertex_buffer, pr_trianglelist, sprite_get_texture(spr_texture, 0));

//Reset draw state
matrix_set(matrix_world, matrix_build_identity());
gpu_set_ztestenable(false);
gpu_set_zwriteenable(false);
gpu_set_cullmode(cull_noculling);