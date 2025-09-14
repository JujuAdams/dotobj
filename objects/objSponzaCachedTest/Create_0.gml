//Remind the user to run using YYC, but only if they're not debugging
if ((not code_is_compiled()) && (not debug_mode))
{
    show_message("It is strongly recommended you run this example using YYC.");
}

//Load our .obj from disk. This might take a while!
//The script returns a dotobj model (in reality, a struct) that we can draw in the Draw event
//If the model references a material (.mtl) file then that will be loaded as well
DotobjSetFlipTexcoordV(true);
model_sponza = DotobjTryCache("sponza\\sponza.obj");
model_sponza.Freeze(); //Wise to freeze your models as well

//Output the materials that this model uses
show_debug_message(model_sponza.GetMaterials());

//If you want to manually load material (.mtl) files then you can do so using this function:
//    DotobjMtlFromFile("sponza.mtl");
//As mentioned above, DotobjModelLoadFile() will try to load material files automatically

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