# restart processes
if nprocs() > 1
    rmprocs(workers()) # remove all worker processes
end
wpids = addprocs(2) # add processes

println("Spawned ", nprocs(), " processes, ", nworkers()," workers")
println("Proc IDs: ", procs())

# load LMDB on all processes
@everywhere using LMDB

# create a sample database
nsamples = 100
dbname = "simpleseq.db"
isdir(dbname) && rm(dbname, recursive=true)
!isdir(dbname) && mkdir(dbname)

# the data are just {1:1, 2:2 ... }
environment(dbname) do env
    start(env) do txn
        open(txn) do dbi
            for i=1:nsamples
                put!(txn, dbi, string(i), string(i))
            end
        end
        commit(txn)
    end
end

# helper functions
@everywhere function getSamplesFromDb(env, idxs::Array{Int})
    txn = start(env)
    dbi = open(txn)
    xs = Int[]
    println(idxs)
    for idx in idxs
        key = string(idx)
        val = get(txn, dbi, key, String);
        println("k:$key, v:$val")
        val = parse(Int, val)
        push!(xs, val)
    end
    abort(txn)
    close(env, dbi)
    return xs
end

@everywhere function miniBatchSum(idxs, dbname::String)
    # open the database
    println("Opening ", dbname)
    xs = environment(dbname) do env
        getSamplesFromDb(env, idxs)
    end

    # the cost is the sum of all the values we get from the db
    cost = 0.0
    for x in xs
        cost += x;
    end

    return cost
end

# the following single process call works
println("miniBatchSum([1,2,3], dbname)")
println(miniBatchSum([1,2,3], dbname))

# the following (which does it in parallel) does not work
# we generate some ids to split across the nodes
# each node will process sample_size values
# the ids are put into proc_idxs
sample_size = 10;
idxs = randperm(nsamples);
idxs = idxs[1:(nworkers()*sample_size)]
proc_idxs = Any[]
st_idx = 1;
en_idx = sample_size;
for i=1:nworkers()
    push!(proc_idxs, idxs[st_idx:en_idx]);
    st_idx = en_idx+1;
    en_idx = en_idx+sample_size;
end
println(proc_idxs)

# spawn and run across all worker nodes
k = 1;
remrefs = Array{Future}(nworkers());
for proc in workers()
    println("Remote call to: ", proc);
    remrefs[k] = remotecall(miniBatchSum, proc, proc_idxs[k], dbname);
    k += 1;
end

# collect the results
k = 1;
results = Array{Float64}(nworkers());
for k = 1:length(remrefs)
    wait(remrefs[k]);
    results[k] = fetch(remrefs[k]);
    k += 1;
end
println(results)
