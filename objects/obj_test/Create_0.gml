//Define the vertex format we want to use
vertex_format_begin();
vertex_format_add_position_3d();     //              12
vertex_format_add_normal();          //            + 12
vertex_format_add_colour();          //            +  4
vertex_format_add_texcoord();        //            +  8
vertex_format = vertex_format_end(); //vertex size = 36

//Initialise dotobj. This creates some globally scoped maps, and a default material
dotobj_init();

//Load materials from file
//This will also load in images from disk (from the "textures" folder in Included Files)
dotobj_material_load_file("sponza.mtl");

//Load our .obj from disk. This might take a while!
//The script returns a dotobj model (in reality, an array) that we can draw in the Draw event
model_sponza = dotobj_model_load_file("sponza.obj", vertex_format, true, true, true, true);

//Mouse lock variables (press F3 to lock the mouse and use mouselook)
mouse_lock = false;
mouse_lock_timer = 0;

//Some variables to track the camera
cam_x     = 0;
cam_y     = 120;
cam_z     = 0;
cam_yaw   = -60;
cam_pitch = 0;
cam_dx    = -dcos(cam_pitch)*dsin(cam_yaw);
cam_dy    = -dsin(cam_pitch);
cam_dz    =  dcos(cam_pitch)*dcos(cam_yaw);

//Smoothed fps_real variable
fps_smoothed = 60;
show_info = true;