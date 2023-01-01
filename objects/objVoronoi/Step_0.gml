//Toggle the info panel if we press F1
if (keyboard_check_released(vk_f1)) show_info = !show_info;

//Slightly weird use of lerp() but it works
fps_smoothed = lerp(fps_smoothed, fps_real, 0.1);