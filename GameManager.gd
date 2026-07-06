extends Node

var deck: Array = []
var hand: Array = []
var discard: Array = []

func _ready():
	start_run()

func start_run():
	build_deck()
	shuffle_deck()
	draw_cards(5)

func build_deck():
	deck = ["Strike", "Strike", "Strike", "Defend", "Defend"]

func shuffle_deck():
	deck.shuffle()

func draw_cards(amount: int):
	for i in range(amount):
		if deck.is_empty():
			reshuffle_discard_into_deck()

		if deck.is_empty():
			return

		hand.append(deck.pop_back())

	print("Hand:", hand)

func reshuffle_discard_into_deck():
	deck = discard
	discard = []
	shuffle_deck()
