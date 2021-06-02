if (show_info)
{
    //Display credits
    var _string  = "dotobj " + __DOTOBJ_VERSION + "\n";
        _string += "@jujuadams " + __DOTOBJ_DATE + "\n";
        _string += "\n";
        _string += "Model by @artofsully\n"
        _string += "\n";
        _string += "FPS = " + string(fps) + " (" + string(fps_smoothed) + ")\n";
        _string += "\n";
        _string += "WASD/shift/space to move\n";
        _string += "F1 to toggle this panel\n";
        _string += "F3 to toggle mouselook\n";
        _string += "F4 to toggle fullscreen";
    
    draw_set_colour(c_black);
    draw_set_alpha(0.5);
    draw_rectangle(10, 10, 20+string_width(_string), 20+string_height(_string), false);
    draw_text(15, 16, _string);
    draw_set_alpha(1.0);
    draw_text(14, 15, _string);
    draw_text(16, 15, _string);
    draw_text(15, 14, _string);
    draw_text(15, 16, _string);
    draw_set_colour(c_white);
    draw_text(15, 15, _string);
}