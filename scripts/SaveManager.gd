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

func save_game():
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

	save_game()

# -------------------------
# HERO STORAGE
# -------------------------

func add_hero(hero_id: String):
	data["owned_heroes"].append(hero_id)
	save_game()


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
