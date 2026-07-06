extends Node

# ----------------------------
# PLAYER
# ----------------------------

var player_hp := 20
var player_max_hp := 20

# ----------------------------
# RUN
# ----------------------------

var battles_won := 0
var fight_index :=0 
var current_fight := 1

# ----------------------------
# DECK
# ----------------------------

var deck = [
	"Hero1",
	"Hero2",
	"Hero3",
	"Hero4",
	"Hero5",
	"Hero6",
	"Hero7",
	"Hero8",
	"Hero9",
	"Hero10"
]

# The 3 heroes drawn this turn
var current_hand = []

# ----------------------------
# HERO UPGRADES
# ----------------------------

# Example:
# Hero1:
#    attack_a +1 die
# Hero5:
#    attack_b +2 sides
#
# We'll fill this in later.
var hero_upgrades = {}

# ----------------------------
# CURRENCY
# ----------------------------

var tokens := 0

# ----------------------------
# RESET RUN
# ----------------------------

func start_new_run():

	player_hp = player_max_hp

	battles_won = 0
	current_fight = 1

	current_hand.clear()

	hero_upgrades.clear()

	deck = [
		"Hero1",
		"Hero2",
		"Hero3",
		"Hero4",
		"Hero5",
		"Hero6",
		"Hero7",
		"Hero8",
		"Hero9",
		"Hero10"
	]
func reset():
	player_hp = 20
	player_max_hp = 20
	battles_won = 0
	fight_index = 0 
	current_fight = 1
