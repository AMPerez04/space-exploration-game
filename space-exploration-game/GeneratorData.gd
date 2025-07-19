# GeneratorData.gd
class_name GeneratorData
extends Resource

## The unique ID for this generator (e.g., "university", "supercomputer_cluster").
@export var id: String = ""

## The display name shown to the player (e.g., "University").
@export var display_name: String = "New Generator"

## The starting cost to buy the first one.
@export var base_cost: float = 10.0

## The amount of RP this generator produces per second at level 1.
@export var base_rps: float = 1.0

## How much the cost multiplies for each new one you buy. 1.07 is a common starting value.
@export var cost_multiplier: float = 1.07

## Which stage this generator belongs to (we'll use this later).
# @export_enum("Earth", "Moon", "Mars") var stage: String = "Earth"

## The levels at which this generator gets a production bonus (e.g., 25, 50, 100).
@export var multiplier_milestones: Array[int] = [10, 25, 50, 100, 200, 300, 400, 500]

## The production multiplier gained at each milestone (e.g., 2.0 for x2 speed).
@export var production_multiplier: float = 2.0
