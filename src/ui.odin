package main

import          "../lib/odin-imgui/imgui_impl_sdl2"
import          "../lib/odin-imgui/imgui_impl_opengl3"
import im       "../lib/odin-imgui"

import sdl      "vendor:sdl2"
import gl       "vendor:OpenGL"


c_search_text   : cstring     = "testing"
running         :             = true
event           : sdl.Event

main_loop :: proc() 
{
        for running {
                handle_events()

                imgui_impl_opengl3.NewFrame()
                imgui_impl_sdl2.NewFrame()
                im.NewFrame()

                draw_menu_bar(0, 0)
                draw_search_bar(0, 15)
                draw_image_grid(0, 30)

                im.Render()
                gl.Viewport(0, 0, i32(io.DisplaySize.x), i32(io.DisplaySize.y))
                gl.ClearColor(0, 0, 0, 1)
                gl.Clear(gl.COLOR_BUFFER_BIT)
                imgui_impl_opengl3.RenderDrawData(im.GetDrawData())

                sdl.GL_SwapWindow(window)
        }
}

handle_events :: proc() 
{
        for sdl.PollEvent(&event) {
                imgui_impl_sdl2.ProcessEvent(&event)

                #partial switch event.type {
                case .QUIT: running = false
                // TODO:
                case .DROPBEGIN: 
                case .DROPFILE:
                case .DROPCOMPLETE:
                }
        }
}

draw_menu_bar :: proc(x, y: f32) 
{
        im.BeginMainMenuBar()
        {
                if im.BeginMenu("File") {
                        clicked := im.MenuItem("Open")
                        if clicked do open_file_dialog()
                        im.EndMenu()
                }
        }
        im.EndMainMenuBar()
}

draw_search_bar :: proc(x, y: f32) 
{
        im.SetNextWindowPos({x, y})
        im.SetNextWindowSize(io.DisplaySize)
        im.SetNextWindowViewport(0)

        im.Begin("search", nil, {
                .NoResize,
                .NoMove,
                .NoCollapse,
                .NoTitleBar,
                .NoBringToFrontOnFocus,
        })
        {
                im.Text("Search: ")
                im.SameLine()
                im.Text(c_search_text)
        }
        im.End()
}

draw_image_grid :: proc(x, y: f32) 
{
        im.SetNextWindowPos({x, y})
        im.SetNextWindowSize(io.DisplaySize)
        im.SetNextWindowViewport(0)

        im.Begin("main", nil, {
                .NoResize,
                .NoMove,
                .NoCollapse,
                .NoTitleBar,
                .NoBringToFrontOnFocus,
        })
        {
        }
        im.End()
}

open_file_dialog :: proc() 
{
}
