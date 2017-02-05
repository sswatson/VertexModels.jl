# VertexModels

`VertexModels` is a Julia packages for generating and displaying random samples from the 20-vertex model. The samples are chosen using Propp and Wilson's [coupling from the past](https://en.wikipedia.org/wiki/Coupling_from_the_past) algorithm.

```julia
julia> using VertexModels
julia> m = 8
julia> n = 2m-1
julia> G = twentyvertex(m,n)
julia> picture(G)
```
![Twenty Vertex Sample](https://github.com/sswatson/VertexModels.jl/blob/master/images/twentyvertex.png)

```julia
julia> height(G)
8×15 Array{Int64,2}:
  0  -1   0  -1   0  -1   0  -1   0  -1   0  -1   0  -1   0
 -1   0  -1   0  -1   0  -1  -2  -1   0   1   0   1   0  -1
  0  -1   0  -1  -2  -1   0  -1  -2  -1  -2  -1  -2  -1   0
 -1   0  -1   0  -1   0   1   0  -1  -2  -1  -2  -1   0  -1
  0  -1   0   1   0  -1   0  -1  -2  -3  -2  -1   0  -1   0
 -1   0   1   0  -1   0  -1   0  -1   0  -1   0   1   0  -1
  0  -1  -2  -1   0  -1   0   1   0  -1  -2  -1   0  -1   0
 -1   0  -1   0  -1   0  -1   0  -1   0  -1   0  -1   0  -1
```

[![Build Status](https://travis-ci.org/sswatson/VertexModels.jl.svg?branch=master)](https://travis-ci.org/sswatson/VertexModels.jl)

[![Coverage Status](https://coveralls.io/repos/sswatson/VertexModels.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/sswatson/VertexModels.jl?branch=master)

[![codecov.io](http://codecov.io/github/sswatson/VertexModels.jl/coverage.svg?branch=master)](http://codecov.io/github/sswatson/VertexModels.jl?branch=master)
