@doc """
## Description
A DB environment supports multiple databases, all residing in the same shared-memory map.
""" ->
type Environment
    handle::Ptr{Void}
    path::String
    Environment() = new(C_NULL, "")
    Environment(h::Ptr{Void}) = new(h, "")
end

@doc "Return the path that was used in `open`." ->
path(env::Environment) = env.path

@doc "Check if environment is open." ->
isopen(env::Environment) = env.handle != C_NULL && length(path(env))>0

@doc "Create an LMDB environment handle." ->
function create()
    handle = ccall( (:mdb_env_create_default, liblmdbjl), Ptr{Void}, ())
    return Environment(handle)
end

@doc "Wrapper of `create` for `do` construct." ->
function create(f::Function)
    env = create()
    try
        f(env)
    finally
        close(env)
    end
end

@doc "Open an environment handle." ->
function open(env::Environment, path::String; flags::Uint32 = EMPTY, mode::Int32 = int32(436))
    env.path = path
    cpath = bytestring(path)
    ret = ccall( (:mdb_env_open, liblmdbjl), Cint, (Ptr{Void}, Ptr{Cchar}, Cuint, Cint), env.handle, cpath, flags, mode)
    if ret != 0
        warn(errormsg(ret))
    end
    return ret::Cint
end

@doc "Close the environment and release the memory map." ->
function close(env::Environment)
    if env.handle == C_NULL
        error("Environment is already closed")
    end
    ccall( (:mdb_env_close, liblmdbjl), Void, (Ptr{Void},), env.handle)
    env.handle = C_NULL
    env.path = ""
end

@doc "Flush the data buffers to disk." ->
function sync(env::Environment, force::Bool = false)
    fval = force ? 1 : 0
    ret = ccall( (:mdb_env_sync, liblmdbjl), Cint, (Ptr{Void}, Cint), env.handle, fval)
    if ret != 0
        warn(errormsg(ret))
    end
    return ret::Cint
end

@doc "Unset environment flags." ->
function unset(env::Environment, flag::Cuint)
    ret = ccall( (:mdb_env_set_flags, liblmdbjl), Cint, (Ptr{Void}, Cuint, Cint), env.handle, flag, 0)
    if ret != 0
        warn(errormsg(ret))
    end
    return ret::Cint
end

@doc "Set environment flags and parameters." ->
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
    if ret != 0
        warn(errormsg(ret))
    end
    return ret
end
put!(env::Environment, option::Symbol, val::Int) = put!(env, option, uint32(val))

@doc "Get environment flags and parameters." ->
function get(env::Environment, option::Symbol)
    value = Cuint[0]
    if option == :Flags
        flags = Cuint[0]
        ret = ccall( (:mdb_env_get_flags, liblmdbjl), Cint, (Ptr{Void}, Ptr{Cuint}), env.handle, value)
        if ret != 0
            warn(errormsg(ret))
        end
    elseif option == :Readers
        ret = ccall( (:mdb_env_get_maxreaders, liblmdbjl), Cint, (Ptr{Void}, Ptr{Cuint}), env.handle, value)
        if ret != 0
            warn(errormsg(ret))
        end
    elseif option == :KeySize
        value[1] = ccall( (:mdb_env_get_maxkeysize, liblmdbjl), Cint, (Ptr{Void}, ), env.handle)
    end
    return value[1]
end