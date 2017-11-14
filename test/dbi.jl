module LMDB_DBI
    using LMDB
    using Base.Test

    const dbname = "testdb"

    immutable MyType
        intval::Int
        boolval::Bool
    end

    const TEST_SETS = [
        [
             111                => "key value is 11"
            ,110                => "key value is 10"
            ,211                => [MyType(10,true), MyType(11,false)]
            ,210                => [11, 12, 13]
            ,212                => MyType(12,true)
        ]
        ,[
            "311-str"          => 11
            ,"310-str"          => 10
        ]
        ,[
            MyType(10, true)   => MyType(11, false)
        ]
        ,[
            [MyType(10, true)]   => MyType(11, false)
        ]
    ]

    function put_kvpairs(test_pairs)
        env = create()
        try
            open(env, dbname)
            txn = start(env)
            dbi = open(txn)
            for (key,val) in test_pairs
                put!(txn, dbi, key, val)
                println("    put $(key) => $(val)")
            end

            @test isopen(txn)
            commit(txn)
            @test !isopen(txn)
            close(env, dbi)
            @test !isopen(dbi)
        finally
            close(env)
        end
        @test !isopen(env)
    end

    function get_compare_delete(test_pairs)
        create() do env
            set!(env, LMDB.NOSYNC)
            open(env, dbname)
            start(env) do txn
                open(txn, flags = Cuint(LMDB.REVERSEKEY)) do dbi
                    for (key, val) in test_pairs
                        value = get(txn, dbi, key, typeof(val))
                        println("    got $(key) => $(value)")
                        @test value == val
                        delete!(txn, dbi, key)
                        @test_throws LMDBError get(txn, dbi, key, typeof(val))
                    end
                end
            end
        end
    end

    for test_pairs in TEST_SETS
        mkdir(dbname)
        try
            put_kvpairs(test_pairs)
            get_compare_delete(test_pairs)
        finally
            rm(dbname, recursive=true)
        end
    end
end
