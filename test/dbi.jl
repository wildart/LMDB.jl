module LMDB_DBI
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
        put(env, :Flags, LMDB.NOSYNC)
        open(env, dbname)
        txn = start(env)
        dbi = open(txn)
        put(txn, dbi, key+1, val*string(key+1))
        put(txn, dbi, key, val*string(key))
        @test isopen(txn)
        commit(txn)
        @test !isopen(txn)
        close(env, dbi)
        @test !isopen(dbi)
    finally
        close(env)
    end
    @test !isopen(env)

    # Block style
    create() do env
        put(env, :Flags, LMDB.NOSYNC)
        open(env, dbname)
        start(env) do txn
            open(txn, flags = REVERSEKEY) do (txn, dbi)
                @test get(txn, dbi, key) == val*string(key)
                abort(txn)
            end
        end
    end

    # Block style
    create() do env
        put(env, :Flags, LMDB.NOSYNC)
        open(env, dbname)
        open(start(env), flags = REVERSEKEY) do (txn, dbi)
            @test get(txn, dbi, key) == val*string(key)
            abort(txn)
        end
    end

    run(`rm -rf $(dbname)`)
end