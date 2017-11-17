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
    val = "abcd" # string
    mdb_val_ref = Ref(MDBValue(val))
    mdb_val = mdb_val_ref[]
    # @test val == unsafe_string(convert(Ptr{UInt8}, mdb_val.data), mdb_val.size)
    @test val == convert(String, mdb_val_ref)

    val = [1233] # dense array
    T = eltype(val)
    val_size = sizeof(val)
    mdb_val_ref = Ref(MDBValue(val))
    mdb_val = mdb_val_ref[]
    @test val_size == mdb_val.size
    nvals = floor(Int, mdb_val.size/sizeof(T))
    value = unsafe_wrap(Array, convert(Ptr{T}, mdb_val.data), nvals)
    @test val == value
    @test val == convert(Vector{Int}, mdb_val_ref)

    val = [0x0003, 0xff45]
    val_size = sizeof(val)
    T = eltype(val)
    mdb_val_ref = Ref(MDBValue(val))
    mdb_val = mdb_val_ref[]
    @test val_size == mdb_val.size
    nvals = floor(Int, mdb_val.size/sizeof(T))
    value = unsafe_wrap(Array, convert(Ptr{T}, mdb_val.data), nvals)
    @test val == value
    @test val == convert(Vector{UInt16}, mdb_val_ref)

    struct TestType
        i::Int
        j::Char
    end
    val = TestType(1,'a') # struct
    val_size = sizeof(val)
    T = typeof(val)
    @test_throws ErrorException MDBValue(val)
    val = [val]
    mdb_val_ref = Ref(MDBValue(val))
    mdb_val = mdb_val_ref[]
    @test val_size == mdb_val.size
    nvals = floor(Int, mdb_val.size/sizeof(T))
    value = unsafe_wrap(Array, convert(Ptr{T}, mdb_val.data), nvals)
    @test val == value
    @test val == convert(Vector{T}, mdb_val_ref)
    @test val[1] == convert(T, mdb_val_ref)
end
