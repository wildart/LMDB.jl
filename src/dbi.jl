"A handle for an individual database in the DB environment."
type DBI
    handle::Cuint
    name::String
    DBI(dbi::Cuint, name::String) = new(dbi, name)
end

@doc "Check if database is open." ->
isopen(dbi::DBI) = dbi.handle != 0x00000000

@doc "Open a database in the environment."->
function open(txn::Transaction; dbname::String = "", flags::Uint32 = 0x00000000)
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
function open(f::Function, txn::Transaction; dbname::String = "", flags::Uint32 = 0x00000000)
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
    dbi.handle = 0x00000000
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

