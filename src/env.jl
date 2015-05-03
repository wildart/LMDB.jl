"""
A DB environment supports multiple databases, all residing in the same shared-memory map.
"""
type Environment
    handle::Ptr{Void}
    path::String
    Environment() = new(C_NULL, "")
    Environment(h::Ptr{Void}) = new(h, "")
end

"Return the path that was used in `open`"
path(env::Environment) = env.path

"Check if environment is open"
isopen(env::Environment) = env.handle != C_NULL && length(path(env))>0

"Create an LMDB environment handle"
function create()
    handle = ccall( (:mdb_env_create_default, liblmdbjl), Ptr{Void}, ())
    return Environment(handle)
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
function open(env::Environment, path::String; flags::Uint32 = EMPTY, mode::Int32 = int32(436))
    env.path = path
    cpath = bytestring(path)
    ret = ccall( (:mdb_env_open, liblmdbjl), Cint, (Ptr{Void}, Ptr{Cchar}, Cuint, Cint), env.handle, cpath, flags, mode)
    (ret != 0) && error(errormsg(ret))
    return ret::Cint
end

"Close the environment and release the memory map"
function close(env::Environment)
    if env.handle == C_NULL
        warn("Environment is already closed")
    end
    ccall( (:mdb_env_close, liblmdbjl), Void, (Ptr{Void},), env.handle)
    env.handle = C_NULL
    env.path = ""
end

"Flush the data buffers to disk"
function sync(env::Environment, force::Bool = false)
    fval = force ? 1 : 0
    ret = ccall( (:mdb_env_sync, liblmdbjl), Cint, (Ptr{Void}, Cint), env.handle, fval)
    (ret != 0) && error(errormsg(ret))
    return ret::Cint
end

"Unset environment flags"
function unset(env::Environment, flag::Cuint)
    ret = ccall( (:mdb_env_set_flags, liblmdbjl), Cint, (Ptr{Void}, Cuint, Cint), env.handle, flag, 0)
    (ret != 0) && error(errormsg(ret))
    return ret::Cint
end

"""Set environment flags and parameters

`put!` accepts folowing parameters:
* `env` db environment object
* `option` symbol which indicates parameter. Currently supported parameters:
    * Flags
    * Readers
    * MapSize
    * DBs
* `value` parameter value

**Note:** Consult LMDB documentation for particual values of environment parameters and flags.
"""
function put!(env::Environment, option::Symbol, val::Cuint)
    ret = int32(0)
    if option == :Flags
        ret = ccall( (:mdb_env_set_flags, liblmdbjl), Cint, (Ptr{Void}, Cuint, Cint), env.handle, val, 1)
    elseif option == :Readers
        ret = ccall( (:mdb_env_set_maxreaders, liblmdbjl), Cint, (Ptr{Void}, Cuint), env.handle, val)
    elseif option == :MapSize
        ret = ccall( (:mdb_env_set_mapsize, liblmdbjl), Cint, (Ptr{Void}, Cuint), env.handle, val)
    elseif option == :DBs
        ret = ccall( (:mdb_env_set_maxdbs, liblmdbjl), Cint, (Ptr{Void}, Cuint), env.handle, val)
    else
        error("Parameters $(string(option)) is not defined")
    end
    (ret != 0) && error(errormsg(ret))
    return ret
end
put!(env::Environment, option::Symbol, val::Int) = put!(env, option, uint32(val))

"""Get environment flags and parameters

`get` accepts folowing parameters:
* `env` db environment object
* `option` symbol which indicates parameter. Currently supported parameters:
    * Flags
    * Readers
    * KeySize

**Note:** Consult LMDB documentation for particual values of environment parameters and flags.
"""
function get(env::Environment, option::Symbol)
    value = Cuint[0]
    if option == :Flags
        flags = Cuint[0]
        ret = ccall( (:mdb_env_get_flags, liblmdbjl), Cint, (Ptr{Void}, Ptr{Cuint}), env.handle, value)
        (ret != 0) && error(errormsg(ret))
    elseif option == :Readers
        ret = ccall( (:mdb_env_get_maxreaders, liblmdbjl), Cint, (Ptr{Void}, Ptr{Cuint}), env.handle, value)
        (ret != 0) && error(errormsg(ret))
    elseif option == :KeySize
        value[1] = ccall( (:mdb_env_get_maxkeysize, liblmdbjl), Cint, (Ptr{Void}, ), env.handle)
    end
    return value[1]
end