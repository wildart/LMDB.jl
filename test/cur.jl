module LMDB_CUR
    using LMDB
    using Test

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
            @test 0 == put!(cur, key+1, val*string(key+1))
            @test 0 == put!(cur, key, val*string(key))
            @test issetequal(collect(keys(cur, typeof(key))), [11, 10])
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

    # Block style
    environment(dbname) do env # open environment
        start(env) do txn # start transaction
            open(txn) do dbi # open database
                open(txn, dbi) do cur # open cursor
                    curtxn = transaction(cur)
                    @test curtxn.handle == txn.handle
                    curdbi = database(cur)
                    @test curdbi.handle == dbi.handle
                    v = get(cur, key, String)
                    println("Got value for key $(key): $(v)")
                    @test val*string(key) == v
                end
            end
        end
    end

    # Remove db dir
    rm(dbname, recursive=true)
end
