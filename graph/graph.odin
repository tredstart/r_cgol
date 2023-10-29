package graph
import "core:fmt"

import "core:math"

Point :: struct {
    x, y: int
}

Node :: struct {
    v: [dynamic]Point
}

Cell :: struct {
    nodes: map[Point]^Node
}

cell_append :: proc(self: ^Cell, point: Point) {
    n := new_node()
    for p, node in self.nodes {
        x := math.abs(p.x - point.x)
        y := math.abs(p.y - point.y)
        if x <= 1 && y <= 1 {
            node_add(node, point)
            node_add(n, p)
        }
    }
    self.nodes[point] = n
}

rule_of_death :: proc(self: ^Cell) -> [dynamic]Point {
    still_alive := make([dynamic]Point)
    for point, node in self.nodes {
        switch node_count(node) {
            case 2..=3: append(&still_alive, point)
            case: 
        }
    }
    return still_alive
}

rule_of_life :: proc(self: ^Cell) -> [dynamic]Point {
    // in this case I need to get all the neighbours of the alive points 
    // (because this is the only way new alive will be born). Then I add 
    // every neighbour with it's alive point (if it's not alive itself).
    // Then I check for number of the connections and if any has 3, it 
    // will become alive in the next gen.
    alive_again := make([dynamic]Point)
    dead_cells := make(map[Point]^Node)
    defer delete(dead_cells)

    for point, _ in self.nodes {
        neighbours := fill_dead(point)
        defer delete(neighbours)
        for neighbour in neighbours {
            n, ok := dead_cells[neighbour]
            switch ok {
                case true: node_add(n, point)
                case:
                {
                    if !(neighbour in self.nodes) {
                        node := new_node()
                        node_add(node, point)
                        dead_cells[neighbour] = node
                    }
                }
            }
        }
    }
    for point, node in dead_cells {
        switch node_count(node) {
            case 3: append(&alive_again, point)
            case:
        }
        delete(node.v)
        free(node)
    }
    return alive_again
}
cell_cleanup :: proc(self: ^Cell) {
        for _, node in self.nodes {
            delete(node.v)
            free(node)
        }
        delete(self.nodes)
        free(self)
}

@private
fill_dead :: proc(point: Point) -> [dynamic]Point {
    dead_neighbours := make([dynamic]Point)
    append(&dead_neighbours, Point{point.x - 1, point.y - 1})
    append(&dead_neighbours, Point{point.x + 1, point.y - 1})
    append(&dead_neighbours, Point{point.x - 1, point.y + 1})
    append(&dead_neighbours, Point{point.x + 1, point.y + 1})
    append(&dead_neighbours, Point{point.x - 1, point.y})
    append(&dead_neighbours, Point{point.x + 1, point.y})
    append(&dead_neighbours, Point{point.x,  point.y - 1})
    append(&dead_neighbours, Point{point.x, point.y + 1})
    return dead_neighbours
}

@private
new_node :: proc() -> ^Node {
    return new(Node)
}

@private 
node_count :: proc(self: ^Node) -> int {
    return len(self.v)
}

@private 
node_add :: proc(self: ^Node, point: Point) {
    append(&self.v, point)
}
