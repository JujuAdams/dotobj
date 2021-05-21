//Force anti-aliasing to the maxxxxx
display_reset(8, true);

//If the display is smaller than the window, go fullscreen
if ((display_get_width() <= window_get_width()) || (display_get_height() <= window_get_height()))
{
    window_set_fullscreen(true);
}

//Delay for a few frames, then start the game
alarm[0] = 10;