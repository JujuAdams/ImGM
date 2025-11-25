// Feather disable all

/// @param left
/// @param top
/// @param right
/// @param bottom
/// @param [configFlags]
/// @param [configFlagsUnset]
/// 
/// `.GetInitialized()`
/// `.Destroy()`
/// `.FrameStart()`
/// `.FrameEnd()`
/// `.Draw()`
/// `.SetRegion()`
/// `.GetPointInside()`
/// `.GetCursor()`
/// `.UpdateSurface()`
/// `.GetSurface()`

function ImGuiContext(_left, _top, _right, _bottom, _configFlagsSet = ImGuiConfigFlags.None, _configFlagsUnset = ImGuiConfigFlags.None) constructor
{
    static _global = __ImGuiGlobal();
    
    Display = {
        Width: 1,
        Height: 1,
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
    __cursor = cr_default;
    __left = 0;
    __top = 0;
    __surfaceDirty = true;
    
    SetRegion(_left, _top, _right, _bottom);
    
    
    
    var _initializeResult =  __imgui_initialize(window_handle(),
                                                Engine.Context,
                                                {
                                                    ConfigFlagsOverrideSet: _configFlagsSet,
                                                    ConfigFlagsOverrideClear: _configFlagsUnset,
                                                    
                                                    //Force GameMaker native rendering. Magic number derived from old enum
                                                    GFlags: 3,
                                                    
                                                    //Unused because we're forcing native rendering
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
    
    static SetRegion = function(_left, _top, _right, _bottom)
    {
        __left = _left;
        __top  = _top;
        
        Display.Width  = 1 + _right - _left;
        Display.Height = 1 + _bottom - _top;
    }
    
    static GetPointInside = function(_x, _y)
    {
        return point_in_rectangle(_x, _y, __left, __top, __left + Display.Width - 1, __top + Display.Height - 1);
    }
    
    static FrameStart = function(_mouseX, _mouseY, _setOSCursor = true, _hasFocus = true)
    {
        if (not __initialized) return;
        
        if (_global.__currentFrameContext != undefined)
        {
            __ImGMError("Cannot start a new frame, the previous frame has not been ended");
        }
        
        _global.__currentFrameContext = self;
        ImGuiSetCurrentContext(Engine.Context);
        
        __surfaceDirty = true;
        
        Engine.Time = delta_time / 1_000_000;
        Engine.Framerate = game_get_speed(gamespeed_fps);

        if ((Display.Width > 0) && (Display.Height > 0))
        {
            var _keyboardFunc = keyboard_check; //TODO - Maybe one day expose this
            
            //TODO - Should keyboard collection be inside a focus check?
            var _inputMappingArray = _global.__inputMapping;
            for(var i = ImGuiKey.NamedKey_BEGIN; i < ImGuiKey.NamedKey_END; i++)
            {
                var key = _inputMappingArray[i];
                if (key > -1) __imgui_key(i, _keyboardFunc(key));
            }
            
            __imgui_key(ImGuiKey.ImGuiMod_Ctrl,  _keyboardFunc(vk_lcontrol));
            __imgui_key(ImGuiKey.ImGuiMod_Shift, _keyboardFunc(vk_lshift));
            __imgui_key(ImGuiKey.ImGuiMod_Alt,   _keyboardFunc(vk_lalt) || _keyboardFunc(vk_ralt));
            
            if (_hasFocus && window_has_focus())
            {
                var _mouseFunc = mouse_check_button; //TODO - Maybe one day expose this
                
                //FIXME - Almost certainly breaks with multiple contexts
                if (__imgui_want_text_input(undefined))
                {
                    if (not _global.__inputRequested)
                    {
                        _global.__inputRequested = true;
                        _global.__inputStore = keyboard_string;
                        keyboard_string = "";
                    }
                    
                    if (__imgui_input(keyboard_string))
                    {
                        keyboard_string = "";
                    }
                }
                else
                {
                    if (_global.__inputRequested)
                    {
                        keyboard_string = _global.__inputStore;
                        _global.__inputRequested = false;
                    }
                }
                
                Input.Mouse.X = _mouseX - __left;
                Input.Mouse.Y = _mouseY - __top;
                
                __imgui_mouse(0, _mouseFunc(mb_left));
                __imgui_mouse(1, _mouseFunc(mb_right));
                __imgui_mouse(2, _mouseFunc(mb_middle));
                
                __imgui_mouse_wheel(0, mouse_wheel_up() - mouse_wheel_down());
                
                __cursor = _global.__cursorMapping[__imgui_mouse_cursor() + 1];
                
                if (_setOSCursor && point_in_rectangle(display_mouse_get_x(), display_mouse_get_y(),
                                                       window_get_x() + IMGM_WINDOW_EDGE,
                                                       window_get_y() + IMGM_WINDOW_EDGE,
                                                       window_get_x() + window_get_width() - IMGM_WINDOW_EDGE,
                                                       window_get_y() + window_get_height() - IMGM_WINDOW_EDGE))
                {
                    window_set_cursor(__cursor);
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
    
    static FrameEnd = function()
    {
        if (not __initialized) return;
        
        if (_global.__currentFrameContext != self)
        {
            __ImGMError("Cannot end this context's frame, it has not been started");
        }
        
        _global.__currentFrameContext = undefined;
        
        __imgui_end_frame();
    }
    
    static Draw = function()
    {
        if (not __initialized) return;
        
        if (__surfaceDirty)
        {
            UpdateSurface();
        }
        
        gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha); //Pre-multiplied alpha blend mode
        draw_surface(GetSurface(), __left, __top);
        gpu_set_blendmode(bm_normal);
    }
    
    static GetCursor = function()
    {
        return __cursor;
    }
    
    static UpdateSurface = function()
    {
        if (not __initialized) return;
        
        __surfaceDirty = false;
        
        ImGuiSetCurrentContext(Engine.Context);
        __imgui_render();
        __imgui_draw(self);
        
        var cmdBuffer = Renderer.CmdBuffer;
        buffer_seek(cmdBuffer, buffer_seek_start, 0);
        if (buffer_read(cmdBuffer, buffer_bool))
        {
            //Cache static values for better performance inside the loop
            var vtxBuffer = _global.__vtxBuffer;
            var vtxStride = _global.__vtxFormatStride;
            
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