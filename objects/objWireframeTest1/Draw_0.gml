//Turn on z-writing and z-testing so we're ready for 3D rendering
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);

//Set our view + projection matrices
var _old_world      = matrix_get(matrix_world); 
var _old_view       = matrix_get(matrix_view); 
var _old_projection = matrix_get(matrix_projection);

matrix_set(matrix_view, matrix_build_lookat(cam_x, cam_y, cam_z,
                                            cam_x+cam_dx, cam_y+cam_dy, cam_z+cam_dz,
                                            0, 1, 0));
matrix_set(matrix_projection, matrix_build_projection_perspective_fov(90, room_width/room_height, 1, 3000));

//Finally, draw the model
matrix_set(matrix_world, matrix_build(0,0,0, 0,0,0, 50, 50, 50));

shader_set(shdFlatColour);
model.Submit();
shader_reset();

//Reset draw state
matrix_set(matrix_world     , _old_world     );
matrix_set(matrix_view      , _old_view      );
matrix_set(matrix_projection, _old_projection);
gpu_set_ztestenable(false);
gpu_set_zwriteenable(false);