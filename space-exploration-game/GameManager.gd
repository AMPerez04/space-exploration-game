# GameManager.gd
extends Node

## Player's save path
const SAVE_PATH = "user://savegame.json"

## Player's current Research Points.
var research_points: float = 0.0

## Player's current click power
var manual_click_power: float = 1.0

signal offline_progress_calculated(seconds, rp_earned)

## A dictionary to store how many of each generator the player owns.
## Format: { "generator_id": count }
var owned_generators: Dictionary = {
    "university": 0,
    "private_company": 0,
    "supercomputer_cluster": 0,
    "global_ai_network": 0,
    # We'll add Moon and Mars generators later
}
            
var purchased_upgrades: Dictionary = {}

@export var all_upgrades: Array[UpgradeData]
var _upgrade_data_map: Dictionary = {}

## An array to hold all our GeneratorData resources.
## We link them here in the Inspector.
@export var all_generators: Array[GeneratorData]

# This is a helper dictionary for quick lookups.
var _generator_data_map: Dictionary = {}

func _ready():
    # Build the helper map for fast access instead of looping through the array every time.
    for gen_data in all_generators:
        _generator_data_map[gen_data.id] = gen_data
        # NEW: Pre-sort the milestone arrays for efficient calculation later.
        if gen_data.multiplier_milestones:
            gen_data.multiplier_milestones.sort()
            
    for upg_data in all_upgrades:
        _upgrade_data_map[upg_data.id] = upg_data
        
    if not load_game():
        # ...then this must be a new game. Set up the initial state.
        print("Setting up a new game.")
        research_points = 15.0
        # It's good practice to also initialize your other variables here
        # for a fresh start, even if they have defaults.
        owned_generators = {
            "university": 0,
            "private_company": 0,
            "supercomputer_cluster": 0,
            "global_ai_network": 0,
        }
    

    
    print("GameManager is ready!")

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
            # Get the multiplier for this specific generator
            var multiplier = calculate_generator_multiplier(generator_id)
            # Apply the multiplier to the base production rate
            var boosted_rps = gen_data.base_rps * multiplier
            # Add the total production from all generators of this type
            total_rps += boosted_rps * count
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

func calculate_generator_multiplier(generator_id: String) -> float:
    var total_multiplier: float = 1.0
    var gen_data: GeneratorData = _generator_data_map.get(generator_id)
    var count = owned_generators.get(generator_id, 0)
    
    if not gen_data:
        return 1.0

    # Loop through the milestones (we pre-sorted them in _ready)
    for milestone_level in gen_data.multiplier_milestones:
        if count >= milestone_level:
            # If we've reached the milestone, apply the multiplier
            total_multiplier *= gen_data.production_multiplier
        else:
            # Since the list is sorted, we can stop checking once we find a milestone
            # we haven't reached yet.
            break
            
    for purchased_id in purchased_upgrades:
        var upg_data: UpgradeData = _upgrade_data_map.get(purchased_id)
        if not upg_data: continue
        
        # Check if this upgrade applies to the current generator OR to "all"
        if upg_data.target_generator_id == generator_id or upg_data.target_generator_id == "all":
            total_multiplier *= upg_data.production_multiplier
            
    return total_multiplier

# ... At the end of GameManager.gd ...

func save_game():
    print("Saving game...")
    # 1. Create a dictionary to hold all the data we want to save.
    var save_data = {
        "research_points": research_points,
        "owned_generators": owned_generators,
        "purchased_upgrades": purchased_upgrades,
        "last_save_time": Time.get_unix_time_from_system() 
    }
    
    # 2. Open the save file for writing.
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if not file:
        print("Error: Could not open save file for writing.")
        return

    # 3. Convert our dictionary to a JSON string.
    var json_string = JSON.stringify(save_data, "\t") # The "\t" makes it nicely indented
    
    # 4. Write the string to the file and close it.
    file.store_string(json_string)
    file.close()
    print("Game saved successfully.")

func load_game() -> bool:
    # 1. Check if the save file even exists.
    if not FileAccess.file_exists(SAVE_PATH):
        print("No save file found. Starting fresh.")
        return false # Do nothing if there's no save.

    # 2. Open the file for reading.
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not file:
        print("Error: Could not open save file for reading.")
        return false
        
    # 3. Read the file content and parse it from JSON.
    var content = file.get_as_text()
    var save_data = JSON.parse_string(content)
    file.close()

    # 4. Check for parsing errors or empty data.
    if not save_data:
        print("Error: Could not parse save data.")
        return false

    # 5. Restore the game state from the loaded data.
    # Use .get() with a default value for safety in case a key is missing.
    research_points = save_data.get("research_points", 0.0)
    owned_generators = save_data.get("owned_generators", {}) # Start with empty dict if missing
    purchased_upgrades = save_data.get("purchased_upgrades", {})
    var last_save_time = save_data.get("last_save_time", 0)
    
    if last_save_time > 0:
        var current_time = Time.get_unix_time_from_system()
        var time_offline_seconds = current_time - last_save_time
        
        # Prevent huge numbers if system clock is wrong
        time_offline_seconds = max(0, time_offline_seconds) 
        
        # We must calculate RPS based on the generators we just loaded
        var rps = calculate_total_rps()
        var rp_earned_offline = rps * time_offline_seconds
        
        if rp_earned_offline > 0:
            research_points += rp_earned_offline
            print("DEBUG: GameManager is about to emit signal.")
            emit_signal.call_deferred("offline_progress_calculated", time_offline_seconds, rp_earned_offline)
            # In the next step, we'll show a popup here instead of printing.
            
    print("Game loaded successfully.")
    return true

func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
        save_game()
        
func buy_upgrade(upgrade_id: String):
    var upg_data: UpgradeData = _upgrade_data_map.get(upgrade_id)
    if not upg_data: return
    
    # Check if already purchased or can't afford
    if purchased_upgrades.has(upgrade_id) or research_points < upg_data.cost:
        return

    research_points -= upg_data.cost
    purchased_upgrades[upgrade_id] = true
    print("Purchased upgrade: ", upgrade_id)
