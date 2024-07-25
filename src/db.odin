package main

import sql      "../lib/odin-sqlite3/sqlite3_wrap"

import stb_img  "vendor:stb/image"

import fp       "core:path/filepath"
import          "core:os"
import          "core:slice"

import          "core:time"
import          "core:strings"

import          "core:fmt"


db      : ^sql.DB

Image :: struct {
        id            : int,
        path          : string,
        hash          : string,
        size          : int,
        width         : int,
        height        : int,
        file_type     : string,
        date_added    : string,
        date_modified : string,
        use_count     : int,
}

Tag :: struct {
        id            : int,
        name          : string,
        date_added    : string,
        date_modified : string,
        is_sensitive  : bool,
        use_count     : int,
}

ImageTag :: struct {
        image_id      : int,
        tag_id        : int,
}

init_db :: proc(database_path: cstring) 
{
        err: sql.Status
        db, err = sql.open(database_path)
        assert(err == nil, string(sql.status_explain(err)))

        create_tables()
}

close_db :: proc() 
{
        sql.close(db)
}

create_tables :: proc() {
        err: sql.Status

        err = sql.sql_exec(db, `
                CREATE TABLE IF NOT EXISTS Images (
                        id            INTEGER PRIMARY KEY,
                        path          TEXT NOT NULL UNIQUE,
                        hash          TEXT NOT NULL,
                        size          INTEGER NOT NULL,
                        width         INTEGER,
                        height        INTEGER,
                        file_type     TEXT,
                        date_added    TEXT NOT NULL,
                        date_modified TEXT NOT NULL,
                        use_count     INTEGER NOT NULL DEFAULT 0
                );
                CREATE INDEX IF NOT EXISTS idx_images_hash ON Images(hash);
                CREATE INDEX IF NOT EXISTS idx_images_date_added ON Images(date_added);
                `)
        assert(err == nil, string(sql.status_explain(err)))

        err = sql.sql_exec(db, `
                CREATE TABLE IF NOT EXISTS Tags (
                        id            INTEGER PRIMARY KEY,
                        name          TEXT NOT NULL UNIQUE,
                        date_added    TEXT NOT NULL,
                        date_modified TEXT NOT NULL,
                        is_sensitive  INTEGER NOT NULL,
                        use_count     INTEGER NOT NULL DEFAULT 0
                );
                CREATE INDEX IF NOT EXISTS idx_tags_name ON Tags(name);
                `)
        assert(err == nil, string(sql.status_explain(err)))

        err = sql.sql_exec(db, `
                CREATE TABLE IF NOT EXISTS ImageTags (
                        image_id      INTEGER NOT NULL,
                        tag_id        INTEGER NOT NULL,
                        PRIMARY KEY (image_id, tag_id),
                        FOREIGN KEY (image_id) REFERENCES Images(id) ON DELETE CASCADE,
                        FOREIGN KEY (tag_id) REFERENCES Tags(id) ON DELETE CASCADE
                );
                CREATE INDEX IF NOT EXISTS idx_imagetags_image_id ON ImageTags(image_id);
                CREATE INDEX IF NOT EXISTS idx_imagetags_tag_id ON ImageTags(tag_id);
                `)
        assert(err == nil, string(sql.status_explain(err)))
}

deep_copy :: proc(src: Image) -> Image
{
        return Image{
                id            = src.id,
                path          = strings.clone(src.path),
                hash          = strings.clone(src.hash),
                size          = src.size,
                width         = src.width,
                height        = src.height,
                file_type     = strings.clone(src.file_type),
                date_added    = strings.clone(src.date_added),
                date_modified = strings.clone(src.date_modified),
                use_count     = src.use_count,
        }
}

get_all_images :: proc()
{
        query, _ := sql.sql_bind(db, `SELECT * FROM Images`)

        images : [dynamic]Image
        clear_dynamic_array(&display_list)
        for image in sql.sql_row(db, query, Image) {
                append_elem(&display_list, deep_copy(image))
        }
}

ADD_IMAGE_QUERY ::
`
INSERT INTO Images (path, hash, size, width, height, file_type, date_added, date_modified)
VALUES (?, ?, ?, ?, ?, ?, ?, ?)
`

add_image :: proc(path: string) -> bool
{
        path       := fp.abs(path) or_return
        file_type  := fp.ext(path)
        if !slice.contains(ALLOWED_EXTENSIONS, file_type) do return false
        
        hash       := "hash"
        width, height: i32

        stb_img.info(
                strings.clone_to_cstring(path),
                &width,
                &height,
                nil,
        )

        fd, fd_err := os.open(path, os.O_RDONLY)
        if  fd_err != os.ERROR_NONE do return false

        size, size_err := os.file_size(fd)
        if size_err != os.ERROR_NONE do return false
        
        file_info, file_info_err:= os.stat(path)
        if file_info_err != os.ERROR_NONE do return false

        date_added    := time_format(file_info.creation_time)
        date_modified := date_added

        os.close(fd)

        result := sql.sql_exec(
                db,
                ADD_IMAGE_QUERY,
                strings.clone_to_cstring(path),
                hash,
                size,
                width,
                height,
                file_type,
                date_added,
                date_modified,
        )

        return result == .Ok
}

time_format :: proc(t: time.Time) -> string
{
        y := time.year(t)
        m := cast (int) time.month(t)
        d := time.day(t)
        h, min, s := 0, 0, 0

        return fmt.tprintf("%d-%02d-%02d %02d:%02d:%02d",
                y, m, d, h, min, s
        )
}
