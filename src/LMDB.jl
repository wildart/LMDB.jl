module LMDB

    @isdefined(Docile) && eval(:(@document))

    import Base: open, close, getindex, setindex!, put!, reset,
                 isopen, count, delete!, keys, get, show, convert, show
    import Base.Iterators: drop

    depsfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
    if isfile(depsfile)
        include(depsfile)
    else
        error("LMDB not properly installed. Please run Pkg.build(\"LMDB\")")
    end

    export Environment, create, open, close, sync, set!, unset!, getindex, setindex!, path, info, show,
           Transaction, start, abort, commit, reset, renew, environment,
           DBI, drop, delete!, keys, get, put!,
           Cursor, count, transaction, database,
           isflagset, isopen,
           LMDBError, CursorOps

    include("common.jl")
    include("env.jl")
    include("txn.jl")
    include("dbi.jl")
    include("cur.jl")
end
