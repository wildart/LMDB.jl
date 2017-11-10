module LMDB_DBI
    using LMDB
    using Base.Test

    const dbname = "testdb"
    key = 10
    val = "key value is "

    # Create dir
    mkdir(dbname)
    try

        # Procedural style
        env = create()
        try
            open(env, dbname)
            txn = start(env)
            dbi = open(txn)
            put!(txn, dbi, key+1, val*string(key+1))
            put!(txn, dbi, key, val*string(key))
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
            set!(env, LMDB.NOSYNC)
            open(env, dbname)
            start(env) do txn
                open(txn, flags = Cuint(LMDB.REVERSEKEY)) do dbi
                    k = key
                    value = get(txn, dbi, k, AbstractString)
                    println("Got value for key $(k): $(value)")
                    @test value == val*string(k)
                    delete!(txn, dbi, k)
                    k += 1
                    value = get(txn, dbi, k, AbstractString)
                    println("Got value for key $(k): $(value)")
                    @test value == val*string(k)
                    delete!(txn, dbi, k, value)
                    @test_throws LMDBError get(txn, dbi, k, AbstractString)
                end
            end
        end
    finally
        rm(dbname, recursive=true)
    end
end
