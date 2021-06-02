pipe = DotobjPipeCreate();
pipe.AddShader({ shader: shdPipeDiffMap,         diffuseMap:  "gm_BaseTexture"                                               });
pipe.AddShader({ shader: shdPipeDiffMapNormMap,  diffuseMap:  "gm_BaseTexture",  normalMap: "u_sNormal"                      }, true);
pipe.AddShader({ shader: shdPipeDiffFlat,        diffuseFlat: "u_vDiffuse"                                                   });
pipe.AddShader({ shader: shdPipeDiffMapDissMap,  diffuseMap:  "gm_BaseTexture",  dissolveMap:  "u_sDissolve"                 });
pipe.AddShader({ shader: shdPipeDiffMapDissMap,  diffuseMap:  "gm_BaseTexture",  dissolveMap:  "u_sDissolve",  normalMap: "" }, true);

//Load our .obj from disk. This might take a while!
//The script returns a dotobj model (in reality, a struct) that we can draw in the Draw event
//If the model references a material (.mtl) file then that will be loaded as well
DotobjSetFlipTexcoordV(true);
DotobjSetReverseTriangles(true);
DotobjSetWriteTangents(true, false);
model = DotobjModelLoadFile("venus_cube.obj");
model.Freeze();

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