package main

import "core:fmt"
import "graph"

main :: proc() {
    width :: 50
    height :: 50

    points := []graph.Point{
        {25, 25},
        {26, 26},
        {26, 27},
        {25, 27},
        {24, 27},
    }

    alive := new(graph.Cell)
    for point in points {
        graph.cell_append(alive, point)
    }
    defer graph.cell_cleanup(alive)
    for _ in 0..<100 {
        rows: [width]string
        cells: [height]type_of(rows)
        for point, _ in alive.nodes {
            cells[point.x][point.y] = "X"
        }
        for row in 0..<height {
            for cell in 0..<width {
                if cells[row][cell] != "X" {
                    cells[row][cell] = " "
                }
                fmt.print(cells[row][cell])
            }
            fmt.println()
        }
        alive_next_gen := new(graph.Cell)
        apply_rule(alive, alive_next_gen, graph.rule_of_life)
        apply_rule(alive, alive_next_gen, graph.rule_of_death)
        graph.cell_cleanup(alive)
        alive = alive_next_gen
    }
}

apply_rule :: proc(
    alive: ^graph.Cell,
    alive_next_gen: ^graph.Cell,
    rule: proc(^graph.Cell)->[dynamic]graph.Point){
        points_of_death := rule(alive)
        for point in points_of_death {
            graph.cell_append(alive_next_gen, point)
        }
        delete(points_of_death)
}
