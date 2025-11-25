context1.BeginStep(window_mouse_get_x(), window_mouse_get_y());
                   
ImGuiSetNextWindowSize(room_width/4, room_height/2, ImGuiCond.Once);
var ret = ImGuiBegin("ImGM Example", true, ImGuiWindowFlags.None, ImGuiReturnMask.Both);
ImGuiEnd();

context1.EndStep();



context2.BeginStep(window_mouse_get_x(), window_mouse_get_y());
                   
ImGuiSetNextWindowSize(room_width/4, room_height/2, ImGuiCond.Once);
var ret = ImGuiBegin("ImGM Example", true, ImGuiWindowFlags.None, ImGuiReturnMask.Both);
ImGuiEnd();

context2.EndStep();