### Working with the database

First, an LMDB environment needs to be created. The `create` function creates an `Environment` object that contains a DB environment handle.
```julia
env = create()
```
Before opening the environment, you can set its parameters.
Environment parameters are set with the `put!` function, which accepts:
* `Environment` object
* `option` symbol which indicates parameter name, and
* parameter `value`.

```julia
env[:DBs] = 2
```

Environment parameters can be read with the `get` function:
```julia
env[:Readers]
```

Next, an environment must be opened using `open` function that takes as a parameter the path to the directory where database files reside. Make sure that the database directory exists and is writable.
```julia
open(env, "./testdb")
```

After opening the environment, create a transaction with the `start` function. It creates a new transaction and returns a `Transaction` object.
```julia
txn = start(env)
```

Next step, you need to open database using the `open` function, which takes the transaction as an argument.
```julia
dbi = open(txn)
```

Put key-value pair into the database with the `put!` function:
```julia
put!(txn, dbi, "key", "val")
```

Commit all the operations of a transaction into the database. The transaction and its cursors must not be used afterwards, because its handle has been freed.
```julia
commit(txn)
```

When you have finished working with the database, close it with a `close` call:
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
