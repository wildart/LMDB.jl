using Test

@testset "LMDB" for t in ["common", "env", "dbi", "cur"]
    fp = "$t.jl"
    include(fp)
end
