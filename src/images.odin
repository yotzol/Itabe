package main

import im       "../lib/odin-imgui"

import gl       "vendor:OpenGL"
import          "vendor:stb/image"

import fp       "core:path/filepath"
import          "core:strings"

ALLOWED_EXTENSIONS : []string : {".png", ".jpg", ".jpeg", ".bmp"} //, "gif"}

ImageData :: [^]byte

@(private="file")
THUMBNAIL_W : i32 : 512

@(private="file")
THUMBNAIL_H : i32 : 512

open_image :: proc(file_path: string) -> (texture_id: im.TextureID)
{       
        file_path := strings.clone_to_cstring(file_path)
        width, height, channels: i32
        img_data := image.load(file_path, &width, &height, &channels, 4)
        defer image.image_free(img_data)

        texture: u32
        gl.GenTextures(1, &texture)
        gl.BindTexture(gl.TEXTURE_2D, texture)
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

        gl.TexImage2D(
                gl.TEXTURE_2D, 0, gl.RGBA,
                width, height, 0,
                gl.RGBA, gl.UNSIGNED_BYTE,
                img_data
        )
        gl.BindTexture(gl.TEXTURE_2D, 0)

        return cast (rawptr) uintptr(texture)
}

