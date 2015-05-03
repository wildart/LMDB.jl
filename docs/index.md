# LMDB.jl

[*LMDB.jl*](https://github.com/wildart/LMDB.jl) is a [Julia](http://www.julialang.org) package for interfacing with LMDB database.

[Lightning Memory-Mapped Database (LMDB)](http://symas.com/mdb/) is an ultra-fast,
ultra-compact key-value embedded data store developed by Symas for the OpenLDAP Project.
It uses memory-mapped files, so it has the read performance of a pure in-memory
database while still offering the persistence of standard disk-based databases,
and is only limited to the size of the virtual address space.
This module provides a Julia interface to LMDB.
