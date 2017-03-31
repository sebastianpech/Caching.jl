using Caching
using Base.Test

function foo1(x)
    sleep(1)
    1.0x
end

foo1_c = @cache foo1::Float64 < store

t1 = @timed foo1_c(11.0)
t2 = @timed foo1_c(11.0)
res = foo1(11.0)

@test t1[2] > 1.0
@test t2[2] < 0.01
@test t2[1] == t1[1]
@test t2[1] == res
@test store[(11.0,)] == 11.0

@cache function foo2(x)::Float64
    sleep(1)
    1.0x
end

t1 = @timed foo2(12.0)
t2 = @timed foo2(12.0)

@test t1[2] > 1.0
@test t2[2] < 0.01
