# LMDB

## Exported

---

<a id="method__abort.1" class="lexicon_definition"></a>
#### abort(txn::LMDB.Transaction) [¶](#method__abort.1)
Abandon all the operations of the transaction instead of saving them

The transaction and its cursors must not be used after, because its handle is freed.


*source:*
[LMDB/src/txn.jl:40](file:///home/art/.julia/v0.4/LMDB/src/txn.jl)

---

<a id="method__close.1" class="lexicon_definition"></a>
#### close(cur::LMDB.Cursor) [¶](#method__close.1)
Close a cursor

*source:*
[LMDB/src/cur.jl:33](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="method__close.2" class="lexicon_definition"></a>
#### close(env::LMDB.Environment) [¶](#method__close.2)
Close the environment and release the memory map

*source:*
[LMDB/src/env.jl:56](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="method__close.3" class="lexicon_definition"></a>
#### close(env::LMDB.Environment,  dbi::LMDB.DBI) [¶](#method__close.3)
Close a database handle

*source:*
[LMDB/src/dbi.jl:36](file:///home/art/.julia/v0.4/LMDB/src/dbi.jl)

---

<a id="method__commit.1" class="lexicon_definition"></a>
#### commit(txn::LMDB.Transaction) [¶](#method__commit.1)
Commit all the operations of a transaction into the database

The transaction and its cursors must not be used after, because its handle is freed.


*source:*
[LMDB/src/txn.jl:50](file:///home/art/.julia/v0.4/LMDB/src/txn.jl)

---

<a id="method__count.1" class="lexicon_definition"></a>
#### count(cur::LMDB.Cursor) [¶](#method__count.1)
Return count of duplicates for current key

*source:*
[LMDB/src/cur.jl:115](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="method__create.1" class="lexicon_definition"></a>
#### create() [¶](#method__create.1)
Create an LMDB environment handle

*source:*
[LMDB/src/env.jl:18](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="method__create.2" class="lexicon_definition"></a>
#### create(f::Function) [¶](#method__create.2)
Wrapper of `create` for `do` construct

*source:*
[LMDB/src/env.jl:26](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="method__delete.1" class="lexicon_definition"></a>
#### delete!(cur::LMDB.Cursor) [¶](#method__delete.1)
Delete current key/data pair to which the cursor refers

*source:*
[LMDB/src/cur.jl:107](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="method__delete.2" class="lexicon_definition"></a>
#### delete!(txn::LMDB.Transaction,  dbi::LMDB.DBI,  key,  val) [¶](#method__delete.2)
Delete items from a database

*source:*
[LMDB/src/dbi.jl:83](file:///home/art/.julia/v0.4/LMDB/src/dbi.jl)

---

<a id="method__drop.1" class="lexicon_definition"></a>
#### drop(txn::LMDB.Transaction,  dbi::LMDB.DBI) [¶](#method__drop.1)
Empty or delete+close a database.

If parameter `delete` is `false` DB will be emptied, otherwise
DB will be deleted from the environment and DB handle will be closed


*source:*
[LMDB/src/dbi.jl:60](file:///home/art/.julia/v0.4/LMDB/src/dbi.jl)

---

<a id="method__getindex.1" class="lexicon_definition"></a>
#### getindex(env::LMDB.Environment,  option::Symbol) [¶](#method__getindex.1)
Get environment flags and parameters

`getindex` accepts folowing parameters:
* `env` db environment object
* `option` symbol which indicates parameter. Currently supported parameters:
    * Flags
    * Readers
    * KeySize

**Note:** Consult LMDB documentation for particual values of environment parameters and flags.


*source:*
[LMDB/src/env.jl:131](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="method__get.1" class="lexicon_definition"></a>
#### get{T}(cur::LMDB.Cursor,  key,  ::Type{T}) [¶](#method__get.1)
Retrieve by cursor.

This function retrieves key/data pairs from the database.


*source:*
[LMDB/src/cur.jl:68](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="method__get.2" class="lexicon_definition"></a>
#### get{T}(cur::LMDB.Cursor,  key,  ::Type{T},  op::LMDB.CursorOps) [¶](#method__get.2)
Retrieve by cursor.

This function retrieves key/data pairs from the database.


*source:*
[LMDB/src/cur.jl:68](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="method__get.3" class="lexicon_definition"></a>
#### get{T}(txn::LMDB.Transaction,  dbi::LMDB.DBI,  key,  ::Type{T}) [¶](#method__get.3)
Get items from a database

*source:*
[LMDB/src/dbi.jl:96](file:///home/art/.julia/v0.4/LMDB/src/dbi.jl)

---

<a id="method__info.1" class="lexicon_definition"></a>
#### info(env::LMDB.Environment) [¶](#method__info.1)
Return information about the LMDB environment.

*source:*
[LMDB/src/env.jl:160](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="method__isflagset.1" class="lexicon_definition"></a>
#### isflagset(value,  flag) [¶](#method__isflagset.1)
 Check if binary flag is set in provided value

*source:*
[LMDB/src/common.jl:114](file:///home/art/.julia/v0.4/LMDB/src/common.jl)

---

<a id="method__isopen.1" class="lexicon_definition"></a>
#### isopen(cur::LMDB.Cursor) [¶](#method__isopen.1)
Check if cursor is open

*source:*
[LMDB/src/cur.jl:10](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="method__isopen.2" class="lexicon_definition"></a>
#### isopen(dbi::LMDB.DBI) [¶](#method__isopen.2)
Check if database is open

*source:*
[LMDB/src/dbi.jl:11](file:///home/art/.julia/v0.4/LMDB/src/dbi.jl)

---

<a id="method__isopen.3" class="lexicon_definition"></a>
#### isopen(env::LMDB.Environment) [¶](#method__isopen.3)
Check if environment is open

*source:*
[LMDB/src/env.jl:15](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="method__isopen.4" class="lexicon_definition"></a>
#### isopen(txn::LMDB.Transaction) [¶](#method__isopen.4)
Check if transaction is open.

*source:*
[LMDB/src/txn.jl:18](file:///home/art/.julia/v0.4/LMDB/src/txn.jl)

---

<a id="method__open.1" class="lexicon_definition"></a>
#### open(env::LMDB.Environment,  path::AbstractString) [¶](#method__open.1)
Open an environment handle

`open` function accepts folowing parameters:
* `env` db environment object
* `path` directory in which the database files reside
* `flags` defines special options for the environment
* `mode` UNIX permissions to set on created files

*Note:* A database directory must exist and be writable.


*source:*
[LMDB/src/env.jl:45](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="method__open.2" class="lexicon_definition"></a>
#### open(f::Function,  txn::LMDB.Transaction) [¶](#method__open.2)
Wrapper of DBI `open` for `do` construct

*source:*
[LMDB/src/dbi.jl:25](file:///home/art/.julia/v0.4/LMDB/src/dbi.jl)

---

<a id="method__open.3" class="lexicon_definition"></a>
#### open(f::Function,  txn::LMDB.Transaction,  dbi::LMDB.DBI) [¶](#method__open.3)
Wrapper of Cursor `open` for `do` construct

*source:*
[LMDB/src/cur.jl:23](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="method__open.4" class="lexicon_definition"></a>
#### open(f::Function,  txn::LMDB.Transaction,  dbname::AbstractString) [¶](#method__open.4)
Wrapper of DBI `open` for `do` construct

*source:*
[LMDB/src/dbi.jl:25](file:///home/art/.julia/v0.4/LMDB/src/dbi.jl)

---

<a id="method__open.5" class="lexicon_definition"></a>
#### open(txn::LMDB.Transaction) [¶](#method__open.5)
Open a database in the environment

*source:*
[LMDB/src/dbi.jl:14](file:///home/art/.julia/v0.4/LMDB/src/dbi.jl)

---

<a id="method__open.6" class="lexicon_definition"></a>
#### open(txn::LMDB.Transaction,  dbi::LMDB.DBI) [¶](#method__open.6)
Create a cursor

*source:*
[LMDB/src/cur.jl:13](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="method__open.7" class="lexicon_definition"></a>
#### open(txn::LMDB.Transaction,  dbname::AbstractString) [¶](#method__open.7)
Open a database in the environment

*source:*
[LMDB/src/dbi.jl:14](file:///home/art/.julia/v0.4/LMDB/src/dbi.jl)

---

<a id="method__path.1" class="lexicon_definition"></a>
#### path(env::LMDB.Environment) [¶](#method__path.1)
Return the path that was used in `open`

*source:*
[LMDB/src/env.jl:12](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="method__put.1" class="lexicon_definition"></a>
#### put!(cur::LMDB.Cursor,  key,  val) [¶](#method__put.1)
Store by cursor.

This function stores key/data pairs into the database. The cursor is positioned at the new item, or on failure usually near it.


*source:*
[LMDB/src/cur.jl:94](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="method__put.2" class="lexicon_definition"></a>
#### put!(txn::LMDB.Transaction,  dbi::LMDB.DBI,  key,  val) [¶](#method__put.2)
Store items into a database

*source:*
[LMDB/src/dbi.jl:70](file:///home/art/.julia/v0.4/LMDB/src/dbi.jl)

---

<a id="method__renew.1" class="lexicon_definition"></a>
#### renew(txn::LMDB.Transaction) [¶](#method__renew.1)
Renew a read-only transaction

This acquires a new reader lock for a transaction handle that had been released by `reset`.
It must be called before a reset transaction may be used again.


*source:*
[LMDB/src/txn.jl:72](file:///home/art/.julia/v0.4/LMDB/src/txn.jl)

---

<a id="method__renew.2" class="lexicon_definition"></a>
#### renew(txn::LMDB.Transaction,  cur::LMDB.Cursor) [¶](#method__renew.2)
Renew a cursor

*source:*
[LMDB/src/cur.jl:43](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="method__reset.1" class="lexicon_definition"></a>
#### reset(txn::LMDB.Transaction) [¶](#method__reset.1)
Reset a read-only transaction

Abort the transaction like `abort`, but keep the transaction handle.


*source:*
[LMDB/src/txn.jl:61](file:///home/art/.julia/v0.4/LMDB/src/txn.jl)

---

<a id="method__set.1" class="lexicon_definition"></a>
#### set!(env::LMDB.Environment,  flag::UInt32) [¶](#method__set.1)
Set environment flags

*source:*
[LMDB/src/env.jl:75](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="method__setindex.1" class="lexicon_definition"></a>
#### setindex!(env::LMDB.Environment,  val::UInt32,  option::Symbol) [¶](#method__setindex.1)
Set environment flags and parameters

`setindex!` accepts folowing parameters:
* `env` db environment object
* `option` symbol which indicates parameter. Currently supported parameters:
    * Flags
    * Readers
    * MapSize
    * DBs
* `value` parameter value

**Note:** Consult LMDB documentation for particual values of environment parameters and flags.


*source:*
[LMDB/src/env.jl:104](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="method__start.1" class="lexicon_definition"></a>
#### start(env::LMDB.Environment) [¶](#method__start.1)
Create a transaction for use with the environment

`start` function creates a new transaction and returns `Transaction` object.
It allows to set transaction flags with `flags` option.


*source:*
[LMDB/src/txn.jl:25](file:///home/art/.julia/v0.4/LMDB/src/txn.jl)

---

<a id="method__sync.1" class="lexicon_definition"></a>
#### sync(env::LMDB.Environment) [¶](#method__sync.1)
Flush the data buffers to disk

*source:*
[LMDB/src/env.jl:67](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="method__sync.2" class="lexicon_definition"></a>
#### sync(env::LMDB.Environment,  force::Bool) [¶](#method__sync.2)
Flush the data buffers to disk

*source:*
[LMDB/src/env.jl:67](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="method__unset.1" class="lexicon_definition"></a>
#### unset!(env::LMDB.Environment,  flag::UInt32) [¶](#method__unset.1)
Unset environment flags

*source:*
[LMDB/src/env.jl:83](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="type__cursor.1" class="lexicon_definition"></a>
#### LMDB.Cursor [¶](#type__cursor.1)
A handle to a cursor structure for navigating through a database.


*source:*
[LMDB/src/cur.jl:4](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="type__dbi.1" class="lexicon_definition"></a>
#### LMDB.DBI [¶](#type__dbi.1)
A handle for an individual database in the DB environment.


*source:*
[LMDB/src/dbi.jl:4](file:///home/art/.julia/v0.4/LMDB/src/dbi.jl)

---

<a id="type__environment.1" class="lexicon_definition"></a>
#### LMDB.Environment [¶](#type__environment.1)
A DB environment supports multiple databases, all residing in the same shared-memory map.


*source:*
[LMDB/src/env.jl:4](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="type__lmdberror.1" class="lexicon_definition"></a>
#### LMDB.LMDBError [¶](#type__lmdberror.1)
LMDB exception type

*source:*
[LMDB/src/common.jl:106](file:///home/art/.julia/v0.4/LMDB/src/common.jl)

---

<a id="type__transaction.1" class="lexicon_definition"></a>
#### LMDB.Transaction [¶](#type__transaction.1)
A database transaction. Every operation requires a transaction handle.
All database operations require a transaction handle. Transactions may be read-only or read-write.


*source:*
[LMDB/src/txn.jl:5](file:///home/art/.julia/v0.4/LMDB/src/txn.jl)

## Internal

---

<a id="method__dbi.1" class="lexicon_definition"></a>
#### dbi(cur::LMDB.Cursor) [¶](#method__dbi.1)
Return the cursor's database

*source:*
[LMDB/src/cur.jl:58](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="method__errormsg.1" class="lexicon_definition"></a>
#### errormsg(err::Int32) [¶](#method__errormsg.1)
Return a string describing a given error code

Function returns description of the error as a string. It accepts following arguments:
* `err::Int32`: An error code.


*source:*
[LMDB/src/common.jl:100](file:///home/art/.julia/v0.4/LMDB/src/common.jl)

---

<a id="method__flags.1" class="lexicon_definition"></a>
#### flags(txn::LMDB.Transaction,  dbi::LMDB.DBI) [¶](#method__flags.1)
Retrieve the DB flags for a database handle

*source:*
[LMDB/src/dbi.jl:46](file:///home/art/.julia/v0.4/LMDB/src/dbi.jl)

---

<a id="method__txn.1" class="lexicon_definition"></a>
#### txn(cur::LMDB.Cursor) [¶](#method__txn.1)
Return the cursor's transaction

*source:*
[LMDB/src/cur.jl:51](file:///home/art/.julia/v0.4/LMDB/src/cur.jl)

---

<a id="method__version.1" class="lexicon_definition"></a>
#### version() [¶](#method__version.1)
Return the LMDB library version and version information

Function returns tuple `(VersionNumber,String)` that contains a library version and a library version string.


*source:*
[LMDB/src/common.jl:87](file:///home/art/.julia/v0.4/LMDB/src/common.jl)

---

<a id="type__environmentinfo.1" class="lexicon_definition"></a>
#### LMDB.EnvironmentInfo [¶](#type__environmentinfo.1)
Information about the environment

*source:*
[LMDB/src/env.jl:149](file:///home/art/.julia/v0.4/LMDB/src/env.jl)

---

<a id="type__mdbvalue.1" class="lexicon_definition"></a>
#### LMDB.MDBValue [¶](#type__mdbvalue.1)
Generic structure used for passing keys and data in and out of the database.

*source:*
[LMDB/src/common.jl:4](file:///home/art/.julia/v0.4/LMDB/src/common.jl)

