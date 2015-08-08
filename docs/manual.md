### Working with the database

First, an LMDB environment need to be created. `create` function creates `Environment` object that contains DB environment handle.
```julia
env = create()
```
Before opening the environment, you can be set its parameters.
Environment parameters are set with `put!` function that accepts:
* `Environment` object
* `option` symbol which indicates parameter, and
* parameter `value`.

```julia
env[:DBs] = 2
```

Environment parameters can be read with `get` function:
```julia
env[:Readers]
```

Next, the environment must be opened using `open` function that takes as parameter path to the directory where database files reside. Make sure that the database directory exists and is writable.
```julia
open(env, "./testdb")
```

After opennig environment, create a transaction with `start` function. It creates a new transaction and return `Transaction` object.
```julia
txn = start(env)
```

Next step, you need to open database using `open` function that takes the transanction as an argument.
```julia
dbi = open(txn)
```

Put key-value pair into the database with `put!` function:
```julia
put!(txn, dbi, "key", "val")
```

Commit all the operations of a transaction into the database. The transaction and its cursors must not be used after, because its handle is freed.
```julia
commit(txn)
```

If you finished working with the database, close it with `close` call
```julia
close(env, dbi)
```

After you finished working with the environment, it has to be closed to free resources:
```julia
close(env)
```


### Complete example
```julia
env = create() # create new db environment
try
    open(env, "./testdb") # open db environment !!! `testdb` must exist !!!
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