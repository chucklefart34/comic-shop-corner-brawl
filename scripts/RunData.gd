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
	player_hp = 20
	player_max_hp = 20
	battles_won = 0
	fight_index = 0
	current_fight = 1
	current_hand.clear()
	hero_upgrades.clear()
	deck = SaveManager.data["deck"].duplicate()
	
func reset():
	player_hp = 20
	player_max_hp = 20
	tokens = 0
	fight_index = 0
	current_fight = 1
	current_hand.clear()
	hero_upgrades.clear()
	deck = SaveManager.data["deck"].duplicate()
