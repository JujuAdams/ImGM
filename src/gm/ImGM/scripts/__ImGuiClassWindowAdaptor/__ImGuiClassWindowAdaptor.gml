// Feather disable all

function __ImGuiClassWindowAdaptor() constructor
{
    static GetHandle = function() {return window_handle();}
    static Exists = function() {return true;}
    static HasFocus = function() {return window_has_focus();}
    static GetX = function() {return window_get_x();}
    static GetY = function() {return window_get_y();}
    static GetWidth = function() {return window_get_width();}
    static GetHeight = function() {return window_get_height();}
    static MouseGetX = function() {return window_mouse_get_x();}
    static MouseGetY = function() {return window_mouse_get_y();}
    static MouseCheckButton = function(mb) {return mouse_check_button(mb);}
    static MouseWheelUp = function(mb) {return mouse_wheel_up();}
    static MouseWheelDown = function(mb) {return mouse_wheel_down();}
    static SetCursor = function(cursor) {return window_set_cursor(cursor);}
    static IsMinimized = function() {return GetWidth() == 0 and GetHeight() == 0;}
    static Destroy = undefined;
}