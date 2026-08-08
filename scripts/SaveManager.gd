extends Node

const SAVE_PATH = "user://savegame.json"
const BACKUP_PATH = "user://savegame_backup.json"

var data = {}

var testing_mode := false 


func _ready():
	load_game()


func _notification(what):
	
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()


# -------------------------
# DEFAULTS
# -------------------------
func get_default_data() -> Dictionary:
	return {
		"owned_heroes": STARTING_HEROES.duplicate(),
		"deck": STARTING_HEROES.duplicate(),
		"currency": 0,
		"skills": {},
		"skill_points": 0,
		"rebirth_count": 0,
		"token_multiplier": 1.0
	}


# -------------------------
# SAVE (atomic write + backup)
# -------------------------
func save_game():
	if testing_mode:
		return

	
	if FileAccess.file_exists(SAVE_PATH):
		var current_bytes = FileAccess.get_file_as_bytes(SAVE_PATH)
		var backup_file = FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
		if backup_file:
			backup_file.store_buffer(current_bytes)
			backup_file.close()

	
	var tmp_path = SAVE_PATH + ".tmp"
	var file = FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		print("Save failed: couldn't open temp file")
		return
	file.store_string(JSON.stringify(data))
	file.close()

	var dir = DirAccess.open("user://")
	if dir:
		if dir.file_exists(SAVE_PATH):
			dir.remove(SAVE_PATH)
		dir.rename(tmp_path, SAVE_PATH)
	else:
		print("Save failed: couldn't access user:// directory")


# -------------------------
# LOAD (falls back to backup, then to fresh save)
# -------------------------
func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save found, creating new one")
		reset_game()
		return

	var loaded = _try_load_file(SAVE_PATH)

	if loaded == null:
		print("Primary save unreadable, trying backup...")
		loaded = _try_load_file(BACKUP_PATH)

	if loaded == null:
		print("No valid save could be loaded, starting fresh")
		reset_game()
		return

	data = loaded
	_migrate_data()


func _try_load_file(path: String):
	if not FileAccess.file_exists(path):
		return null
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var content = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
	return parsed



func _migrate_data():
	var defaults = get_default_data()
	for key in defaults.keys():
		if not data.has(key):
			data[key] = defaults[key]


# -------------------------
# RESET
# -------------------------
func reset_game():
	data = get_default_data()
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
	data["currency"] += amount * data["token_multiplier"]
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
const MIN_DECK_SIZE := 5

func add_to_deck(hero_id: String) -> bool:
	if hero_id in data["deck"]:
		return false
	if data["deck"].size() >= MAX_DECK_SIZE:
		return false
	data["deck"].append(hero_id)
	save_game()
	return true

func remove_from_deck(hero_id: String) -> bool:
	if data["deck"].size() <= MIN_DECK_SIZE:
		return false
	data["deck"].erase(hero_id)
	save_game()
	return true

func hero_in_deck(hero_id: String) -> bool:
	return hero_id in data["deck"]


# -------------------------
# DUPLICATE UPGRADES
# -------------------------
const STAR_THRESHOLDS := [10, 50, 100, 300, 500, 750, 1000, 5000, 10000]
const ATTACK_BONUS_PER_STAR := 5

func get_hero_copies(hero_id: String) -> int:
	var count := 0
	for id in data["owned_heroes"]:
		if id == hero_id:
			count += 1
	return count

func get_hero_star_level(hero_id: String) -> int:
	var copies = get_hero_copies(hero_id)
	var reduction = get_skill_duplicate_bonus()
	var stars := 0
	for threshold in STAR_THRESHOLDS:
		var adjusted_threshold = max(int(threshold * (1.0 - reduction)), 1)
		if copies >= adjusted_threshold:
			stars += 1
		else:
			break
	return stars
	
func get_hero_attack_bonus(hero_id: String) -> int:
	return get_hero_star_level(hero_id) * ATTACK_BONUS_PER_STAR


# -------------------------
# REBIRTH
# -------------------------
const STARTING_HEROES := ["Hero9", "Hero4", "Hero2", "Hero14", "Hero8"]

func get_rebirth_threshold() -> int:
	return int(500 * (2 * (data.rebirth_count + 1)))

func can_rebirth() -> bool:
	return data["currency"] >= get_rebirth_threshold()

func do_rebirth() -> bool:
	if not can_rebirth():
		return false
	data["rebirth_count"] += 1
	data["token_multiplier"] *= 1.5
	data["owned_heroes"] = STARTING_HEROES.duplicate()
	data["deck"] = STARTING_HEROES.duplicate()
	data["currency"] = 0
	data["skill_points"] = data.get("skill_points", 0) + 1
	save_game()
	return true


func multiply_currency(factor: float):
	data["currency"] *= factor
	save_game()

# -------------------------
# SKILL WEB
# -------------------------
const SKILL_BRANCHES = ["attack", "hp", "tokens", "luck", "regen", "crit", "duplicate", "upgrade_power"]
const SKILL_MAX_LEVEL = 5

func get_skill_level(branch: String) -> int:
	if not data.has("skills"):
		data["skills"] = {}
	return data["skills"].get(branch, 0)

func get_skill_points() -> int:
	return data.get("skill_points", 0)

func can_buy_skill(branch: String) -> bool:
	var level = get_skill_level(branch)
	return level < SKILL_MAX_LEVEL and get_skill_points() > 0

func buy_skill(branch: String) -> bool:
	if not can_buy_skill(branch):
		return false
	if not data.has("skills"):
		data["skills"] = {}
	data["skills"][branch] = get_skill_level(branch) + 1
	data["skill_points"] -= 1
	save_game()
	return true
func get_skill_regen_bonus() -> int:
	return get_skill_level("regen")

func get_skill_crit_chance() -> float:
	return get_skill_level("crit") * 0.05  # 5% per tier, max 25%

func get_skill_duplicate_bonus() -> float:
	return get_skill_level("duplicate") * 0.1  # 10% fewer copies needed per tier, max 50%

func get_skill_upgrade_power_bonus() -> int:
	return get_skill_level("upgrade_power")
	
func get_skill_attack_bonus() -> int:
	return get_skill_level("attack")

func get_skill_hp_bonus() -> int:
	return get_skill_level("hp") * 5

func get_skill_token_bonus() -> float:
	return get_skill_level("tokens") * 0.1

func get_skill_luck_bonus() -> int:
	return get_skill_level("luck")
