using Test

@testset "LMDB" for t in ["common", "env", "dbi", "cur","dict"]
    fp = "$t.jl"
    include(fp)
end
