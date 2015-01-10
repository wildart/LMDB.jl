module LMDB_CUR
    using LMDB
    using Base.Test

    const dbname = "testdb"
    key = 10
    val = "key value is "

    # Create dir
    mkdir(dbname)

    # Procedural style
    env = create()
    try
        open(env, dbname)
        txn = start(env)
        dbi = open(txn)
        commit(txn)

        txn = start(env)
        cur = open(txn, dbi)
        try
            @test 0 == insert!(cur, key+1, val*string(key+1))
            @test 0 == insert!(cur, key, val*string(key))
        finally
            close(cur)
            commit(txn)
        end
        @test !isopen(cur)
        @test !isopen(txn)
    finally
        close(env)
    end
    @test !isopen(env)

    # Remove db dir
    rm(dbname, recursive=true)
end