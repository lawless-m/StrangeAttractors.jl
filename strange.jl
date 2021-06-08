using Random     
using Images
using FileIO
using DynamicPolynomials

@polyvar x
@polyvar y
@polyvar z
@polyvar w


global a


function progs(ndims, order)
    m = 1
    dims = ["x", "y", "z", "w"]

    progs = Dict{String, Vector{String}}()
    for i in 1:ndims
        d = dims[i]
        progs[d] = Vector{String}()
        push!(progs[d], "a[$m]")
        m += 1
        for i1 in 1:ndims
            push!(progs[d], "a[$m] * $(dims[i1])")
            m += 1
            for i2 in i1:ndims
                push!(progs[d], "a[$m] * $(dims[i1]) * $(dims[i2])")
                m += 1
                if order > 2
                    for i3 in i2:ndims
                        push!(progs[d], "a[$m] * $(dims[i1]) * $(dims[i2]) * $(dims[i3])")
                        m += 1
                        if order > 3
                            for i4 in i3:ndims
                                push!(progs[d], "a[$m] * $(dims[i1]) * $(dims[i2]) * $(dims[i3]) * $(dims[i4])")
                                m += 1
                                if order > 4
                                    for i5 in i4:ndims
                                        push!(progs[d], "a[$m] * $(dims[i1]) * $(dims[i2]) * $(dims[i3]) * $(dims[i4]) * $(dims[i5])")
                                        m += 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    progs, m-1
end

function polys(es::Dict{String, Expr})
    ps = Dict{String, DynamicPolynomials.Polynomial{true,Float64}}()

    for d in keys(es)
        ps[d] = eval(es[d])
    end
    ps
end


function exprs(ps::Dict{String, Vector{String}})

    es = Dict{String, Expr}()
    for d in keys(ps)
        es[d] = Meta.parse(join(ps[d], " + "))
    end

    es
end



function write_raw(iters, w, h)
    xrange = (minimum(iters["x"]), maximum(iters["x"]))
    xscale = (w-1) / (xrange[2]-xrange[1])
    yrange = (minimum(iters["y"]), maximum(iters["y"]))
    yscale = (h-1) / (yrange[2]-yrange[1])

    pixels = zeros(Int64, w, h)

    for i in 1:length(iters["x"])
        fx = iters["x"][i]
        fy = iters["y"][i]
        if abs(fx) == Inf || isnan(fx) || abs(fy) == Inf || isnan(fy)
            break
        end
        x = floor(Int64, 1+(fx - xrange[1]) * xscale)
        y = floor(Int64, 1+(fy - yrange[1]) * yscale)
        
        pixels[x, y] += 1
    end

    gmax = 1 / maximum(pixels)
    
    gs =  (pixels .* gmax) |> colorview(Gray)

    save("t.jpg", gs)
    gs
end

function string2args(s::String)
    [(Int(c)-77)/10.0 for c in s]
end

function iterate(ps, states, ns)
    
    n = 1 + ns[end]-ns[1]

    iters = Dict{String, Vector{Float64}}()
    for d in keys(ps)
        iters[d] = zeros(Float64, n)
    end

    for i in 1:n
         for d in keys(iters)
            iters[d][i] = ps[d](x=>states["x"], y=>states["y"], z=>states["z"], w=>states["w"])
        end
         for d in keys(iters)
            states[d] = iters[d][i]
        end
        
    end

    iters
end

function lyup(vs)
    L = 0.
    for i in 2:length(vs)
        L += abs(vs[i-1] - vs[i])
    end
    L /= length(vs)
    0.721347 * log(L)
end

function valid(iters)
   for d in keys(iters)
        ld = lyup(iters[d])
        if isnan(ld) || ld == Inf
            return false
        end

        if 1 < abs(ld) < 2
            return false
        end
    end
    return true
end


while true
      global a
    pgs, as = progs(2,2)
    a = rand(as)
    es = exprs(pgs)
    pl = polys(es)

    states = Dict{String, Float64}()
    states["x"] = 0.05
    states["y"] = 0.05
    states["z"] = 0.05
    states["w"] = 0.05

    iters = iterate(pl, states, 1:100)

    if valid(iters)
        
        states["x"] = 0.05
        states["y"] = 0.05
        states["z"] = 0.05
        states["w"] = 0.05

        write_raw(iterate(pl, states, 1:50000), 800, 600)
        break
    end
end