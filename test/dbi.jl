module LMDB_DBI
    using LMDB
    using Test

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
            put!(txn, dbi, key+2, key+2)
            put!(txn, dbi, key+3, [key, key+1, key+2])
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
            set!(env, LMDB.MDB_NOSYNC)
            open(env, dbname)
            start(env) do txn
                open(txn, flags = Cuint(LMDB.MDB_REVERSEKEY)) do dbi
                    k = key
                    value = get(txn, dbi, k, String)
                    println("Got value for key $(k): $(value)")
                    @test value == val*string(k)
                    delete!(txn, dbi, k)
                    k += 1
                    value = get(txn, dbi, k, String)
                    println("Got value for key $(k): $(value)")
                    @test value == val*string(k)
                    delete!(txn, dbi, k, value)
                    @test_throws LMDBError get(txn, dbi, k, String)
                    k += 1
                    value = get(txn, dbi, k, Int)
                    println("Got value for key $(k): $(value)")
                    @test value == k
                    k += 1
                    value = get(txn, dbi, k, Vector{Int})
                    println("Got value for key $(k): $(value)")
                    @test value == [key, key+1, key+2]
                end
            end
        end
    finally
        rm(dbname, recursive=true)
    end
end
