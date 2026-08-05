extends Node
var player_hp := 20
var player_max_hp := 20
var battles_won := 0
var fight_index :=0 
var current_fight := 1
var deck: Array
var current_hand = []
var hero_upgrades = {}
var tokens := 0

func start_new_run():
	player_max_hp = 20 + SaveManager.get_skill_hp_bonus()
	player_hp = player_max_hp
	fight_index = 0
	current_fight = 1
	current_hand.clear()
	hero_upgrades.clear()
	deck = SaveManager.data["deck"].duplicate()
	
func reset():
	player_max_hp = 20 + SaveManager.get_skill_hp_bonus()
	player_hp = player_max_hp
	tokens = 0
	current_fight = 1
	current_hand.clear()
	hero_upgrades.clear()
	deck = SaveManager.data["deck"].duplicate()

func ensure_deck_loaded():
	deck = SaveManager.data["deck"].duplicate()
