package main

import sql      "../lib/odin-sqlite3/sqlite3_wrap"


db      : ^sql.DB

init_db :: proc(database_path: cstring) 
{
        err: sql.Status
        db, err = sql.open(database_path)
        assert(err == nil, string(sql.status_explain(err)))
}

close_db :: proc() 
{
        sql.close(db)
}
