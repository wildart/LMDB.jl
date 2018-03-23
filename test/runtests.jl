using Compat
using Compat.Test
push!(LOAD_PATH, joinpath(dirname(@__FILE__), "../src"))

@testset "LMDB" for t in ["common", "env", "dbi", "cur"]
    fp = "$t.jl"
    println("* running $fp ...")
    include(fp)
end

