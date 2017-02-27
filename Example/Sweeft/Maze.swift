//
//  Maze.swift
//  Sweeft
//
//  Created by Mathias Quintero on 2/27/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Sweeft

final class Maze {
    
    enum Direction {
        
        static let all: [Direction] = [.right, .left, .up, .down]
        
        case right, left, up, down
        
        var opposite: Direction {
            switch self {
            case .right:
                return .left
            case .left:
                return .right
            case .up:
                return .down
            case .down:
                return .up
            }
        }

        func coordinates(byApplyingTo point: Coordinates) -> Coordinates {
            switch self {
            case .right:
                return Coordinates(x: point.x + 1, y: point.y)
            case .left:
                return Coordinates(x: point.x - 1, y: point.y)
            case .up:
                return Coordinates(x: point.x, y: point.y - 1)
            case .down:
                return Coordinates(x: point.x, y: point.y + 1)
            }
        }
    }
    
    struct Coordinates {
        let x: Int
        let y: Int
        
        func distance(to point: Coordinates) -> Int {
            return abs(x - point.x) + abs(y - point.y)
        }
    }
    
    let maze: [[Bool]]
    
    init(maze: [[Bool]]) {
        self.maze = maze
    }

    func hasPath(at point: Coordinates) -> Bool {
        return !hasWall(at: point)
    }
    
    func hasWall(at point: Coordinates) -> Bool {
        if point.x < 0 || point.x >= maze[0].count || point.y < 0 || point.y >= maze.count {
            return true
        }
        return maze[point.y][point.x]
    }

    func nextDecisiveCoordinate(for point: Coordinates, in direction: Direction, steps: Int = 1) -> (Coordinates, Int) {
        let neighbour = direction.coordinates(byApplyingTo: point)
        if directions(for: neighbour).count == 2 {
            let directions = self.directions(for: neighbour) |> { $0.opposite != direction }
            if let direction = directions.first {
                return nextDecisiveCoordinate(for: neighbour, in: direction, steps: steps + 1)
            }
        }
        return (neighbour, steps)
    }
    
    func directions(for point: Coordinates) -> [Direction] {
        return Direction.all |> { $0.coordinates(byApplyingTo: point) | self.hasPath }
    }
    
    func neighbours(for point: Coordinates) -> [Coordinates] {
        return directions(for: point) => { $0.coordinates(byApplyingTo: point) }
    }
    
    func findWay(from source: Coordinates, to destination: Coordinates) -> ResultPromise<[MazeNode]?> {
        let source = MazeNode(maze: self, point: source)
        let destination = MazeNode(maze: self, point: destination)
        return source.shortestPath(with: { $0.point.distance(to: destination.point) | Double.init },
                                   to: destination)
    }
    
}

extension Maze: ExpressibleByArrayLiteral {
    
    convenience init(arrayLiteral elements: [Bool]...) {
        self.init(maze: elements)
    }

}

struct MazeNode: HashableNode, SyncNode {
    
    var neighbours: [Connection<MazeNode>] {
        return maze.directions(for: point) => { direction in
            let next = maze.nextDecisiveCoordinate(for: point, in: direction)
            let node = MazeNode(maze: maze, point: next.0)
            return .cost(to: node, cost: Double(next.1))
        }
    }
    
    let maze: Maze
    let point: Maze.Coordinates
    
}

extension MazeNode {
    
    var hashValue: Int {
        return "\(point.x),\(point.y)".hashValue
    }
    
    static func ==(lhs: MazeNode, rhs: MazeNode) -> Bool {
        return lhs.point.x == rhs.point.x && lhs.point.y == rhs.point.y
    }
    
}
