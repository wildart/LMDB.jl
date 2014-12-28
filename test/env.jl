module LMDB_Env
    using LMDB
    using Base.Test

    const dbname = "testdb"

    # Open environemnt
    env = create()
    @test env.handle != C_NULL
    @test get(env, :Readers) == 126
    @test get(env, :KeySize) == 511
    @test !isopen(env)

    # Manipulate flags
    @test !isflagset(get(env, :Flags), LMDB.NOSYNC)
    put!(env, :Flags, LMDB.NOSYNC)
    @test isflagset(get(env, :Flags), LMDB.NOSYNC)
    unset(env, LMDB.NOSYNC)
    @test !isflagset(get(env, :Flags), LMDB.NOSYNC)

    # Parameters
    @test put!(env, :Readers, 100) == 0
    @test put!(env, :MapSize, 1000^2) == 0
    @test put!(env, :DBs, 10) == 0
    @test get(env, :Readers) == 100

    # open db
    mkdir(dbname)
    ret = open(env, dbname)
    @test ret[1] == 0

    # Close environment
    close(env)
    @test !isopen(env)

    # do block
    create() do env
        put!(env, :Flags, LMDB.NOSYNC)
        open(env, dbname)
        @test isopen(env)
    end
    run(`rm -rf $(dbname)`)
end