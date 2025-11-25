// Feather disable all

/// @param width
/// @param height

function ImGuiContext(_width, _height, _configFlags = ImGuiConfigFlags.None) constructor
{
    static _system = __ImGuiSystem();
    
    Display = {
        Width: _width,
        Height: _height,
        Scale: 1,
        Font: -1,
    };
    
    Input = {
        Mouse: {
            X: 0,
            Y: 0
        }
    };
    
    Engine = {
        Context: ImGuiCreateContext(),
        Time: 0,
        Framerate: game_get_speed(gamespeed_fps),
    };
    
    Renderer = {
        CmdBuffer: buffer_create(__IMGUI_GM_BUFFER_SIZE, buffer_grow, 1),
        FontBuffer: buffer_create(__IMGUI_GM_BUFFER_SIZE, buffer_grow, 1),
        Surface: -1,
        UpdateFont: true,
    };
    
    __initialized = false;
    
    
    
    var _initializeResult =  __imgui_initialize(window_handle(),
                                                Engine.Context,
                                                {
                                                    GFlags: 3, //Force GameMaker native rendering. Magic number derived from old enum
                                                    
                                                    ConfigFlagsOverrideSet: _configFlags,
                                                    ConfigFlagsOverrideClear: ImGuiConfigFlags.None,
                                                    
                                                    //Unused because we're using native rendering
                                                    D3DDevice: pointer_null,
                                                    D3DDeviceContext: pointer_null,
                                                });
    
    if ((_initializeResult == pointer_null) || (_initializeResult == undefined))
    {
        Destroy();
    }
    else
    {
        __initialized = true;
    }
    
    
    
    static GetInitialized = function()
    {
        return __initialized;
    }
    
    static BeginStep = function(_surfaceWidth, _surfaceHeight, _mouseX, _mouseY, _hasFocus = window_has_focus(), _keyboardFunc = keyboard_check_direct, _mouseFunc = mouse_check_button, _mouseWheelDelta = mouse_wheel_up() - mouse_wheel_down(), _cursorFunc = window_set_cursor)
    {
        if (not __initialized) return;
        
        ImGuiSetCurrentContext(Engine.Context);
        
        Display.Width  = _surfaceWidth;
        Display.Height = _surfaceHeight;

        Engine.Time = delta_time / 1_000_000;
        Engine.Framerate = game_get_speed(gamespeed_fps);

        if ((_surfaceWidth > 0) && (_surfaceHeight > 0))
        {
            var _inputMappingArray = _system.__inputMapping;
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
                if (not _system.__inputRequested)
                {
                    _system.__inputRequested = true;
                    _system.__inputStore = keyboard_string;
                    keyboard_string = "";
                }
                
                if (__imgui_input(keyboard_string))
                {
                    keyboard_string = "";
                }
            }
            else
            {
                if (_system.__inputRequested)
                {
                    keyboard_string = _system.__inputStore;
                    _system.__inputRequested = false;
                }
            }
            
            if (_hasFocus)
            {
                Input.Mouse.X = _mouseX;
                Input.Mouse.Y = _mouseY;
                
                for(var i = 0; i < 3; i++)
                {
                    __imgui_mouse(i, _mouseFunc(i + 1));
                }
                
                __imgui_mouse_wheel(0, _mouseWheelDelta);

                var _cursor = __imgui_mouse_cursor();
                if (_cursor != _system.__cursorPrev)
                {
                    _cursorFunc(_system.__cursorMapping[_cursor + 1]);
                    _system.__cursorPrev = _cursor;
                }
            }
        }
        
        __imgui_new_frame(self);

        if (buffer_peek(Renderer.FontBuffer, 0, buffer_bool))
        {
            if (sprite_exists(Display.Font)) sprite_delete(Display.Font);
            var font = surface_create(buffer_peek(Renderer.FontBuffer, 1, buffer_u32), buffer_peek(Renderer.FontBuffer, 5, buffer_u32));
            buffer_set_surface(Renderer.FontBuffer, font, 9);
            Display.Font = sprite_create_from_surface(font, 0, 0, surface_get_width(font), surface_get_height(font), false, false, 0, 0);
            surface_free(font);
            Renderer.UpdateFont = false;
        }
    }
    
    static EndStep = function()
    {
        if (not __initialized) return;
        
        ImGuiSetCurrentContext(Engine.Context);
        __imgui_end_frame();
    }
    
    static PreDraw = function()
    {
        if (not __initialized) return;
        
        ImGuiSetCurrentContext(Engine.Context);
        __imgui_render();
        __imgui_draw(self);
        
        var cmdBuffer = Renderer.CmdBuffer;
        buffer_seek(cmdBuffer, buffer_seek_start, 0);
        if (buffer_read(cmdBuffer, buffer_bool))
        {
            //Cache static values for better performance inside the loop
            var vtxBuffer = _system.__vtxBuffer;
            var vtxStride = _system.__vtxFormatStride;
            
            //Keep a copy of the current scissor state for later reset
            var oldScissor = gpu_get_scissor();
            
            surface_set_target(GetSurface());
            
            draw_clear_alpha(c_black, 0);
            draw_clear(c_gray);
            
            gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha); //Pre-multiplied alpha blend mode
            
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
                                var tex_id = sprite_get_texture(Display.Font, 0);
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
        }
    }
    
    static GetSurface = function()
    {
        if (not __initialized) return -1;
        
        var _displayWidth  = Display.Width;
        var _displayHeight = Display.Height;
        
        var _surface = Renderer.Surface;
        if (surface_exists(_surface) && ((surface_get_width(_surface) != _displayWidth) || (surface_get_height(_surface) != _displayHeight)))
        {
            surface_free(_surface);
        }
        
        if (not surface_exists(_surface))
        {
            _surface = surface_create(max(1, _displayWidth), max(1, _displayHeight));
            Renderer.Surface = _surface;
        }
        
        return _surface;
    }
    
    static Destroy = function()
    {
        if (is_ptr(Engine.Context))
        {
            if (__initialized)
            {
                __imgui_shutdown(__state.Engine.Context);
            }
            
            ImGuiDestroyContext(Engine.Context);
        }
        
        Engine.Context = pointer_null;
        
        if (buffer_exists(Renderer.CmdBuffer)) buffer_delete(Renderer.CmdBuffer);
        Renderer.CmdBuffer = -1;
        
        if (buffer_exists(Renderer.FontBuffer)) buffer_delete(Renderer.FontBuffer);
        Renderer.FontBuffer = -1;
        
        if (surface_exists(Renderer.Surface)) surface_free(Renderer.Surface);
        Renderer.Surface = -1;
        
        __initialized = false;
    }
}