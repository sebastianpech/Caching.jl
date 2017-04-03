module Caching
export @cache
"""
    @cache name[::type] [< store]

Generate a wrapper around the function name which stores the returned value
for every input combination. That way already calculated parameter combinations
do not need to be recomputed.
The type parameter after the function name is optional. In case it's provided 
the storage dictionary is initalized with this type instead of `Any`. Furthermore
if a storage name is defined by `< store` the dictionary is brought into current
scope and is accessbile, otherwise it's only in the scope of the new function.

Let `f(x)` be a function with a costly calculation procedure.

```
julia> _f = @cache f::Float64 < storage

julia> _f(2.4)
  1.006197 seconds (12 allocations: 560 bytes)
0.675463180551151

julia> _f(2.4)
  0.000004 seconds (7 allocations: 208 bytes)
0.675463180551151
```
"""
macro cache(ex)
    # Seperate the function name, the return type and the store name
    # Return type and storename default to :Any and nothing
    func = typeof(ex) == Symbol ? ex : ex.args[1] == :< ? ex.args[2] : ex
    dtype = :(Any)
    if typeof(func) == Expr && func.head == :(::)
        dtype = func.args[2]
        func = func.args[1]
    end

    # If cached is used directly on a function obtain the type from the
    # function definition
    if typeof(ex) != Symbol && ex.head == :function && typeof(ex.args[1]) == Expr && ex.args[1].head == :(::)
        dtype = ex.args[1].args[2]
    end

    store = typeof(ex) == Symbol ? nothing : ex.args[1] == :< ? ex.args[3] : nothing
    func, dtype, store

    # Generate function call to generate anonymous function which passes the 
    # input to the underlying function after checking for previously made
    # calculations.
    ex2 = Expr(:call,(Expr(:->,Expr(:tuple,:(store=Dict{UInt,$dtype}())),
                           Expr(:block, :((args...)-> get!(store,Caching.hashkeys(args)) do
                                          $func(args...)
                                          end
                                         )
                               )
                          )
                     )
              )

    # In case a dictionary for store was defined add it to the function.
    if store != nothing
        # Push variable
        push!(ex2.args,store)
        ex2 = Expr(:block,:($store = Dict{UInt,$dtype}()),ex2)
    end

    # Call was done directly during function definition -> override function
    # name
    if typeof(ex) != Symbol && ex.head == :function
        # find function name
        fn_name = ex
        while typeof(fn_name) == Expr
            fn_name = fn_name.args[1]
        end
        ex2 = quote
            $(fn_name) = ($ex2)
        end
    end

    esc(ex2)
end

function hashkeys(tup::Tuple)
    hash(map(tup) do xi
        hash(xi)
    end)
end

end
