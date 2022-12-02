"""
A DB environment supports multiple databases, all residing in the same shared-memory map.
"""
mutable struct Environment
    handle::Ptr{MDB_env}
    path::String
    Environment() = new(C_NULL, "")
    Environment(h::Ptr{MDB_env}) = new(h, "")
end

"Return the path that was used in `open`"
path(env::Environment) = env.path

"Check if environment is open"
isopen(env::Environment) = env.handle != C_NULL

"Create an LMDB environment handle"
function create()
    env_ref = Ref{Ptr{MDB_env}}()
    mdb_env_create(env_ref)
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
function open(env::Environment, path::String; flags::Cuint=zero(Cuint), mode::LibLMDB.mode_t = LibLMDB.mode_t(0o755))
    env.path = path
    mdb_env_open(env.handle, path, flags, mode)
end

"Wrapper of `open` for `do` construct"
function environment(f::Function, path::String; flags::Cuint=zero(Cuint), mode::LibLMDB.mode_t = LibLMDB.mode_t(0o755))
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
    _mdb_env_close(env.handle)
    env.handle = C_NULL
    env.path = ""
    return zero(Cint)
end

"""Flush the data buffers to disk"""
function sync(env::Environment, force::Bool = false)
    fval = force ? 1 : 0
    mdb_env_sync(env.handle, fval)
    return zero(Cint)
end

"""Set environment flags"""
function set!(env::Environment, flag::Cuint)
    mdb_env_set_flags(env.handle, flag, one(Cint))
    return flag
end
set!(env::Environment, flag::EnvironmentFlags) = set!(env, Cuint(flag))

"""Unset environment flags"""
function unset!(env::Environment, flag::Cuint)
    mdb_env_set_flags(env.handle, flag, zero(Cint))
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
    if option == :Readers
        mdb_env_set_maxreaders(env.handle, val)
    elseif option == :DBs
        mdb_env_set_maxdbs(env.handle, val)
    else
        @warn("Cannot set $(string(option)) value")
        Cint(0)
    end
end

function setindex!(env::Environment, val::Csize_t, option::Symbol)
    if  option == :MapSize
        println("Setting map size to: ", val)
        mdb_env_set_mapsize(env.handle, val)
    else
        warn("Cannot set $(string(option)) value")
        Cint(0)
    end
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
        mdb_env_get_flags(env.handle, value)
    elseif option == :Readers
        mdb_env_get_maxreaders(env.handle, value)
    elseif option == :KeySize
        value[1] = _mdb_env_get_maxkeysize(env.handle)
    else
        @warn("Cannot get $(string(option)) value")
    end
    return value[1]
end

"""Return information about the LMDB environment."""
function info(env::Environment)
    ei_ref = Ref{MDB_envinfo}()
    !isopen(env) && return MDB_envinfo(C_NULL, 0, 0, 0, 0, 0)
    ret = mdb_env_info(env.handle, ei_ref)
    return ei_ref[]
end

function show(io::IO, env::Environment)
    print(io,"Environment is ", isopen(env) ? (isempty(env.path) ? "created" : "opened") : "closed")
    if !isempty(env.path)
        print(io,"\nDB path: $(path(env))")
        ei = info(env)
        print(io,"\nSize of the data memory map: $(ei.me_mapsize)")
        print(io,"\nID of the last used page: $(ei.me_last_pgno)")
        print(io,"\nID of the last committed transaction: $(ei.me_last_txnid)")
        print(io,"\nMax reader slots in the environment: $(ei.me_maxreaders)")
        print(io,"\nMax reader slots used in the environment: $(ei.me_numreaders)")
    end
end
