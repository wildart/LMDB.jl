using Clang.Generators
using LMDB_jll

cd(@__DIR__)

include_dir = joinpath(LMDB_jll.artifact_dir, "include") |> normpath
lmdb_dir = include_dir

options = load_options(joinpath(@__DIR__, "generator.toml"))

# add compiler flags, e.g. "-DXXXXXXXXX"
args = get_default_args()
push!(args, "-I$include_dir")

headers = [joinpath(lmdb_dir, header) for header in readdir(lmdb_dir) if endswith(header, ".h")]
# there is also an experimental `detect_headers` function for auto-detecting top-level headers in the directory
# headers = detect_headers(clang_dir, args)

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx, BUILDSTAGE_NO_PRINTING)

function rewrite!(e)
    if length(e)==1
        ex = first(e)
        if ex.head == :function && startswith(string(ex.args[1].args[1]),"mdb_")
            fname = ex.args[1].args[1]
            f2name = Symbol(string("_", fname))
            ex2 = Expr(:(=),deepcopy(ex.args[1]), Expr(:call, :checked_call, f2name,ex.args[1].args[2:end]...))
            ex.args[1].args[1] = f2name
            push!(e,ex2)
        end
    end
end

function rewrite!(dag::ExprDAG)
    for node in get_nodes(dag)
        exlist = get_exprs(node)
        rewrite!(exlist)
    end
end

rewrite!(ctx.dag)

# print
build!(ctx, BUILDSTAGE_PRINTING_ONLY)
