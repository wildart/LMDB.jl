module LMDB_Common
    using LMDB
    using Base.Test

    @test LMDB.version()[1] == v"0.9.15"

    ex = LMDBError(0)
    @test_throws LMDBError throw(ex)
    @test ex.code == 0
end