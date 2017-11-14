module LMDB_Common
    using LMDB
    using Base.Test
    import LMDB.MDBValue

    @test LMDB.version()[1] >= v"0.9.15"

    # LMDBError
    ex = LMDBError(Cint(0))
    @test_throws LMDBError throw(ex)
    @test ex.code == 0

    # MDBValue
    val = "abcd"
    mdb_val_ref = Ref(MDBValue(val))
    mdb_val = mdb_val_ref[]
    @test val == unsafe_string(convert(Ptr{UInt8}, mdb_val.data), mdb_val.size)

    val = [1233]
    T = eltype(val)
    val_size = sizeof(val)
    mdb_val = MDBValue(val)
    @test val_size == mdb_val.size
    nvals = floor(Int, mdb_val.size/sizeof(T))
    value = unsafe_wrap(Array, convert(Ptr{T}, mdb_val.data), nvals)
    @test val == value

    val = [0x0003, 0xff45]
    val_size = sizeof(val)
    T = eltype(val)
    mdb_val = MDBValue(val)
    @test val_size == mdb_val.size
    nvals = floor(Int, mdb_val.size/sizeof(T))
    value = unsafe_wrap(Array, convert(Ptr{T}, mdb_val.data), nvals)
    @test val == value
end
