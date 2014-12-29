# LMDB
[![Build Status](https://travis-ci.org/wildart/LMDB.jl.svg?branch=master)](https://travis-ci.org/wildart/LMDB.jl)
[![Coverage Status](https://img.shields.io/coveralls/wildart/LMDB.jl.svg)](https://coveralls.io/r/wildart/LMDB.jl)

Lightning Memory-Mapped Database (LMDB) is Gis an ultra-fast, ultra-compact key-value embedded data store developed by Symas for the OpenLDAP Project. It uses memory-mapped files, so it has the read performance of a pure in-memory database while still offering the persistence of standard disk-based databases, and is only limited to the size of the virtual address space. This module provides a Julia interface to LMDB.

## Installation
Clone package from this repository and build it.

    julia> Pkg.clone("https://github.com/wildart/LMDB.jl.git")
    julia> Pkg.build("LMDB")

## API

### Open/Use/Close a LMDB environment

First, an LMDB environment need to be created.
```
env = create()
```
`create` function generates `Environment` object that contains DB environment handle.

At this point various parameters of environment can be set (befor openning it).
Environment parameters are set with  `put!` function that accepts parameters: `Environment` object, `option` symbol which indicates parameter and parameter `value`.
```
put!(env::Environment, option::Symbol, value)
```
`set` function `option` parameter values:
* Flags
* Readers
* MapSize
* DBs

Environment parameters can be viewed with `get` function:
```
get(env::Environment, option::Symbol)
```
`get` function `option` parameter values:
* Flags
* Readers
* KeySize

Next, the environment can be opened using `open` function. `path` is the directory in which the database files reside. The directory must already exist and be writable. `flags` defines special options for the environment. `mode` is the UNIX permissions to set on created files.
```
open(env::Environment, path::String; flags::Uint32, mode::Int32)
```

After you finish using the environment, it have to be closed to free resources:
```
close(env::Environment)
```

### Using LMDB transactions
A `start` function creates a new transaction and return `Transaction` object:
```
txn = start(env::Environment; flags::Uint32)
```

Commit all the operations of a transaction into the database. The transaction and its cursors must not be used after, because its handle is freed.
```
commit(txn::Transaction)
```

Abandon all the operations of the transaction instead of saving them. The transaction and its cursors must not be used after, because its handle is freed.
```
abort(txn::Transaction)
```

### LMDB database
TODO

## Example
```
env = create() # create new db environment
try
	open(env, "./testdb") # open db environment
    txn = start(env)      # start new transaction
    dbi = open(txn)       # open database
    try
        put!(txn, dbi, "key", "val") # add key-value pair
        commit(txn)                  # commit transaction
    finally
        close(env, dbi)  # close db
    end
finally
    close(env)           # close environment
end
```