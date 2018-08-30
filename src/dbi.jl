"""
A handle for an individual database in the DB environment.
"""
mutable struct DBI
    handle::Cuint
    name::String
    DBI(dbi::Cuint, name::String) = new(dbi, name)
end

"Check if database is open"
isopen(dbi::DBI) = dbi.handle != zero(Cuint)

"Open a database in the environment"
function open(txn::Transaction, dbname::String = ""; flags::Cuint = zero(Cuint))
    cdbname = length(dbname) > 0 ? dbname : convert(Cstring, Ptr{UInt8}(C_NULL))
    handle = Cuint[0]
    ret = ccall((:mdb_dbi_open, liblmdb), Cint,
                (Ptr{Nothing}, Cstring, Cuint, Ptr{Cuint}),
                 txn.handle, cdbname, flags, handle)
    (ret != 0) && throw(LMDBError(ret))
    return DBI(handle[1], dbname)
end

"Wrapper of DBI `open` for `do` construct"
function open(f::Function, txn::Transaction, dbname::String = ""; flags::Cuint = zero(Cuint))
    dbi = open(txn, dbname, flags=flags)
    tenv = env(txn)
    try
        f(dbi)
    finally
        close(tenv, dbi)
    end
end

"Close a database handle"
function close(env::Environment, dbi::DBI)
    if !isopen(env)
        warn("Environment is closed")
    end
    ccall((:mdb_dbi_close, liblmdb), Nothing, (Ptr{Nothing}, Cuint), env.handle, dbi.handle)
    dbi.handle = zero(Cuint)
    return
end

"Retrieve the DB flags for a database handle"
function flags(txn::Transaction, dbi::DBI)
    flags = Cuint[0]
    ret = ccall((:mdb_dbi_flags, liblmdb), Cint,
                (Ptr{Nothing}, Cuint, Ptr{Cuint}),
                 txn.handle, dbi.handle, flags)
    (ret != 0) && throw(LMDBError(ret))
    return flags[1]
end

"""Empty or delete+close a database.

If parameter `delete` is `false` DB will be emptied, otherwise
DB will be deleted from the environment and DB handle will be closed
"""
function drop(txn::Transaction, dbi::DBI; delete = false)
    del = delete ? Int32(1) : Int32(0)
    ret = ccall((:mdb_drop, liblmdb), Cint,
                (Ptr{Nothing}, Cuint, Cint),
                 txn.handle, dbi.handle, del)
    (ret != 0) && throw(LMDBError(ret))
    return ret
end

"Store items into a database"
function put!(txn::Transaction, dbi::DBI, key, val; flags::Cuint = zero(Cuint))
    k = isbitstype(typeof(key)) ? [key] :  key
    mdb_key_ref = Ref(MDBValue(k))
    v = isbitstype(typeof(val)) ? [val] :  val
    mdb_val_ref = Ref(MDBValue(v))

    ret = ccall((:mdb_put, liblmdb), Cint,
                (Ptr{Nothing}, Cuint, Ptr{MDBValue}, Ptr{MDBValue}, Cuint),
                txn.handle, dbi.handle, mdb_key_ref, mdb_val_ref, flags)

    (ret != 0) && throw(LMDBError(ret))
    return ret
end

"Delete items from a database"
function delete!(txn::Transaction, dbi::DBI, key, val=C_NULL)
    k = isbitstype(typeof(key)) ? [key] : key
    mdb_key_ref = Ref(MDBValue(k))
    v = isbitstype(typeof(val)) ? [val] : val
    mdb_val_ref = Ref((val === C_NULL) ? MDBValue() : MDBValue(v))

    ret = ccall((:mdb_del, liblmdb), Cint,
                (Ptr{Nothing}, Cuint, Ptr{MDBValue}, Ptr{MDBValue}),
                txn.handle, dbi.handle, mdb_key_ref, mdb_val_ref)

    (ret != 0) && throw(LMDBError(ret))
    return ret
end

"Get items from a database"
function get(txn::Transaction, dbi::DBI, key, ::Type{T}) where T
    # Setup parameters
    k = isbitstype(typeof(key)) ? [key] :  key
    mdb_key_ref = Ref(MDBValue(k))
    mdb_val_ref = Ref(MDBValue())

    # Get value
    ret = ccall((:mdb_get, liblmdb), Cint,
                 (Ptr{Nothing}, Cuint, Ptr{MDBValue}, Ptr{MDBValue}),
                 txn.handle, dbi.handle, mdb_key_ref, mdb_val_ref)
    (ret != 0) && throw(LMDBError(ret))

    # Convert to proper type
    return convert(T, mdb_val_ref)
end
