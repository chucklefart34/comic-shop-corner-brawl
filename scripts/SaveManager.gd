extends Node
 
const SAVE_PATH = "user://savegame.json"
 
var data = {
	"owned_heroes": [],
	"deck": [],
	"currency": 0
}
 
func _ready():
	load_game()
 
# -------------------------
# SAVE / LOAD
# -------------------------
# SaveManager.gd

var testing_mode := false # flip to false before shipping/building for real

func save_game():
	if testing_mode:
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Save failed")
		return
	file.store_string(JSON.stringify(data))
	file.close()
 
func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save found, creating new one")
		save_game()
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if parsed == null:
		print("Save corrupted, resetting")
		return
	data = parsed
	# -------------------------
	# SAFE MIGRATION (IMPORTANT)
	# -------------------------
	if not data.has("owned_heroes"):
		data["owned_heroes"] = []
	if not data.has("deck"):
		data["deck"] = []
	if not data.has("currency"):
		data["currency"] = 0
	RunData.deck = data.deck
	save_game()
 
# -------------------------
# RESET
# -------------------------
func reset_game():
	data = {
		"owned_heroes": [],
		"deck": [],
		"currency": 0,
	}
	save_game()
 
# -------------------------
# HERO STORAGE
# -------------------------
func add_hero(hero_id: String):
	data["owned_heroes"].append(hero_id)
	save_game()
 
# -------------------------
# CURRENCY / TOKENS
# -------------------------
func add_currency(amount: int):
	data["currency"] += amount
	save_game()
 
func can_afford(amount: int) -> bool:
	return data["currency"] >= amount
 
func spend_currency(amount: int) -> bool:
	if not can_afford(amount):
		return false
	data["currency"] -= amount
	save_game()
	return true
 
# -------------------------
# DECK SYSTEM
# -------------------------
const MAX_DECK_SIZE := 10
 
func add_to_deck(hero_id: String) -> bool:
	if hero_id in data["deck"]:
		return false
	if data["deck"].size() >= MAX_DECK_SIZE:
		return false
	data["deck"].append(hero_id)
	save_game()
	return true
 
func remove_from_deck(hero_id: String):
	data["deck"].erase(hero_id)
	save_game()
 
func hero_in_deck(hero_id: String) -> bool:
	return hero_id in data["deck"]
	
	
# -------------------------
# DUPLICATE UPGRADES
# -------------------------
const STAR_THRESHOLDS := [10, 50, 100, 300, 500, 750, 1000, 5000, 10000]
const ATTACK_BONUS_PER_STAR := 5  # each star adds +2 to attack rolls

func get_hero_copies(hero_id: String) -> int:
	var count := 0
	for id in data["owned_heroes"]:
		if id == hero_id:
			count += 1
	return count

func get_hero_star_level(hero_id: String) -> int:
	var copies = get_hero_copies(hero_id)
	var stars := 0
	for threshold in STAR_THRESHOLDS:
		if copies >= threshold:
			stars += 1
		else:
			break
	return stars

func get_hero_attack_bonus(hero_id: String) -> int:
	return get_hero_star_level(hero_id) * ATTACK_BONUS_PER_STAR
	
	
