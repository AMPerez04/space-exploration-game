# GameManager.gd
extends Node

## Player's current Research Points.
var research_points: float = 0.0

## Player's current click power
var manual_click_power: float = 1.0

## A dictionary to store how many of each generator the player owns.
## Format: { "generator_id": count }
var owned_generators: Dictionary = {
	"university": 0,
	"private_company": 0,
	"supercomputer_cluster": 0,
	"global_ai_network": 0,
	"quantum_lab": 0,
	# We'll add Moon and Mars generators later
}

## An array to hold all our GeneratorData resources.
## We link them here in the Inspector.
@export var all_generators: Array[GeneratorData]

# This is a helper dictionary for quick lookups.
var _generator_data_map: Dictionary = {}

func _ready():
	# Build the helper map for fast access instead of looping through the array every time.
	print(all_generators) 
	for gen_data in all_generators:
		_generator_data_map[gen_data.id] = gen_data
	
	print("GameManager is ready!")
	# For testing, let's start with some RP
	research_points = 15.0

# The main game loop. 'delta' is the time since the last frame.
func _process(delta: float):
	var rps = calculate_total_rps()
	research_points += rps * delta

# Calculates the total RP per second from all owned generators.
func calculate_total_rps() -> float:
	var total_rps: float = 0.0
	for generator_id in owned_generators:
		var count = owned_generators[generator_id]
		if count > 0:
			var gen_data: GeneratorData = _generator_data_map[generator_id]
			total_rps += gen_data.base_rps * count
	return total_rps

# Calculates the current cost of a specific generator.
func get_generator_cost(generator_id: String) -> float:
	var gen_data: GeneratorData = _generator_data_map[generator_id]
	var count = owned_generators.get(generator_id, 0)
	# The core cost formula: base_cost * multiplier^count
	return gen_data.base_cost * pow(gen_data.cost_multiplier, count)

# The function to buy a generator.
func buy_generator(generator_id: String):
	var cost = get_generator_cost(generator_id)
	if research_points >= cost:
		research_points -= cost
		owned_generators[generator_id] += 1
		print("Bought 1 %s. New count: %d" % [generator_id, owned_generators[generator_id]])
	else:
		print("Not enough RP to buy %s" % generator_id)

func manual_research_click():
	research_points += manual_click_power
	# We can add sound effects or visual feedback here later!
