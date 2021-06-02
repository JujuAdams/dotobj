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
model_planet = DotobjModelLoadFile("planet.obj");
model_planet.Freeze();

//Duplicate the model
model_planet2 = model_planet.Duplicate();

//Create a new material and set its diffuse map to a new texture
var _alt_material = DotobjMaterialCreate("runtime", "inverted skin");
_alt_material.SetDiffuseMap(DotobjTextureCreate(sprPlanetTexAridInv, 0));

//Now pass the new material into the second planet model
model_planet2.SetMaterialForMeshes("runtime", "inverted skin");

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