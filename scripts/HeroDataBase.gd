extends Node



var heroes = {
	"Hero1": {
		"display_name": "MoonWarrior",
		"rarity": "Common",
		"attack_a": [3, 3, 3, 3],
		"attack_b": [13],
		"attack_bonus": 0
	},
	"Hero2": {
		"display_name": "Gnatman",
		"rarity": "Common",
		"attack_a": [2, 3, 4, 2],
		"attack_b": [12],
		"attack_bonus": 0
	},
	"Hero3": {
		"display_name": "Rascal",
		"rarity": "Legendary",
		"attack_a": [16, 16, 16, 16],
		"attack_b": [62],
		"attack_bonus": 0
	},
	"Hero4": {
		"display_name": "Duperman",
		"rarity": "Common",
		"attack_a": [2, 2, 3, 2],
		"attack_b": [11],
		"attack_bonus": 0
	},
	"Hero5": {
		"display_name": "Boosting Silver",
		"rarity": "Epic",
		"attack_a": [10, 10, 10, 5],
		"attack_b": [40],
		"attack_bonus": 0
	},
	"Hero6": {
		"display_name": "Duperboy Prime",
		"rarity": "Rare",
		"attack_a": [6, 6, 6, 3],
		"attack_b": [24],
		"attack_bonus": 0
	},
	"Hero7": {
		"display_name": "Martial Manhunt", 
		"rarity": "Common",
		"attack_a": [3, 3, 4, 3],
		"attack_b": [13],
		"attack_bonus": 0
	},
	"Hero8": {
		"display_name": "The Speed", 
		"rarity": "Common",
		"attack_a": [2, 2, 2, 2],
		"attack_b": [11],
		"attack_bonus": 0
	},
	"Hero9": {
		"display_name": "Thoughtful Woman", 
		"rarity": "Common",
		"attack_a": [3, 4, 4, 2],
		"attack_b": [12],
		"attack_bonus": 0
	},
	"Hero10": {
		"display_name": "Creature Man", 
		"rarity": "Uncommon",
		"attack_a": [4, 4, 4, 3],
		"attack_b": [16],
		"attack_bonus": 0
	},
	"Hero11": {
		"display_name": "Cardinal Hood", 
		"rarity": "Common",
		"attack_a": [3, 3, 3, 3],
		"attack_b": [13],
		"attack_bonus": 0
	},
	"Hero12": {
		"display_name": "Ghostman", 
		"rarity": "Rare",
		"attack_a": [5, 6, 7, 6],
		"attack_b": [26],
		"attack_bonus": 0
	},
	"Hero13": {
		"display_name": "Robin steel",
		"rarity": "Legendary",
		"attack_a": [15, 16, 17, 15],
		"attack_b": [64],
		"attack_bonus": 0
	},
	"Hero14": {
		"display_name": "arachnaboy", 
		"rarity": "Rare",
		"attack_a": [6, 6, 6, 5],
		"attack_b": [23],
		"attack_bonus": 0
	},
	"Hero15": {
		"display_name": "insivible", 
		"rarity": "Epic",
		"attack_a": [9, 10, 11, 10],
		"attack_b": [42],
		"attack_bonus": 0
	},
	"Hero16": {
		"display_name": "Green Bug", 
		"rarity": "Common",
		"attack_a": [3, 3, 3, 3],
		"attack_b": [13],
		"attack_bonus": 0
	},
	"Hero17": {
		"display_name": "SupraMan",
		"rarity": "Common",
		"attack_a": [3, 4, 4, 2],
		"attack_b": [12],
		"attack_bonus": 0
	},
	"Hero18": {
		"display_name": "Big Green Genius", 
		"rarity": "Common",
		"attack_a": [2, 3, 4, 4],
		"attack_b": [13],
		"attack_bonus": 0
	},
	"Hero19": {
		"display_name": "ThunderBoy", 
		"rarity": "Common",
		"attack_a": [2, 3, 3, 3],
		"attack_b": [14],
		"attack_bonus": 0
	},
	"Hero20": {
		"display_name": "Smart Rich Suit", 
		"rarity": "Common",
		"attack_a": [3, 3, 4, 2],
		"attack_b": [12],
		"attack_bonus": 0
	},
	"Hero21": {
		"display_name": "Spider Agent", 
		"rarity": "Common",
		"attack_a": [2, 2, 3, 2],
		"attack_b": [13],
		"attack_bonus": 0
	},
	"Hero22": {
		"display_name": "Target",
		"rarity": "Common",
		"attack_a": [3, 3, 3, 2],
		"attack_b": [13],
		"attack_bonus": 0
	},
	"Hero23": {
		"display_name": "Olive Bowson", 
		"rarity": "Common",
		"attack_a": [2, 3, 4, 2],
		"attack_b": [12],
		"attack_bonus": 0
	},
	"Hero24": {
		"display_name": "General Nation",
		"rarity": "Common",
		"attack_a": [3, 4, 4, 2],
		"attack_b": [11],
		"attack_bonus": 0
	},
	"Hero25": {
		"display_name": "Half-Robot", 
		"rarity": "Common",
		"attack_a": [3, 3, 3, 2],
		"attack_b": [13],
		"attack_bonus": 0
	},
	"Hero26": {
		"display_name": "Green Ring", 
		"rarity": "Common",
		"attack_a": [3, 3, 4, 2],
		"attack_b": [12],
		"attack_bonus": 0
	},
	"Hero27": {
		"display_name": "WaterKing", 
		"rarity": "Common",
		"attack_a": [2, 3, 3, 2],
		"attack_b": [14],
		"attack_bonus": 0
	},
	"Hero28": {
		"display_name": "Hondis Integrity", 
		"rarity": "Legendary",
		"attack_a": [16, 16, 16, 15],
		"attack_b": [60],
		"attack_bonus": 0
	},
	"Hero29": {
		"display_name": "Toying Carrol", 
		"rarity": "Epic",
		"attack_a": [10, 10, 10, 7],
		"attack_b": [38],
		"attack_bonus": 0
	},
	"Hero30": {
		"display_name": "Hondis seevic", 
		"rarity": "Rare",
		"attack_a": [5, 6, 7, 4],
		"attack_b": [25],
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
