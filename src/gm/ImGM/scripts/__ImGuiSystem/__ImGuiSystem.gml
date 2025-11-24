function __ImGuiSystem()
{
    static _system = undefined;
    if (_system != undefined) return _system;
    
    _system = {};
    with(_system)
    {
        __initialized = false;
        
        __state = undefined;
        
        __mainWindowHandle = window_handle();
        __mainWindow = undefined;
        
        vertex_format_begin();
        vertex_format_add_position();
        vertex_format_add_texcoord();
        vertex_format_add_color();
        __vtxFormat = vertex_format_end();
        
        __vtxFormatStride = vertex_format_get_info(__vtxFormat).stride;
        
        __vtxBuffer = vertex_create_buffer();
        vertex_begin(__vtxBuffer, __vtxFormat);
        vertex_end(__vtxBuffer);
        
        __inputMapping  = __imgui_create_input_mapping();
        __cursorMapping = __imgui_create_cursor_mapping();
        
        __cursorPrev = -1;
        __inputRequested = false;
        __inputStore = undefined;
    }
    
    return _system;
}

function ImGuiSystemInitialize(_configFlags = ImGuiConfigFlags.None)
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (__initialized) return;

        // Setup received parameters
        var ww = undefined;
        var new_state = undefined;
        
        __mainWindow ??= new ImGuiBaseMainWindow();
        ww = __mainWindow;
        
        new_state = new ImGuiState();
        new_state.Engine.Window = ww;
        new_state.Engine.Context = ImGuiCreateContext();
        
        var inited = new_state.__Initialize(_configFlags);

        if ((inited == pointer_null) || (inited == undefined))
        {
            ImGuiDestroyContext(__state.Engine.Context);
            __state.Engine.Context = pointer_null;
            
            buffer_delete(__state.Renderer.CmdBuffer);
            __state.Renderer.CmdBuffer = -1;
            
            buffer_delete(__state.Renderer.FontBuffer);
            __state.Renderer.FontBuffer = -1;
            
            __initialized = false;
            return false;
        }
        else
        {
            new_state.Use();
            
            __initialized = true;
            return true;
        }
    }
}

function ImGuiSystemShutdown(state = undefined)
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (not __initialized) return;
        
        state ??= __state;
        if (state != __state) state.Use();
        
        if (__imgui_shutdown(__state.Engine.Context))
        {
            __initialized = false;
            __state.Destroy();
            
            return true;
        }
        
        return false;
    }
}

function ImGuiSystemNewFrame (state = undefined)
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (not __initialized) return;
    
        state ??= __state;
        if (state != __state) state.Use();
        
        var _wwidth  = __state.Engine.Window.GetWidth();
        var _wheight = __state.Engine.Window.GetHeight();
        var _focus   = __state.Engine.Window.HasFocus();
        
        // Check surface
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

        var _data = __state.__GetData();
        __imgui_new_frame(_data);

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

function ImGuiSystemEndFrame(state = undefined)
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (not __initialized) return;
        
        state ??= __state;
        if (state != __state) state.Use();
        
        __imgui_end_frame();
    }
}

function ImGuiSystemRender(state = undefined)
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (not __initialized) return;
        
        state ??= __state;
        if (state != __state) state.Use();
        
        __imgui_render();
    }
}

function ImGuiSystemDraw(state = undefined, _rescale = true)
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (not __initialized) return;
        
        state ??= __state;
        if (state != __state) state.Use();
        
        if (not surface_exists(__state.Renderer.Surface))
        {
            __state.Renderer.Surface = surface_create(max(1, __state.Display.Width), max(1, __state.Display.Height));
        }
        
        var _data = __state.__GetData();
        __imgui_draw(_data);
        
        var cmdBuffer = __state.Renderer.CmdBuffer;
        buffer_seek(cmdBuffer, buffer_seek_start, 0);
        if (buffer_read(cmdBuffer, buffer_bool))
        {
            //Cache static values for better performance inside the loop
            var vtxBuffer = __vtxBuffer;
            var vtxStride = __vtxFormatStride;
            
            //Keep a copy of the current scissor state for later reset
            var oldScissor = gpu_get_scissor();
            
            surface_set_target(__state.Renderer.Surface);
            gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha); //Pre-multiplied alpha blend mode
            draw_clear_alpha(0, 0);
            var list_count = buffer_read(cmdBuffer, buffer_u32);
            repeat(list_count)
            {
                var cmd_count = buffer_read(cmdBuffer, buffer_u32);
                repeat(cmd_count)
                {
                    if (not buffer_read(cmdBuffer, buffer_bool))
                    {
                        var tex_data = buffer_read(cmdBuffer, buffer_u32);
                        switch (tex_data & 0xF)
                        {
                            case ImGuiTextureType.Surface:
                                var tex_id = surface_get_texture(tex_data >> 16);
                            break;

                            case ImGuiTextureType.Font:
                                var tex_id = sprite_get_texture(__state.Display.Font, 0);
                            break;

                            case ImGuiTextureType.Sprite:
                                var tex_id = sprite_get_texture(tex_data >> 16, (tex_data >> 4) & 0xFFF);
                            break;
                            
                            default:
                                var tex_id = -1;
                            break;
                        }

                        var clip_x1 = buffer_read(cmdBuffer, buffer_f32);
                        var clip_y1 = buffer_read(cmdBuffer, buffer_f32);
                        var clip_x2 = buffer_read(cmdBuffer, buffer_f32);
                        var clip_y2 = buffer_read(cmdBuffer, buffer_f32);
                        gpu_set_scissor(clip_x1, clip_y1, clip_x2 - clip_x1, clip_y2 - clip_y1);
                            
                        var vtx_count = buffer_read(cmdBuffer, buffer_u32);
                        vertex_update_buffer_from_buffer(vtxBuffer, 0, cmdBuffer, buffer_tell(cmdBuffer), vtxStride*vtx_count);
                        vertex_submit_ext(vtxBuffer, pr_trianglelist, tex_id, 0, vtx_count)
                            
                        buffer_seek(cmdBuffer, buffer_seek_relative, vtxStride*vtx_count);
                    }
                }
            }
            
            surface_reset_target();
            gpu_set_blendmode(bm_normal);
            gpu_set_scissor(oldScissor);
            
            draw_surface(__state.Renderer.Surface, 0, 0);
        }
    }
}