module LMDB

    @isdefined(Docile) && eval(:(@document))

    import Base: open, close, getindex, setindex!, put!, reset,
                 isopen, count, delete!, keys, get, show, convert, show
    import Base.Iterators: drop

    export Environment, create, open, close, sync, set!, unset!, getindex, setindex!, path, info, show,
           Transaction, start, abort, commit, reset, renew, environment,
           DBI, drop, delete!, keys, get, put!,
           Cursor, count, transaction, database,
           isflagset, isopen,
           LMDBError, CursorOps

    """LMDB exception type"""
    struct LMDBError <: Exception
        code::Cint
        msg::AbstractString
        LMDBError(code::Cint) = new(code, errormsg(code))
    end
    show(io::IO, err::LMDBError) = print(io, "Code[$(err.code)]: $(err.msg)")
    function checked_call(f,args...)
        ret = f(args...)
        ret === zero(Cint) || throw(LMDBError(ret))
        ret
    end

    include("LibLMDB.jl")
    using .LibLMDB
    include("common.jl")
    include("env.jl")
    include("txn.jl")
    include("dbi.jl")
    #include("cur.jl")
end
