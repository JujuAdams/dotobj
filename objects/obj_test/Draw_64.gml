if (show_info)
{
    //Display credits
    var _string  = "dotobj " + __DOTOBJ_VERSION + "\n";
        _string += "@jujuadams " + __DOTOBJ_DATE + "\n";
        _string += "\n";
        _string += "Sponza Atrium by Marko Dabrovic\n"
        _string += "\n";
        _string += "FPS = " + string(fps) + " (" + string(fps_smoothed) + ")\n";
        _string += "\n";
        _string += "WASD/shift/space to move\n";
        _string += "F1 to toggle this panel\n";
        _string += "F3 to toggle mouselook";
    
    draw_set_colour(c_black);
    draw_set_alpha(0.5);
    draw_rectangle(10, 10, 20+string_width(_string), 20+string_height(_string), false);
    draw_set_alpha(1.0);
    draw_set_colour(c_white);
    draw_text(15, 15, _string);
}