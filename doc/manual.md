Lightning Memory-Mapped Database (LMDB) is an ultra-fast, ultra-compact key-value
embedded data store developed by Symas for the OpenLDAP Project.
It uses memory-mapped files, so it has the read performance of a pure in-memory
database while still offering the persistence of standard disk-based databases,
and is only limited to the size of the virtual address space.
This module provides a Julia interface to LMDB.

## Installation
You can install the package using package manager:

    julia> Pkg.add("LMDB")

or clone latest version of the package from a repository and build it.

    julia> Pkg.clone("https://github.com/wildart/LMDB.jl.git")
    julia> Pkg.build("LMDB")

## Example
```julia
env = create() # create new db environment
try
    open(env, "./testdb") # open db environment
    txn = start(env)      # start new transaction
    dbi = open(txn)       # open database
    try
        insert!(txn, dbi, "key", "val") # add key-value pair
        commit(txn)                  # commit transaction
    finally
        close(env, dbi)  # close db
    end
finally
    close(env)           # close environment
end
```