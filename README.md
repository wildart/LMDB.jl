# LMDB
[![Build Status](https://travis-ci.org/wildart/LMDB.jl.svg?branch=master)](https://travis-ci.org/wildart/LMDB.jl)
[![Coverage Status](https://img.shields.io/coveralls/wildart/LMDB.jl.svg)](https://coveralls.io/r/wildart/LMDB.jl)

Lightning Memory-Mapped Database (LMDB) is an ultra-fast, ultra-compact key-value embedded data store developed by Symas for the OpenLDAP Project. It uses memory-mapped files, so it has the read performance of a pure in-memory database while still offering the persistence of standard disk-based databases, and is only limited to the size of the virtual address space. This module provides a Julia interface to LMDB (v0.9.15).

## Installation
You can install the package using package manager:

    julia> Pkg.add("LMDB")

or clone package from this repository and build it.

    julia> Pkg.clone("https://github.com/wildart/LMDB.jl.git")
    julia> Pkg.build("LMDB")

## Documentation

For more information, see the **[Documentation](http://wildart.github.io/LMDB.jl/)**.

