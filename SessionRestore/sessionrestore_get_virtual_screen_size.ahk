#include <screen>
screen_get_virtual_size(&_x, &_y, &vs_width, &vs_height)
FileAppend(vs_width "," vs_height, "*")
ExitApp
