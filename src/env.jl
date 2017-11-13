"""
A DB environment supports multiple databases, all residing in the same shared-memory map.
"""
mutable struct Environment
    handle::Ptr{Void}
    path::String
    Environment() = new(C_NULL, "")
    Environment(h::Ptr{Void}) = new(h, "")
end

"Return the path that was used in `open`"
path(env::Environment) = env.path

"Check if environment is open"
isopen(env::Environment) = env.handle != C_NULL

"Create an LMDB environment handle"
function create()
    env_ref = Ref{Ptr{Void}}(C_NULL)
    ret = ccall( (:mdb_env_create, liblmdb), Cint, (Ptr{Ptr{Void}},), env_ref)
    (ret != 0) && throw(LMDBError(ret))
    return Environment(env_ref[])
end

"Wrapper of `create` for `do` construct"
function create(f::Function)
    env = create()
    try
        f(env)
    finally
        close(env)
    end
end

"""Open an environment handle

`open` function accepts folowing parameters:
* `env` db environment object
* `path` directory in which the database files reside
* `flags` defines special options for the environment
* `mode` UNIX permissions to set on created files

*Note:* A database directory must exist and be writable.
"""
function open(env::Environment, path::String; flags::Cuint=zero(Cuint), mode::Cmode_t = 0o755)
    env.path = path
    ret = ccall((:mdb_env_open, liblmdb), Cint,
                 (Ptr{Void}, Cstring, Cuint, Cmode_t),
                  env.handle, path, flags, mode)
    (ret != 0) && throw(LMDBError(ret))
    return ret::Cint
end

"Wrapper of `open` for `do` construct"
function open(f::Function, path::String; flags::Cuint=zero(Cuint), mode::Cmode_t = 0o755)
    env = create()
    try
        open(env, path)
        f(env)
    finally
        close(env)
    end
end

"""Close the environment and release the memory map"""
function close(env::Environment)
    if env.handle == C_NULL
        throw(LMDBError(-1,"Environment is already closed"))
    end
    ccall( (:mdb_env_close, liblmdb), Void, (Ptr{Void},), env.handle)
    env.handle = C_NULL
    env.path = ""
    return
end

"""Flush the data buffers to disk"""
function sync(env::Environment, force::Bool = false)
    fval = force ? 1 : 0
    ret = ccall( (:mdb_env_sync, liblmdb), Cint, (Ptr{Void}, Cint), env.handle, fval)
    (ret != 0) && throw(LMDBError(ret))
    return ret::Cint
end

"""Set environment flags"""
function set!(env::Environment, flag::Cuint)
    ret = ccall( (:mdb_env_set_flags, liblmdb), Cint, (Ptr{Void}, Cuint, Cint), env.handle, flag, one(Cint))
    (ret != 0) && throw(LMDBError(ret))
    return flag
end
set!(env::Environment, flag::EnvironmentFlags) = set!(env, Cuint(flag))

"""Unset environment flags"""
function unset!(env::Environment, flag::Cuint)
    ret = ccall( (:mdb_env_set_flags, liblmdb), Cint, (Ptr{Void}, Cuint, Cint), env.handle, flag, zero(Cint))
    (ret != 0) && throw(LMDBError(ret))
    return flag
end
unset!(env::Environment, flag::EnvironmentFlags) = unset!(env, Cuint(flag))


"""Set environment flags and parameters

`setindex!` accepts folowing parameters:
* `env` db environment object
* `option` symbol which indicates parameter. Currently supported parameters:
    * Flags
    * Readers
    * MapSize
    * DBs
* `value` parameter value

**Note:** Consult LMDB documentation for particual values of environment parameters and flags.
"""
function setindex!(env::Environment, val::Cuint, option::Symbol)
    ret = zero(Cint)
    if option == :Readers
        ret = ccall( (:mdb_env_set_maxreaders, liblmdb), Cint, (Ptr{Void}, Cuint), env.handle, val)
    elseif option == :MapSize
        ret = ccall( (:mdb_env_set_mapsize, liblmdb), Cint, (Ptr{Void}, Cuint), env.handle, val)
    elseif option == :DBs
        ret = ccall( (:mdb_env_set_maxdbs, liblmdb), Cint, (Ptr{Void}, Cuint), env.handle, val)
    else
        warn("Cannot set $(string(option)) value")
    end
    (ret != 0) && throw(LMDBError(ret))
    return ret
end
setindex!(env::Environment, val::Int, option::Symbol) = setindex!(env, Cuint(val), option)

"""Get environment flags and parameters

`getindex` accepts folowing parameters:
* `env` db environment object
* `option` symbol which indicates parameter. Currently supported parameters:
    * Flags
    * Readers
    * KeySize

**Note:** Consult LMDB documentation for particual values of environment parameters and flags.
"""
function getindex(env::Environment, option::Symbol)
    value = Cuint[0]
    if option == :Flags
        flags = Cuint[0]
        ret = ccall( (:mdb_env_get_flags, liblmdb), Cint, (Ptr{Void}, Ptr{Cuint}), env.handle, value)
        (ret != 0) && throw(LMDBError(ret))
    elseif option == :Readers
        ret = ccall( (:mdb_env_get_maxreaders, liblmdb), Cint, (Ptr{Void}, Ptr{Cuint}), env.handle, value)
        (ret != 0) && throw(LMDBError(ret))
    elseif option == :KeySize
        value[1] = ccall( (:mdb_env_get_maxkeysize, liblmdb), Cint, (Ptr{Void}, ), env.handle)
    else
        warn("Cannot get $(string(option)) value")
    end
    return value[1]
end

"""Information about the environment"""
struct EnvironmentInfo
    mapaddr::Ptr{Void}
    mapsize::Csize_t     # Size of the data memory map
    last_pgno::Csize_t   # ID of the last used page
    last_txnid::Csize_t  # ID of the last committed transaction
    maxreaders::Cuint    # max reader slots in the environment */
    numreaders::Cuint    # max reader slots used in the environment */
    EnvironmentInfo() = new(C_NULL, zero(Csize_t), zero(Csize_t), zero(Csize_t), zero(Cuint), zero(Cuint))
end

"""Return information about the LMDB environment."""
function info(env::Environment)
    ei_ref = Ref(EnvironmentInfo())
    !isopen(env) && return ei_ref[]
    ret = ccall( (:mdb_env_info, liblmdb), Cint, (Ptr{Void}, Ptr{EnvironmentInfo}), env.handle, ei_ref)
    (ret != 0) && throw(LMDBError(ret))
    return ei_ref[]
end

function show(io::IO, env::Environment)
    print(io,"Environment is ", isopen(env) ? (isempty(env.path) ? "created" : "opened") : "closed")
    if !isempty(env.path)
        print(io,"\nDB path: $(path(env))")
        ei = info(env)
        print(io,"\nSize of the data memory map: $(ei.mapsize)")
        print(io,"\nID of the last used page: $(ei.last_pgno)")
        print(io,"\nID of the last committed transaction: $(ei.last_txnid)")
        print(io,"\nMax reader slots in the environment: $(ei.maxreaders)")
        print(io,"\nMax reader slots used in the environment: $(ei.numreaders)")
    end
end
