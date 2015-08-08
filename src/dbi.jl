"""
A handle for an individual database in the DB environment.
"""
type DBI
    handle::Cuint
    name::String
    DBI(dbi::Cuint, name::String) = new(dbi, name)
end

"Check if database is open"
isopen(dbi::DBI) = dbi.handle != zero(Cuint)

"Open a database in the environment"
function open(txn::Transaction, dbname::String = ""; flags::Cuint=zero(Cuint))
    cdbname = length(dbname) > 0 ? bytestring(dbname) : convert(Cstring, Ptr{UInt8}(C_NULL))
    handle = Cuint[0]
    ret = ccall((:mdb_dbi_open, liblmdb), Cint,
                (Ptr{Void}, Cstring, Cuint, Ptr{Cuint}),
                 txn.handle, cdbname, flags, handle)
    (ret != 0) && throw(LMDBError(ret))
    return DBI(handle[1], dbname)
end

"Wrapper of DBI `open` for `do` construct"
function open(f::Function, txn::Transaction, dbname::String = ""; flags::Cuint=zero(Cuint))
    dbi = open(txn, dbname, flags=flags)
    try
        f(dbi)
    finally
        close(env(txn), dbi)
    end
end

"Close a database handle"
function close(env::Environment, dbi::DBI)
    if !isopen(env)
        warn("Environment is closed")
    end
    ccall((:mdb_dbi_close, liblmdb), Void, (Ptr{Void}, Cuint), env.handle, dbi.handle)
    dbi.handle = zero(Cuint)
end

"Retrieve the DB flags for a database handle"
function flags(txn::Transaction, dbi::DBI)
    flags = Cuint[0]
    ret = ccall((:mdb_dbi_flags, liblmdb), Cint,
                (Ptr{Void}, Cuint, Ptr{Cuint}),
                 txn.handle, dbi.handle, flags)
    (ret != 0) && throw(LMDBError(ret))
    return flags[1]
end

"""Empty or delete+close a database.

If parameter `delete` is `false` DB will be emptied, otherwise
DB will be deleted from the environment and DB handle will be closed
"""
function drop(txn::Transaction, dbi::DBI; delete=false)
    del = delete ? int32(1) : int32(0)
    ret = ccall((:mdb_drop, liblmdb), Cint,
                (Ptr{Void}, Cuint, Cint),
                 txn.handle, dbi.handle, del)
    (ret != 0) && throw(LMDBError(ret))
    return ret
end

"Store items into a database"
function put!(txn::Transaction, dbi::DBI, key, val; flags::Cuint=zero(Cuint))
    mdb_key_ref = Ref(MDBValue(key))
    mdb_val_ref = Ref(MDBValue(val))

    ret = ccall((:mdb_put, liblmdb), Cint,
                (Ptr{Void}, Cuint, Ptr{MDBValue}, Ptr{MDBValue}, Cuint),
                txn.handle, dbi.handle, mdb_key_ref, mdb_val_ref, flags)

    (ret != 0) && throw(LMDBError(ret))
    return ret
end

"Delete items from a database"
function delete!(txn::Transaction, dbi::DBI, key, val)
    mdb_key_ref = Ref(MDBValue(key))
    mdb_val_ref = Ref(MDBValue(val))

    ret = ccall((:mdb_del, liblmdb), Cint,
                (Ptr{Void}, Cuint, Ptr{MDBValue}, Ptr{MDBValue}),
                txn.handle, dbi.handle, mdb_key_ref, mdb_val_ref)

    (ret != 0) && throw(LMDBError(ret))
    return ret
end

"Get items from a database"
function get{T}(txn::Transaction, dbi::DBI, key, ::Type{T})
    # Setup parameters
    mdb_key_ref = Ref(MDBValue(key))
    mdb_val_ref = Ref(MDBValue())

    # Get value
    ret = ccall((:mdb_get, liblmdb), Cint,
                 (Ptr{Void}, Cuint, Ptr{MDBValue}, Ptr{MDBValue}),
                 txn.handle, dbi.handle, mdb_key_ref, mdb_val_ref)
    (ret != 0) && throw(LMDBError(ret))

    # Convert to proper type
    mdb_val = mdb_val_ref[]
    if T <: AbstractString
        value = bytestring(convert(Ptr{UInt8}, mdb_val.data), mdb_val.size)
    else
        nvals = floor(Int, mdb_val.size/sizeof(T))
        value = pointer_to_array(convert(Ptr{T}, mdb_val.data), nvals)
    end
    return length(value) == 1 ? value[1] : value
end