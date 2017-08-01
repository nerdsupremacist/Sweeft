
import Sweeft
import UIKit

func flipped<V>(array: [[V]]) -> [[V]] {
    return array.first?.count.range => { a in array.count.range => { b in array[b][a] } }
}

func ==(lhs: Maze.Coordinates, rhs: Maze.Coordinates) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

extension UIColor {
    
    static var wallColor: UIColor {
        return UIColor(red: 52 / 255, green: 50 / 255, blue: 59 / 255, alpha: 1)
    }
    
    static var pathColor: UIColor {
        return UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1)
    }
    
    static var pathTakenColor: UIColor {
        return UIColor(red: 0.1, green: 0.9, blue: 0.1, alpha: 1)
    }
    
}

enum FieldType {
    case path
    case wall
    case fixedWall
}

extension FieldType {
    
    var bool: Bool {
        return self != .path
    }
    
    var color: UIColor {
        switch self {
        case .fixedWall:
            return .black
        case .path:
            return .pathColor
        case .wall:
            return .wallColor
        }
    }
    
    func set(view: UIView) {
        UIView.animate(withDuration: 0.3) {
            view.backgroundColor = self.color
        }
    }
    
    mutating func toggle() {
        switch self {
        case .path:
            self = .wall
        case .wall:
            self = .path
        default: break
        }
    }
    
}

class Game {
    var score: Int = 0
}

class InternalMaze {
    
    typealias Solution = [Maze.Coordinates]
    
    var entry: Maze.Coordinates
    var exit: Maze.Coordinates
    var items: [[FieldType]]
    var wallLimit: Int
    
    var wallsAdded: Int {
        
        return items.flatMap { $0 }
            .filter { $0 == .wall }
            .count
    }
    
    var wallsLeft: Int {
        return wallLimit - wallsAdded
    }
    
    var width: Int {
        return (items.first?.count ?? 0) + 2
    }
    
    var height: Int {
        return items.count + 2
    }
    
    init(entry: Maze.Coordinates, exit: Maze.Coordinates, width: Int, height: Int, wallLimit: Int) {
        self.entry = entry
        self.exit = exit
        items  = height.range => **{ width.range => **{ .path } }
        self.wallLimit = wallLimit
    }
    
    func resultingMaze() -> Maze {
        let firstRow = width.range => **{ true }
        let otherRows = items => { [true] + ($0 => { $0.bool }) + [true] }
        var maze = [firstRow] + otherRows + [firstRow]
        maze[entry.y][entry.x] = false
        maze[exit.y][exit.x] = false
        return Maze(maze: maze)
    }
    
    func solution() -> [Maze.Coordinates]? {
        return resultingMaze().solution(from: entry, to: exit)
    }
    
    func hasSolution() -> Bool {
        return solution() != nil
    }
    
    func value(of coordinates: Maze.Coordinates) -> FieldType {
        return items[coordinates.y - 1][coordinates.x - 1]
    }
    
    func canToggle(at coordinates: Maze.Coordinates) -> Bool {
        switch value(of: coordinates) {
        case .fixedWall:
            return false
        case .wall:
            return true
        case .path:
            guard wallsAdded < wallLimit else {
                return false
            }
            change(at: coordinates)
            let result = hasSolution()
            change(at: coordinates)
            return result
        }
    }
    
    func change(at coordinates: Maze.Coordinates) {
        items[coordinates.y - 1][coordinates.x - 1].toggle()
    }
    
    func set(coordinates: Maze.Coordinates, to type: FieldType) {
        items[coordinates.y - 1][coordinates.x - 1] = type
    }
    
    func toggle(at coordinates: Maze.Coordinates) {
        guard canToggle(at: coordinates) else {
            return
        }
        change(at: coordinates)
    }
    
    func scoreWithoutWalls() -> Int {
        let walls = (width - 2).range?.flatMap { x in
            (height - 2).range => { y in
                Maze.Coordinates(x: x + 1, y: y + 1)
            }
        } |> { self.value(of: $0) == .wall }
        walls => { self.set(coordinates: $0, to: .path) }
        let result = score()
        walls => { self.set(coordinates: $0, to: .wall) }
        return result
    }
    
    func score() -> Int {
        let solution = self.solution().?
        let edges = (solution.count - 1).range => { (solution[$0], solution[$0 + 1]) }
        return edges ==> 0 ** {
            return $0 + $1.0.distance(to: $1.1)
        }
    }
    
    func weightedScore() -> Int {
        return score() - scoreWithoutWalls()
    }
    
    func fillRandomly(walls: Int) {
        guard walls <= wallsLeft, walls > 0 else {
            return
        }
        var coordinates: Maze.Coordinates
        repeat {
            let x = (self.width - 2).anyRange.random ?? 0
            let y = (self.height - 2).anyRange.random ?? 0
            coordinates = Maze.Coordinates(x: x + 1, y: y + 1)
        } while !canToggle(at: coordinates)
        set(coordinates: coordinates, to: .fixedWall)
        return fillRandomly(walls: walls - 1)
    }
    
}

protocol MazeDatasource {
    var maze: InternalMaze { get }
    func didUpdate()
}

protocol MazeImporter {
    var dataSource: MazeDatasource! { get set }
    var coordinates: Maze.Coordinates! { get set }
    func update()
}

class MazeViewController: UIViewController, MazeDatasource {
    
    var height: Int! = 5
    var width: Int! = 5
    lazy var limit: Int = {
        return Int((self.height * self.width) / 3) - max(self.height, self.width) / 2 // Magic numbers
    }()
    
    var score: Int = 0
    
    lazy var maze: InternalMaze = {
        let entry = Maze.Coordinates(x: 0, y: (self.height.range?.random).? + 1)
        let exit = Maze.Coordinates(x: self.width + 1, y: (self.height.range?.random).? + 1)
        let maze = InternalMaze(entry: entry, exit: exit, width: self.width, height: self.height, wallLimit: self.limit)
        maze.fillRandomly(walls: Int(sqrt(Double(self.limit))))
        return maze
    }()
    
    lazy var mazeView: MazeView = {
        let view = MazeView(frame: self.view.bounds)
        view.dataSource = self
        return view
    }()
    
    lazy var scoreView: ScoreView = {
        let view = ScoreView(frame: self.view.bounds)
        view.limit = self.maze.wallsLeft
        view.score = self.score
        view.heightAnchor.constraint(equalToConstant: 75).isActive = true
        return view
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(frame: self.view.bounds)
        button.setTitleColor(.pathColor, for: .normal)
        button.setTitle("Done", for: .normal)
        button.backgroundColor = .black
        button.heightAnchor.constraint(equalToConstant: 75).isActive = true
        button.addTarget(self, action: #selector(done), for: .touchDown)
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.scoreView, self.mazeView, self.button])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.frame = self.view.bounds
        return stack
    }()
    
    func didUpdate() {
        mazeView.update()
        scoreView.update(limit: maze.wallsLeft)
    }
    
    override func viewDidLoad() {
        
        
        print(LastDateOpened.value ?? "No Value!")
        
        super.viewDidLoad()
        mazeView.backgroundColor = .wallColor
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mazeView.update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func addScore(andCall handler: @escaping () -> ()) {
        let score = maze.weightedScore()
        if score != 0 {
            self.score += score
            scoreView.update(score: self.score, positive: score > 0, andCall: handler)
        } else {
            handler()
        }
    }
    
    func next() {
        let controller = MazeViewController()
        controller.score = self.score
        
        if [true, false, false].random.? {
            controller.height = height + 1
            controller.width = width + 1
        } else {
            controller.height = height
            controller.width = width
        }
        
        
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true)
    }
    
    func done() {
        addScore(andCall: self.next)
    }
    
}

class ScoreView: UIView {
    
    var limit: Int!
    var score: Int!
    
    lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.text = self.limitText
        label.textColor = .wallColor
        label.textAlignment = .center
        return label
    }()
    
    lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.text = self.scoreText
        label.textColor = .wallColor
        label.textAlignment = .center
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.limitLabel, self.scoreLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var limitText: String {
        return "Walls left: \(limit.?)"
    }
    
    var scoreText: String {
        return "Score: \(score.?)"
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        addSubview(stackView)
        backgroundColor = .pathColor
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    func update(limit: Int) {
        UIView.animate(withDuration: 0.2) {
            self.limit = limit
            self.limitLabel.text = self.limitText
        }
    }
    
    func update(score: Int, positive: Bool, andCall handler: @escaping () -> () = dropArguments) {
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: .autoreverse, animations: {
            self.score = score
            self.scoreLabel.text = self.scoreText
            self.scoreLabel.textColor = positive ? .green : .red
        }) { _ in
            handler()
        }
    }
    
}

class MazeView: UIView {
    
    var dataSource: MazeDatasource!
    
    lazy var userViews: [[UserSetFieldView]] = {
        let width = self.dataSource.maze.width - 2
        let height = self.dataSource.maze.height - 2
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        return height.range => { y in
            return width.range => { x in
                let view = UserSetFieldView(frame: frame)
                view.dataSource = self.dataSource
                view.coordinates = Maze.Coordinates(x: x + 1, y: y + 1)
                return view
            }
        }
    }()
    
    lazy var mazeViews: [[UIView]] = {
        let width = self.dataSource.maze.width
        let height = self.dataSource.maze.height
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let firstRow = width.range => { x in
            FixedFieldView(frame: frame, dataSource: self.dataSource, coordinates: Maze.Coordinates(x: x, y: 0))
        }
        let rows = self.userViews => {
            [FixedFieldView(frame: frame, dataSource: self.dataSource, coordinates: Maze.Coordinates(x: 0, y: $1 + 1))]
                + ($0 => { $0 as UIView })
                + [FixedFieldView(frame: frame, dataSource: self.dataSource, coordinates: Maze.Coordinates(x: width - 1, y: $1 + 1))]
        }
        var result = [firstRow => { $0 as UIView }] + rows
        return result
    }()
    
    lazy var stackView: UIStackView = {
        let internalStacks = self.mazeViews => { (views: [UIView]) -> UIStackView in
            let stack = UIStackView(arrangedSubviews: views)
            stack.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            stack.backgroundColor = .green
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.alignment = .fill
            stack.spacing = 0
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }
        let stack = UIStackView(arrangedSubviews: internalStacks)
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.frame = self.bounds
        return stack
    }()
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        layoutIfNeeded()
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    func update() {
        self.userViews.flatMap { $0 }
            .forEach { $0.0.update() }
    }
    
}

final class FixedFieldView: UIView {
    
    var dataSource: MazeDatasource!
    var coordinates: Maze.Coordinates!
    
    var type: FieldType = .fixedWall {
        didSet {
            type.set(view: self)
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        let isEntryOrExit = coordinates == dataSource.maze.entry || coordinates == dataSource.maze.exit
        type = isEntryOrExit ? .path : .fixedWall
    }
    
    convenience init(frame: CGRect, dataSource: MazeDatasource, coordinates: Maze.Coordinates) {
        self.init(frame: frame)
        self.dataSource = dataSource
        self.coordinates = coordinates
    }
    
}

class UserSetFieldView: UIButton, MazeImporter {
    
    var dataSource: MazeDatasource!
    var coordinates: Maze.Coordinates!
    
    var currentType: FieldType = .path {
        didSet {
            currentType.set(view: self)
        }
    }
    
    func toggle() {
        guard dataSource.maze.canToggle(at: coordinates) else {
            self.backgroundColor = dataSource.maze.value(of: self.coordinates).color
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .autoreverse, animations: {
                self.backgroundColor = .red
            }) { _ in
              self.backgroundColor = self.dataSource.maze.value(of: self.coordinates).color
            }
            return
        }
        dataSource.maze.toggle(at: coordinates)
        dataSource.didUpdate()
    }
    
    func update() {
        
        self.addTarget(self, action: #selector(toggle), for: .touchDown)
        
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
            self.currentType = self.dataSource.maze.value(of: self.coordinates)
            self.layoutIfNeeded()
        }
    }
    
}

