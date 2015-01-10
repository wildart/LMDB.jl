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
        #put!(env, :DBs, 2)
        #open(env, dbname; flags = LMDB.FIXEDMAP)
        open(env, dbname)
        txn = start(env)
        dbi = open(txn)
        insert!(txn, dbi, key+1, val*string(key+1))
        insert!(txn, dbi, key, val*string(key))
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
        put!(env, :Flags, LMDB.NOSYNC)
        open(env, dbname)
        start(env) do txn
            open(txn, flags = LMDB.REVERSEKEY) do dbi
                value = get(txn, dbi, key, String)
                println("Got value for key $(key): $(value)")
                @test value == val*string(key)
            end
        end
    end

    rm(dbname, recursive=true)
end