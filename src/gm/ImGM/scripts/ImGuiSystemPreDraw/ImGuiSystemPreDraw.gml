// Feather disable all

function ImGuiSystemPreDraw()
{
    static _system = __ImGuiSystem();
    with(_system)
    {
        if (not __initialized) return;
        
        __imgui_render();
        
        if (not surface_exists(__state.Renderer.Surface))
        {
            __state.Renderer.Surface = surface_create(max(1, __state.Display.Width), max(1, __state.Display.Height));
        }
        
        __imgui_draw(__state);
        
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
        }
    }
}