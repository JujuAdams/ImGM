// Feather disable all

function ImGuiSystemNewFrame()
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (not __initialized) return;
        
        var _wwidth  = __state.Engine.Window.GetWidth();
        var _wheight = __state.Engine.Window.GetHeight();
        var _focus   = __state.Engine.Window.HasFocus();
        
        if (surface_exists(__state.Renderer.Surface) && ((surface_get_width(__state.Renderer.Surface) != _wwidth) || (surface_get_height(__state.Renderer.Surface) != _wheight)))
        {
            surface_free(__state.Renderer.Surface);
        }
        
        if (not surface_exists(__state.Renderer.Surface))
        {
            __state.Renderer.Surface = surface_create(max(1, _wwidth), max(1, _wheight));
        }

        if _wwidth != 0 __state.Display.Width = _wwidth;
        if _wheight != 0 __state.Display.Height = _wheight;
        __state.Engine.Time = delta_time / 1_000_000;
        __state.Engine.Framerate = game_get_speed(gamespeed_fps);

        if ((_wwidth > 0 && _wheight > 0)) {
            for(var i = ImGuiKey.NamedKey_BEGIN; i < ImGuiKey.NamedKey_END; i++) {
                var key = __inputMapping[i];
                if (key > -1) __imgui_key(i, keyboard_check_direct(key));
            }
            __imgui_key(ImGuiKey.ImGuiMod_Ctrl, keyboard_check_direct(vk_lcontrol));
            __imgui_key(ImGuiKey.ImGuiMod_Shift, keyboard_check_direct(vk_lshift));
            __imgui_key(ImGuiKey.ImGuiMod_Alt, keyboard_check_direct(vk_lalt));

            if (__imgui_want_text_input(undefined)) {
                if (!__inputRequested) {
                    __inputRequested = true;
                    __inputStore = keyboard_string;
                    keyboard_string = "";
                }
                if (__imgui_input(keyboard_string)) keyboard_string = "";
            } else {
                if (__inputRequested) {
                    keyboard_string = __inputStore;
                    __inputRequested = false;
                }
            }
            
            if (_focus == true)
            {
                __state.Input.Mouse.X = __state.Engine.Window.MouseGetX();
                __state.Input.Mouse.Y = __state.Engine.Window.MouseGetY();
                for(var i = 0; i < 3; i++) __imgui_mouse(i, __state.Engine.Window.MouseCheckButton(i + 1));
                if (__state.Engine.Window.MouseWheelUp()) __imgui_mouse_wheel(0, 1);
                else if (__state.Engine.Window.MouseWheelDown()) __imgui_mouse_wheel(0, -1);

                var _cursor = __imgui_mouse_cursor();
                if (_cursor != __cursorPrev) {
                    __state.Engine.Window.SetCursor(__cursorMapping[_cursor + 1]);
                    __cursorPrev = _cursor;
                }
            }
        }
        
        __imgui_new_frame(__state);

        if (buffer_peek(__state.Renderer.FontBuffer, 0, buffer_bool))
        {
            if (sprite_exists(__state.Display.Font)) sprite_delete(__state.Display.Font);
            var font = surface_create(buffer_peek(__state.Renderer.FontBuffer, 1, buffer_u32), buffer_peek(__state.Renderer.FontBuffer, 5, buffer_u32));
            buffer_set_surface(__state.Renderer.FontBuffer, font, 9);
            __state.Display.Font = sprite_create_from_surface(font, 0, 0, surface_get_width(font), surface_get_height(font), false, false, 0, 0);
            surface_free(font);
            __state.Renderer.UpdateFont = false;
        }
    }
}