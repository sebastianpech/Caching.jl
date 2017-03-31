# Caching
[![Build Status](https://travis-ci.org/sebastianpech/Caching.jl.svg?branch=master)](https://travis-ci.org/sebastianpech/Caching.jl)

Caching provides a convenient way for storing previously made calculations.

Let `f(x)` be a function with a costly calculation procedure.

```jldoctest
julia> _f = @cache f::Float64 < storage

julia> _f(2.4)
  1.006197 seconds (12 allocations: 560 bytes)
0.675463180551151

julia> _f(2.4)
  0.000004 seconds (7 allocations: 208 bytes)
0.675463180551151

julia> storage
Dict{Tuple,Float64} with 1 entry:
  (2.4,) => 0.675463

```
