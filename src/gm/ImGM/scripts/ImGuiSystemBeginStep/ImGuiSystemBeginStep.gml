// Feather disable all

/// @param surfaceWidth
/// @param surfaceHeight
/// @param mouseX
/// @param mouseY
/// @param [hasFocus]
/// @param [keyboardFunc]
/// @param [mouseFunc]
/// @param [mouseWheelDelta]
/// @param [cursorFunc]

function ImGuiSystemBeginStep(_surfaceWidth, _surfaceHeight, _mouseX, _mouseY, _hasFocus = window_has_focus(), _keyboardFunc = keyboard_check_direct, _mouseFunc = mouse_check_button, _mouseWheelDelta = mouse_wheel_up() - mouse_wheel_down(), _cursorFunc = window_set_cursor)
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (not __initialized) return;
        
        if (surface_exists(__state.Renderer.Surface) && ((surface_get_width(__state.Renderer.Surface) != _surfaceWidth) || (surface_get_height(__state.Renderer.Surface) != _surfaceHeight)))
        {
            surface_free(__state.Renderer.Surface);
        }
        
        if (not surface_exists(__state.Renderer.Surface))
        {
            __state.Renderer.Surface = surface_create(max(1, _surfaceWidth), max(1, _surfaceHeight));
            __state.Display.Width  = surface_get_width(__state.Renderer.Surface);
            __state.Display.Height = surface_get_height(__state.Renderer.Surface);
        }

        __state.Engine.Time = delta_time / 1_000_000;
        __state.Engine.Framerate = game_get_speed(gamespeed_fps);

        if ((_surfaceWidth > 0) && (_surfaceHeight > 0))
        {
            var _inputMappingArray = __inputMapping;
            for(var i = ImGuiKey.NamedKey_BEGIN; i < ImGuiKey.NamedKey_END; i++)
            {
                var key = _inputMappingArray[i];
                if (key > -1) __imgui_key(i, keyboard_check_direct(key));
            }
            
            __imgui_key(ImGuiKey.ImGuiMod_Ctrl, keyboard_check_direct(vk_lcontrol));
            __imgui_key(ImGuiKey.ImGuiMod_Shift, keyboard_check_direct(vk_lshift));
            __imgui_key(ImGuiKey.ImGuiMod_Alt, keyboard_check_direct(vk_lalt));

            if (__imgui_want_text_input(undefined))
            {
                if (!__inputRequested)
                {
                    __inputRequested = true;
                    __inputStore = keyboard_string;
                    keyboard_string = "";
                }
                
                if (__imgui_input(keyboard_string))
                {
                    keyboard_string = "";
                }
            }
            else
            {
                if (__inputRequested)
                {
                    keyboard_string = __inputStore;
                    __inputRequested = false;
                }
            }
            
            if (_hasFocus)
            {
                __state.Input.Mouse.X = _mouseX;
                __state.Input.Mouse.Y = _mouseY;
                
                for(var i = 0; i < 3; i++)
                {
                    __imgui_mouse(i, _mouseFunc(i + 1));
                }
                
                __imgui_mouse_wheel(0, _mouseWheelDelta);

                var _cursor = __imgui_mouse_cursor();
                if (_cursor != __cursorPrev)
                {
                    _cursorFunc(__cursorMapping[_cursor + 1]);
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