context1.SetRegion(0, 0, window_get_width()/2, window_get_height());
context1.FrameStart(window_mouse_get_x(), window_mouse_get_y());
                   
ImGuiSetNextWindowSize(window_get_width()/4, window_get_height()/2, ImGuiCond.Once);
var ret = ImGuiBegin("ImGM Example", true, ImGuiWindowFlags.None, ImGuiReturnMask.Both);
ImGuiEnd();

context1.FrameEnd();



context2.SetRegion(window_get_width()/2, 0, window_get_width(), window_get_height());
context2.FrameStart(window_mouse_get_x(), window_mouse_get_y());
                   
ImGuiSetNextWindowSize(window_get_width()/4, window_get_height()/2, ImGuiCond.Once);
var ret = ImGuiBegin("ImGM Example", true, ImGuiWindowFlags.None, ImGuiReturnMask.Both);
ImGuiEnd();

context2.FrameEnd();