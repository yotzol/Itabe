package main

import sql      "../lib/odin-sqlite3/sqlite3_wrap"

import "core:time"


db      : ^sql.DB

Image :: struct {
        id            : int,
        path          : string,
        hash          : string,
        size          : int,
        width         : int,
        height        : int,
        file_type     : string,
        date_added    : time.Time,
        date_modified : time.Time,
        use_count     : int,
        tags          : []ImageTag,
}

Tag :: struct {
        id            : int,
        name          : string,
        date_added    : time.Time,
        date_modified : time.Time,
        is_sensitive  : bool,
        use_count     : int,
        images        : []ImageTag,
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

        images := get_all_images()
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


get_all_images :: proc() -> []Image
{
        query, _ := sql.sql_bind(db, `
                SELECT * FROM Images
                `)

        images : [dynamic]Image

        for image in sql.sql_row(db, query, Image) {
                append_elem(&images, image)
        }

        return images[:]
}

add_image :: proc(image: Image)
{
        query := `
                INSERT INTO Images (path, hash, size, width, height, file_type, date_added, date_modified)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        `
        sql.sql_exec(db, query, image.path, image.hash, image.size, image.width, image.height, image.file_type, image.date_added, image.date_modified)
}
