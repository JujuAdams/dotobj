var _dots = "";
repeat((current_time mod (4*120-1)) / 120)
{
    _dots += ".";
}

draw_text(10, 10, "Loading" + _dots + "\n\n(This can take a while.)");