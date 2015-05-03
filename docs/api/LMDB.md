# LMDB

## Exported
---

### abort(txn::Transaction)
Abandon all the operations of the transaction instead of saving them

*Note:* The transaction and its cursors must not be used after, because its handle is freed.


*source:*
[LMDB/src/txn.jl:38](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/txn.jl#L38)

---

### close(cur::Cursor)
Close a cursor

*source:*
[LMDB/src/cur.jl:23](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/cur.jl#L23)

---

### close(env::Environment)
Close the environment and release the memory map

*source:*
[LMDB/src/env.jl:52](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/env.jl#L52)

---

### close(env::Environment, dbi::DBI)
Close a database handle

*source:*
[LMDB/src/dbi.jl:37](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/dbi.jl#L37)

---

### commit(txn::Transaction)
Commit all the operations of a transaction into the database

*Note:* The transaction and its cursors must not be used after, because its handle is freed.


*source:*
[LMDB/src/txn.jl:49](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/txn.jl#L49)

---

### count(cur::Cursor)
Return count of duplicates for current key

*source:*
[LMDB/src/cur.jl:46](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/cur.jl#L46)

---

### create()
Create an LMDB environment handle

*source:*
[LMDB/src/env.jl:18](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/env.jl#L18)

---

### create(f::Function)
Wrapper of `create` for `do` construct

*source:*
[LMDB/src/env.jl:24](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/env.jl#L24)

---

### delete!(cur::Cursor)
Delete current key/data pair

*source:*
[LMDB/src/cur.jl:39](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/cur.jl#L39)

---

### drop(txn::Transaction, dbi::DBI)
Empty or delete+close a database

*source:*
[LMDB/src/dbi.jl:54](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/dbi.jl#L54)

---

### environment(txn::Transaction)
Returns the transaction's environment

*source:*
[LMDB/src/txn.jl:12](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/txn.jl#L12)

---

### get(env::Environment, option::Symbol)
Get environment flags and parameters

`get` accepts folowing parameters:
* `env` db environment object
* `option` symbol which indicates parameter. Currently supported parameters:
    * Flags
    * Readers
    * KeySize

**Note:** Consult LMDB documentation for particual values of environment parameters and flags.


*source:*
[LMDB/src/env.jl:118](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/env.jl#L118)

---

### get(txn::Transaction, dbi::DBI)
Retrieve the DB flags for a database handle

*source:*
[LMDB/src/dbi.jl:46](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/dbi.jl#L46)

---

### get{T}(txn::Transaction, dbi::Cursor, key, ::Type{T})
Get items from a database

*source:*
[LMDB/src/cur.jl:79](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/cur.jl#L79)

---

### get{T}(txn::Transaction, dbi::DBI, key, ::Type{T})
Get items from a database

*source:*
[LMDB/src/dbi.jl:86](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/dbi.jl#L86)

---

### isflagset(value, flag)
 Check if binary flag is set in provided value

*source:*
[LMDB/src/common.jl:63](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/common.jl#L63)

---

### isopen(cur::Cursor)
Check if cursor is open

*source:*
[LMDB/src/cur.jl:10](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/cur.jl#L10)

---

### isopen(dbi::DBI)
Check if database is open

*source:*
[LMDB/src/dbi.jl:11](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/dbi.jl#L11)

---

### isopen(env::Environment)
Check if environment is open

*source:*
[LMDB/src/env.jl:15](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/env.jl#L15)

---

### isopen(txn::Transaction)
Check if transaction is open.

*source:*
[LMDB/src/txn.jl:15](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/txn.jl#L15)

---

### open(env::Environment, path::String)
Open an environment handle

`open` function accepts folowing parameters:
* `env` db environment object
* `path` directory in which the database files reside
* `flags` defines special options for the environment
* `mode` UNIX permissions to set on created files

*Note:* A database directory must exist and be writable.


*source:*
[LMDB/src/env.jl:43](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/env.jl#L43)

---

### open(f::Function, txn::Transaction)
Wrapper of DBI `open` for `do` construct

*source:*
[LMDB/src/dbi.jl:27](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/dbi.jl#L27)

---

### open(txn::Transaction)
Open a database in the environment

*source:*
[LMDB/src/dbi.jl:14](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/dbi.jl#L14)

---

### open(txn::Transaction, dbi::DBI)
Create a cursor

*source:*
[LMDB/src/cur.jl:13](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/cur.jl#L13)

---

### path(env::Environment)
Return the path that was used in `open`

*source:*
[LMDB/src/env.jl:12](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/env.jl#L12)

---

### put!(env::Environment, option::Symbol, val::Uint32)
Set environment flags and parameters

`put!` accepts folowing parameters:
* `env` db environment object
* `option` symbol which indicates parameter. Currently supported parameters:
    * Flags
    * Readers
    * MapSize
    * DBs
* `value` parameter value

**Note:** Consult LMDB documentation for particual values of environment parameters and flags.


*source:*
[LMDB/src/env.jl:89](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/env.jl#L89)

---

### renew(txn::Transaction)
Renew a read-only transaction

*source:*
[LMDB/src/txn.jl:64](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/txn.jl#L64)

---

### renew(txn::Transaction, cur::Cursor)
Renew a cursor

*source:*
[LMDB/src/cur.jl:32](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/cur.jl#L32)

---

### reset(txn::Transaction)
Reset a read-only transaction

*source:*
[LMDB/src/txn.jl:57](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/txn.jl#L57)

---

### start(env::Environment)
Create a transaction for use with the environment

`start` function creates a new transaction and returns `Transaction` object.
It allows to set transaction flags with `flags` option.


*source:*
[LMDB/src/txn.jl:22](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/txn.jl#L22)

---

### start(f::Function, env::Environment)
Wrapper of `start` for `do` construct

*source:*
[LMDB/src/txn.jl:32](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/txn.jl#L32)

---

### sync(env::Environment)
Flush the data buffers to disk

*source:*
[LMDB/src/env.jl:62](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/env.jl#L62)

---

### sync(env::Environment, force::Bool)
Flush the data buffers to disk

*source:*
[LMDB/src/env.jl:62](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/env.jl#L62)

---

### unset(env::Environment, flag::Uint32)
Unset environment flags

*source:*
[LMDB/src/env.jl:70](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/env.jl#L70)

---

### Cursor
A handle to a cursor structure for navigating through a database.


*source:*
[LMDB/src/cur.jl:4](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/cur.jl#L4)

---

### DBI
A handle for an individual database in the DB environment.


*source:*
[LMDB/src/dbi.jl:4](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/dbi.jl#L4)

---

### Environment
A DB environment supports multiple databases, all residing in the same shared-memory map.


*source:*
[LMDB/src/env.jl:4](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/env.jl#L4)

---

### Transaction
A database transaction. Every operation requires a transaction handle.
All database operations require a transaction handle. Transactions may be read-only or read-write.


*source:*
[LMDB/src/txn.jl:5](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/txn.jl#L5)

## Internal
---

### errormsg(err::Int32)
Return a string describing a given error code

Function returns description of the error as a string. It accepts following arguments:
* `err::Int32`: An error code.


*source:*
[LMDB/src/common.jl:57](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/common.jl#L57)

---

### insert!(cur::Cursor, key, val)
Store items into a database

*source:*
[LMDB/src/cur.jl:54](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/cur.jl#L54)

---

### insert!(txn::Transaction, dbi::DBI, key, val)
Store items into a database

*source:*
[LMDB/src/dbi.jl:62](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/dbi.jl#L62)

---

### version()
Return the LMDB library version and version information

Function returns tuple `(VersionNumber,String)` that contains a library version and a library version string.


*source:*
[LMDB/src/common.jl:44](https://github.com/wildart/LMDB.jl/tree/af071afae6696a6fe794bc70c3a5d2b79fa71f9a/src/common.jl#L44)

