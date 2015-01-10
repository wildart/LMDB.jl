"A handle for an individual database in the DB environment."
type DBI
    handle::Cuint
    name::String
    DBI(dbi::Cuint, name::String) = new(dbi, name)
end

@doc "Check if database is open." ->
isopen(dbi::DBI) = dbi.handle != EMPTY

@doc "Open a database in the environment."->
function open(txn::Transaction; dbname::String = "", flags::Uint32 = EMPTY)
    if length(dbname) > 0
        cdbname = bytestring(dbname)
    else
        cdbname = C_NULL
    end
    handle = Cuint[0]
    ret = ccall( (:mdb_dbi_open, liblmdbjl), Cint, (Ptr{Void}, Ptr{Cchar}, Cuint, Ptr{Cuint}), txn.handle, cdbname, flags, handle)
    if ret != 0
        warn(errormsg(ret))
        handle[1] = 0
    end
    return DBI(handle[1], dbname)
end

@doc "Wrapper of DBI `open` for `do` construct." ->
function open(f::Function, txn::Transaction; dbname::String = "", flags::Uint32 = EMPTY)
    dbi = open(txn; dbname=dbname, flags=flags)
    try
        f(dbi)
    finally
        close(environment(txn), dbi)
    end
end

@doc "Close a database handle."->
function close(env::Environment, dbi::DBI)
    if !isopen(env)
        error("Environment is closed")
    end
    ccall( (:mdb_dbi_close, liblmdbjl), Cint, (Ptr{Void}, Cuint), env.handle, dbi.handle)
    dbi.handle = EMPTY
end

@doc "Retrieve the DB flags for a database handle."->
function get(txn::Transaction, dbi::DBI)
    flags = Cuint[0]
    ret = ccall( (:mdb_dbi_flags, liblmdbjl), Cint, (Ptr{Void}, Cuint, Ptr{Cuint}), txn.handle, dbi.handle, flags)
    if ret != 0
        warn(errormsg(ret))
    end
    return flags[1]
end

@doc "Empty or delete+close a database."->
function drop(txn::Transaction, dbi::DBI; delete=false)
    del = delete ? int32(1) : int32(0)
    ret = ccall( (:mdb_drop, liblmdbjl), Cint, (Ptr{Void}, Cuint, Cint), txn.handle, dbi.handle, del)
    if ret != 0
        warn(errormsg(ret))
    end
    return flags[1]
end

@doc "Store items into a database."->
function insert!(txn::Transaction, dbi::DBI, key, val; flags::Uint32 = EMPTY)
    keysize = Csize_t[sizeof(key)]
    valsize = Csize_t[sizeof(val)]

    if isa(key, Number)
        keyval=typeof(key)[key]
    else
        keyval=pointer(key)
    end

    if isa(val, Number)
        valval=typeof(val)[val]
    else
        valval=pointer(val)
    end

    ret = ccall( (:mdb_kv_put, liblmdbjl), Cint,
                 (Ptr{Void}, Cuint, Csize_t, Ptr{Void}, Csize_t, Ptr{Void}, Cuint),
                 txn.handle, dbi.handle, keysize[1], keyval, valsize[1], valval, flags)
    if ret != 0
        warn(errormsg(ret))
    end
    return ret
end

@doc "Get items from a database."->
function get{T}(txn::Transaction, dbi::DBI, key, ::Type{T})
    # Setup parameters
    keysize = Csize_t[sizeof(key)]
    valsize = Csize_t[0]
    if isa(key, Number)
        keyval=typeof(key)[key]
    else
        keyval=pointer(key)
    end
    rc = Cint[0]

    # Get value
    val = ccall( (:mdb_kv_get, LMDB.liblmdbjl), Ptr{Cuchar},
                 (Ptr{Void}, Cuint, Csize_t, Ptr{Void}, Ptr{Csize_t}, Ptr{Cint}),
                 txn.handle, dbi.handle, keysize[1], keyval, valsize, rc)
    ret = rc[1]
    if ret != 0
        warn(errormsg(ret))
    end

    # Convert to proper type
    value = pointer_to_array(val, (valsize[1],), true)
    if T <: String
        value = bytestring(value)
    else
        value = reinterpret(T, value)
    end
    return length(value) == 1 ? value[1] : value
end