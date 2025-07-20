# UpgradeData.gd
class_name UpgradeData
extends Resource

## The unique ID for saving/loading (e.g., "university_curriculum_1").
@export var id: String = ""

## The name shown in the UI (e.g., "Improved Curriculum").
@export var display_name: String = "New Upgrade"

## A description of what the upgrade does.
@export var description: String = "Describe the upgrade's effect."

## The icon for the upgrade.
@export var icon: Texture2D

## How much RP this upgrade costs.
@export var cost: float = 1000.0

## The ID of the generator this affects. Use "all" for a global boost.
@export var target_generator_id: String = ""

## How much this upgrade multiplies the target's production (e.g., 2.0 for x2).
@export var production_multiplier: float = 2.0
