__precompile__(true)

module VertexModels

import Graphics2D

export RandGenerator, 
       Orientation,
       maxorientation,
       twentyvertex, 
       picture, 
       height, 
       issink, 
       issource, 
       pushdown!, 
       pushup!

type RandGenerator
    D::Dict{Int64,Tuple{Int64,Int64,Bool}}
    m::Int64
    n::Int64
end

function twentyvertex(m,n,maxiter=2^20)
    U = RandGenerator(Dict(),m,n)
    T = 1
    upper0, lower0 = maxorientation(m,n), minorientation(m,n)
    upper,lower = upper0, lower0
    while upper != lower
        upper,lower = copy(upper0), copy(lower0)
        for t = -T:-1
            pushdown!(upper,sample(U,t)...)
            pushdown!(lower,sample(U,t)...)
        end
        T = 2T
        if T >= maxiter
            error("Did not converge")
        end
    end
    return upper
end

function sample(R::RandGenerator,t::Integer)
    if !(t in keys(R.D))
        u = (rand(2:R.m-1),rand(3:R.n-2),rand(Bool))
        R.D[t] = u
        return u
    else
        return R.D[t]
    end
end

type Orientation
    D::Dict{Tuple{Tuple{Int64,Int64},Tuple{Int64,Int64}},Int64}
    m::Int64
    n::Int64
end

import Base: size, keys, getindex, setindex!, copy, ==, !=, hash

hash(o::Orientation) = hash((o.D,o.m,o.n))
==(o::Orientation,p::Orientation) = o.D == p.D
!=(o::Orientation,p::Orientation) = !(o == p)
size(o::Orientation) = (o.m,o.n)
keys(o::Orientation) = keys(o.D)
getindex(o::Orientation,I::Tuple{Tuple{Int64,Int64},Tuple{Int64,Int64}}) = o.D[I]
setindex!(o::Orientation, i::Int64, k::Tuple{Tuple{Int64,Int64},Tuple{Int64,Int64}}) = setindex!(o.D,i,k)
copy(o::Orientation) = Orientation(copy(o.D),o.m,o.n)

function sinks(h::Orientation) 
    m,n = size(h)
    return [(i,j) for i=1:m,j=1:n][[issink(h,i,j) for i=1:m,j=1:n]] 
end

function sources(h::Orientation)
    m,n = size(h)
    return [(i,j) for i=1:m,j=1:n][[issource(h,i,j) for i=1:m,j=1:n]] 
end

function position(i::Integer,j::Integer,m::Integer,n::Integer)
    h = sqrt(3)/3
    if iseven(m-i) && isodd(j)
        return [j,(m-i)*3h]
    elseif iseven(m-i) && iseven(j)
        return [j,(m-i)*3h-h]
    elseif isodd(m-i) && isodd(j)
        return [j,2h+(m-i-1)*3h]
    else 
        return [j,2h+(m-i-1)*3h+h]
    end
end

function neighbors(i::Integer,j::Integer,m::Integer,n::Integer)
    nbs = Array{Int64,1}[]
    t = iseven(j) && isodd(m-i) || isodd(j) && iseven(m-i) ? -1 : 1
    for (a,b) in [(0,1),(0,-1),(t,0)] 
        if 1 ≤ i+a ≤ m && 1 ≤ j+b ≤ n
            push!(nbs,[i+a,j+b])
        end
    end
    return nbs
end

function picture(filename::AbstractString,h::Orientation;kwargs...)
    m,n = size(h)
    return Graphics2D.showgraphics(filename,
    [h[e]*Graphics2D.Arrow([position(e[1]...,m,n)'; position(e[2]...,m,n)'];
     arrowsize=0.2,arrowloc=0.6) for e in keys(h)])
end
        
function picture(h::Orientation;show=true,kwargs...)
    m,n = size(h)
    if show
        return Graphics2D.showgraphics(
	[h[e]*Graphics2D.Arrow([position(e[1]...,m,n)'; 
	position(e[2]...,m,n)'];
 	arrowsize=0.2,arrowloc=0.6,kwargs...) for e in keys(h)])
    else
        return [h[e]*Graphics2D.Arrow(
	[position(e[1]...,m,n)'; position(e[2]...,m,n)'];
	arrowsize=0.2,arrowloc=0.6,kwargs...) for e in keys(h)]
    end
end
    
function issource(O::Orientation,i::Integer,j::Integer)
    m,n = size(O)
    for (k,l) in neighbors(i,j,m,n)
        if ((i,j),(k,l)) in keys(O)
            if O[((i,j),(k,l))] == -1
                return false
            end
        elseif ((k,l),(i,j)) in keys(O)
            if O[((k,l),(i,j))] == 1
                return false
            end
        end
    end
    return true
end

function issink(O::Orientation,i::Integer,j::Integer)
    m,n = size(O)
    for (k,l) in neighbors(i,j,m,n)
        if ((i,j),(k,l)) in keys(O)
            if O[((i,j),(k,l))] == 1
                return false
            end
        elseif ((k,l),(i,j)) in keys(O)
            if O[((k,l),(i,j))] == -1
                return false
            end
        end
    end
    return true
end

function height(O::Orientation)
    m,n = size(O)
    D = Dict{Tuple{Int64,Int64},Int64}()
    D[(1,1)] = 0
    while length(D) < m*n
        for t in keys(O.D)
            if t[1] in keys(D)
                if t[2] in keys(D) 
                    if D[t[2]] - D[t[1]] != O.D[t]
                        error("height function inconsistent")
                    end
                end
                D[t[2]] = D[t[1]] + O.D[t] 
            elseif t[2] in keys(D)
                if t[1] in keys(D) 
                    if D[t[1]] - D[t[2]] != -O.D[t]
                        error("height function inconsistent")
                    end
                end
                D[t[1]] = D[t[2]] - O.D[t] 
            end
        end
    end
    return [D[i,j] for i=1:m,j=1:n]
end

function picture(D::Dict{Tuple{Int64,Int64},Int64})
    m = maximum([m for (m,n) in keys(D)])
    n = maximum([n for (m,n) in keys(D)])
    grlist = Graphics2D.GraphicElement[]
    for k in keys(D)
        push!(grlist,Graphics2D.GraphicText(position(k...,m,n),string(D[k]);textsize=1.0))
    end
    return grlist
end

function pushup!(h::Orientation,i::Integer,j::Integer)::Bool
    pushdown!(h,i,j,true)
end

function pushdown!(h::Orientation,i::Integer,j::Integer,up=false)::Bool
    m,n = size(h)
    pushed = false
    if up ? issource(h,i,j) : issink(h,i,j)
        pushed = true
        for v in neighbors(i,j,m,n)
            v = tuple(v...)
            if ((i,j),v) in keys(h)
                h[((i,j),v)] *= -1
            else
                h[(v,(i,j))] *= -1
            end
        end
    end
    return pushed
end

function minorientation(m::Integer,n::Integer)::Orientation
    return maxorientation(m,n,down=true)
end

function maxorientation(m::Integer,n::Integer;down=false)::Orientation
    topedges = [((1,j),(1,j+1)) for j=1:n-1]
    topedges = [isodd(i) ? (e[2],e[1]) : e for (i,e) in enumerate(topedges)]
    bottomedges = [((m,j),(m,j+1)) for j=1:n-1][end:-1:1]
    bottomedges = [isodd(i) ? (e[2],e[1]) : e for (i,e) in enumerate(bottomedges)]
    leftedges = vcat([[((i,1),(i+1,1)), ((i+1,1),(i+1,2)), 
        ((i+1,2),(i+2,2)), ((i+2,2),(i+2,1))] for i=1:2:m-1]...)[2m-3:-1:1]
    leftedges = [isodd(i) ? (e[2],e[1]) : e for (i,e) in enumerate(leftedges)]
    rightedges = vcat([[((i,n),(i+1,n)), ((i+1,n),(i+1,n-1)), 
        ((i+1,n-1),(i+2,n-1)), ((i+2,n-1),(i+2,n))] for i=1:2:m-1]...)[1:2m-3]
    rightedges = [isodd(i) ? (e[2],e[1]) : e for (i,e) in enumerate(rightedges)]
    boundaryedges = [topedges; rightedges; bottomedges; leftedges]
    interioredges = vcat([isodd(i+j) ? ((i,j),(i,j+1)) : ((i,j+1),(i,j)) for j=2:n-2,i=2:m-1]...)
    interioredges = [interioredges;
        vcat([((i+1,j),(i,j)) for i=1:2:m-1,j=3:2:n-2]...); 
        vcat([((i+1,j),(i,j)) for i=2:2:m-1,j=4:2:n-2]...);
    ];

    alledges = [boundaryedges; interioredges];

    O = Orientation(Dict(e=>1 for e in alledges),m,n)

    for i=1:10*(m+n)
        for j=2:m-1
            for k=3:n-2
                if down 
                    pushdown!(O,j,k)
                else
                    pushup!(O,j,k)
                end
            end
        end
    end
    return O
end



end # module
