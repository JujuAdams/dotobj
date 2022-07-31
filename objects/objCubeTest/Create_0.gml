model = DotobjModelLoadFile("cube\\cube.obj");

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