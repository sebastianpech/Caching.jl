# Caching
[![Build Status](https://travis-ci.org/sebastianpech/Caching.jl.svg?branch=master)](https://travis-ci.org/sebastianpech/Caching.jl)

Caching provides a convenient way for storing previously made calculations.

## Example

The following code shows an example usage for defining cached functions during
creation.

```julia
using Caching

# The type specifier ::Float64 for the function is optional. If it's not specified
# the storage is initialized as Any.
@cache function foo(x::Vector{Float64},y::Vector{Float64})::Float64
    det(x*y') # actually not a very useful operation
end

a=rand(5000)
b=rand(5000)

foo(a,b*rand()) # precompile

# First run, nothing stored
@time foo(a,b) # 1.735071 seconds (151 allocations: 381.554 MB, 6.27% gc time)
# Second run, stored
@time foo(a,b) # 0.000083 seconds (7 allocations: 224 bytes)
```

It's possible do enable caching on previously defined functions.

```julia
using Caching

function foo(x::Vector{Float64},y::Vector{Float64})
    det(x*y')
end

# The type specifier ::Float64 is again optional, < mystorage is also
# optional, it can be used to create the dictionary for storage outside the
# scope of the generated function, that way it's possible to access the
# calculated results. The dictionary is created automatically.
foo_c = @cache foo::Float64 < mystorage

a=rand(5000); b=rand(5000);
foo_c(a,b*rand());

# First run, nothing stored
@time foo_c(a,b) # 1.724800 seconds (151 allocations: 381.554 MB, 7.19% gc time)
# Second run, stored
@time foo_c(a,b) # 0.000082 seconds (7 allocations: 224 bytes)
# Calling the original function shows that the overhead of storing the
# calculations is minimal.
@time foo(a,b) # 1.745463 seconds (23 allocations: 381.547 MB, 7.32% gc time)
```
