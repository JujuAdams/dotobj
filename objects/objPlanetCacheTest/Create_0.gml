//dotobj allows you to optionally point filenames to textures stored within your game
//This is useful for a little extra security, or if you want to reduce how many Included Files you have lying around
//Sprites should always have "Separate Texture Page" enabled for the sake of texture coordinates lining up
//You should also define filename->sprite relationships before loading materials (or models)
DotobjSpriteAddInternal("textures\\planet_tex_arid.png", sprPlanetTexArid);

//Load our .obj from disk. This might take a while!
//The script returns a dotobj model (in reality, a struct) that we can draw in the Draw event
//If the model references a material (.mtl) file then that will be loaded as well
DotobjSetFlipTexcoordV(true);
DotobjSetReverseTriangles(true);

if (!file_exists("planet.dat"))
{
    model_planet = DotobjModelLoadFile("planet.obj");
    DotobjModelRawSave(model_planet, "planet.dat");
}
else
{
    model_cache = DotobjModelRawLoad("planet.dat");
    model_planet = model_cache.Duplicate();
}

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