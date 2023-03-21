import LinearAlgebra
using Plots


Base.@kwdef mutable struct LayoutCoords 
    x::Float32 = 0.0
    y::Float32 = 0.0
end


mutable struct Node 
    const name::String
    coords::LayoutCoords
end


struct Edge 
    name::String 
    source::Node 
    target::Node
    length::Float32
    strength::Int8
end


function normalize_edge(edge::Edge)::Vector
    dx = edge.target.coords.x - edge.source.coords.x
    dy = edge.target.coords.y - edge.source.coords.y 
    v = [dx, dy]
    d = LinearAlgebra.norm(v, 2)
    return v / d
end


function length_edge(edge::Edge)::Float32 
    dx = edge.target.coords.x - edge.source.coords.x
    dy = edge.target.coords.y - edge.source.coords.y 
    v = [dx, dy]
    d = LinearAlgebra.norm(v, 2)
    return d 
end


function edge_length_constraint!(edge::Edge)::Nothing
    """Apply a length constraint."""
    dx = edge.target.coords.x - edge.source.coords.x
    dy = edge.target.coords.y - edge.source.coords.y 
    v = [dx, dy]
    d = LinearAlgebra.norm(v, 2)
    Δl = (edge.length - d) / (2.0 * d)
    dx *= Δl 
    dy *= Δl 
    edge.source.coords.x -= dx 
    edge.source.coords.y -= dy
    edge.target.coords.x += dx
    edge.target.coords.y += dy
    return nothing
end


function edge_pair_curvature_constraint!(edge_i::Edge, edge_j::Edge)::Nothing 
    vi = normalize_edge(edge_i)
    vj = normalize_edge(edge_j)
    dp = clamp(LinearAlgebra.dot(vi, vj), -1, 1)
    θ = acos(dp)

    return nothing
end


node_A = Node("A", LayoutCoords(x=0.0, y=0.0))
node_B = Node("B", LayoutCoords(x=10.0, y=12.0))
node_C = Node("C", LayoutCoords(x=-4.0, y=-6.0))
node_D = Node("D", LayoutCoords(x=-4.0, y=5.0))

edge_A = Edge("Link", node_A, node_B, 1.0, 5)
edge_B = Edge("Link", node_C, node_D, 1.0, 5)
edge_C = Edge("Hyperlink", node_A, node_C, 3.0, 1)
edge_D = Edge("Hyperlink", node_B, node_D, 4.0, 1)


nodes = [node_A, node_B, node_C, node_D]
edges = [edge_A, edge_B, edge_C, edge_D]

edge_pair_curvature_constraint!(edge_A, edge_B)


anim = @animate for i=1:50

    scatter([n.coords.x for n in nodes], [n.coords.y for n in nodes])

    # for edge ∈ edges
    #     for i ∈ 1:edge.strength
    #         edge_length_constraint!(edge)
    #     end
    #     # println(edge, edge_length(edge))
    # end

    
    plot(
        [edge_A.source.coords.x, edge_A.target.coords.x, edge_B.target.coords.x], 
        [edge_A.source.coords.y, edge_A.target.coords.y, edge_B.target.coords.y]
    )

    edge_pair_curvature_constraint!(edge_A, edge_B)

end

gif(anim, "/Users/arl/Desktop/julia_plot.gif")

