model_a = DotobjModelLoadFile("text_A.obj");
model_b = DotobjModelLoadFile("text_B.obj");
model_c = DotobjModelLoadFile("text_C.obj");
model_ab = DotobjModelLoadFile("text_A.obj");
model_ba = DotobjModelLoadFile("text_B.obj");
model_abc = DotobjModelLoadFile("text_C.obj");
model_ab.Merge(model_b);
model_ba.Merge(model_a);
model_abc.Merge(model_a);
model_abc.Merge(model_b);

//Mouse lock variables (press F3 to lock the mouse and use mouselook)
mouse_lock = false;
mouse_lock_timer = 0;

//Some variables to track the camera
cam_x     = 150;
cam_y     = 0;
cam_z     = -225;
cam_yaw   = 25;
cam_pitch = 15;
cam_dx    = -dcos(cam_pitch)*dsin(cam_yaw);
cam_dy    = -dsin(cam_pitch);
cam_dz    =  dcos(cam_pitch)*dcos(cam_yaw);

//Smoothed fps_real variable
fps_smoothed = 60;
show_info = true;