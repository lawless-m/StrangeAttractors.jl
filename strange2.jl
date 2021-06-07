using DynamicPolynomials

@polyvar x
@polyvar y
@polyvar z
@polyvar w

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

function exprs(ndims, order)
    ps, as = progs(ndims, order)

    es = Dict{String, Expr}()
    for d in keys(ps)
        es[d] = Meta.parse(join(ps[d], " + "))
    end

    es, as
end

function polys(es::Dict{String, Expr}, a::Vector{Float64})
    ps = Dict{String, DynamicPolynomials.Polynomial{true,Float64}}()

    for d in keys(es)
            ps[d] = eval(es[d])
    end
    ps
end

function string2args(s::String)
    [(Int(c)-77)/10.0 for c in s]
end

function write_raw(iters, w, h)
    hrange = (minimum(iters["x"]), maximum(iters["x"]))
    hscale = (w-1) / (hrange[2]-hrange[1])
    yrange = (minimum(iters["y"]), maximum(iters["y"]))
    yscale = (h-1) / (yrange[2]-yrange[1])

    println(hrange, hscale)
    println(yrange, yscale)

    pixels = zeros(Int64, w, h)

    for i in 1:length(iters["x"])
        x = floor(Int64, 1+(iters["x"][i] - hrange[1]) * hscale)
        y = floor(Int64, 1+(iters["y"][i] - yrange[1]) * yscale)
        pixels[x, y] += 1
    end

    gmax = 255 / maximum(pixels)
    f = open("/tmp/gs.data", "w+")
    for p in pixels
        write(f, floor(UInt8, p*gmax))
    end
end

es, as = exprs(2, 2)
a = string2args("EAGHNFODVNJCP"[2:end])
ps = polys(es, a)

n = 100000000
iters = Dict{String, Vector{Float64}}()
for d in keys(ps)
    iters[d] = zeros(Float64, n)
end

states = Dict{String, Float64}()
states["x"] = 0.05
states["y"] = 0.05
states["z"] = 0.05
states["w"] = 0.05

for i in 1:n
    for d in keys(iters)
        states[d] = iters[d][i] = ps[d](x=>states["x"], y=>states["y"], z=>states["z"], w=>states["w"])
    end
end

write_raw(iters, 2400, 1800)
