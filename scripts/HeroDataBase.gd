extends Node

var heroes = {
	"Hero1": {
		"display_name": "MoonWarrior",
		"rarity": "Common",
		"attack_a": [6],
		"attack_b": [3, 9],
		"attack_bonus": 0
	},

	"Hero2": {
		"display_name": "Gnatman",
		"rarity": "Common",
		"attack_a": [6],
		"attack_b": [1, 8],
		"attack_bonus": 0
	},

	"Hero3": {
		"display_name": "Rascal",
		"rarity": "Legendary",
		"attack_a": [20, 50],
		"attack_b": [3, 150],
		"attack_bonus": 0
	},
	"Hero4": {
		"display_name": "Duperman",
		"rarity": "Common",
		"attack_a": [2],
		"attack_b": [4, 10],
		"attack_bonus": 0
	},

	"Hero5": {
		"display_name": "Boosting Silver",
		"rarity": "Epic",
		"attack_a": [15, 30],
		"attack_b": [10, 60],
		"attack_bonus": 0
	},

	"Hero6": {
		"display_name": "Duperboy Prime",
		"rarity": "Rare",
		"attack_a": [10, 20],
		"attack_b": [3, 30],
		"attack_bonus": 0
	},
	"Hero7": {
		"display_name": "Martial Manhunt",
		"rarity": "Common",
		"attack_a": [2, 4],
		"attack_b": [4, 10],
		"attack_bonus": 0
	},

	"Hero8": {
		"display_name": "The Speed",
		"rarity": "Common",
		"attack_a": [1, 4],
		"attack_b": [1, 10],
		"attack_bonus": 0
	},

	"Hero9": {
		"display_name": "Thoughtful Woman",
		"rarity": "Common",
		"attack_a": [5],
		"attack_b": [1, 20],
		"attack_bonus": 0
	},
	"Hero10": {
		"display_name": "Creature Man",
		"rarity": "Uncommon",
		"attack_a": [9],
		"attack_b": [4, 15],
		"attack_bonus": 0
	},

	"Hero11": {
		"display_name": "Cardinal Hood",
		"rarity": "Common",
		"attack_a": [7],
		"attack_b": [5, 10],
		"attack_bonus": 0
	},

	"Hero12": {
		"display_name": "Ghostman",
		"rarity": "Rare",
		"attack_a": [3],
		"attack_b": [3, 30],
		"attack_bonus": 0
	},
	
	"Hero13": {
		"display_name": "Robin steel",
		"rarity": "Legendary",
		"attack_a": [50],
		"attack_b": [1, 75],
		"attack_bonus": 0
	},
	
	
}

func _ready():
	for hero_id in heroes.keys():
		var path = "res://Portraits/%s.png" % hero_id
		if ResourceLoader.exists(path):
			heroes[hero_id]["portrait"] = load(path)
		else:
			heroes[hero_id]["portrait"] = null
