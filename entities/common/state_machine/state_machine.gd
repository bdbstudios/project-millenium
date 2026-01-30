class_name StateMachine extends Node

@export var initial_state: State

var current_state: State
var character_body: CharacterBody3D
var states: Dictionary[String, State] = {}

func init(character: CharacterBody3D) -> void:
	character_body = character

	read_states_recursive(self, "")

	assert(initial_state, "No initial state was assigned")
	assert(states.size() > 0, "No states found in state machine")

	initial_state.enter()
	current_state = initial_state

func read_states_recursive(node: Node, path: String) -> void:
	if node != self and node is State:
		var state = node as State
		state.state_machine = self
		state.character_body = character_body

		var state_path: String

		if path:
			state_path = path + "/" + node.name
		else:
			state_path = node.name

		state.state_path = state_path

		states[state_path.to_lower()] = state

	for child in node.get_children():
		var child_path: String

		if path:
			child_path = path + "/" + node.name
		elif node != self:
			child_path = node.name
		else:
			child_path = ""

		read_states_recursive(child, child_path)

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func handle_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func change_state(state_path: String) -> void:
	var new_state: State = states.get(state_path.to_lower())
	
	assert(new_state, "State not found: " + state_path)
	
	if current_state:
		current_state.exit()

	new_state.enter()
	current_state = new_state
