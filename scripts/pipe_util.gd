# Enums for directions
enum Direction {
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

# Enums for pipe states
enum PipeState {
	UTILIZED = 0,
	NOT_UTILIZED = 1
}

enum PipeType {
	STRAIGHT = 0,
	CURVED = 1,
	T_JUNCTION = 2,
	CROSS = 3
}

const STRAIGHT_PIPE = "res://assets/straight_pipe.png" 
const CURVED_PIPE = "res://assets/curved_pipe.png"
# const T_JUNCTION_PIPE = "res://assets/t_junction_pipe.png"
# const CROSS_PIPE = "res://assets/cross_pipe.png"