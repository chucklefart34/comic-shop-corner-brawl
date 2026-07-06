extends Node

const SAVE_PATH = "user://savegame.json"

var data = {
	"owned_heroes": [],
	"token": 0
}


func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Failed to open save file")
		return

	file.store_string(JSON.stringify(data))
	file.close()


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save found, using defaults")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(content)

	if parsed == null:
		print("Save file corrupted, resetting")
		return

	data = parsed


func add_hero(hero_id: String):
	if hero_id not in data["owned_heroes"]:
		data["owned_heroes"].append(hero_id)
		save_game()


func add_token(amount: int):
	data["token"] += amount
	save_game()
