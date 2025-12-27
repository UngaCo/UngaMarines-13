/obj/machinery/barsign
	name = "bar sign"
	desc = "A bar sign which has not been initialized, somehow. Complain at a coder!"
	icon = 'icons/obj/structures/barsigns.dmi'
	icon_state = "off"
	/// Selected barsign being used
	var/datum/barsign/chosen_sign

/obj/machinery/barsign/Initialize(mapload)
	. = ..()

	switch(dir)
		if(NORTH)
			pixel_y = 32
		if(SOUTH)
			pixel_y = -32
		if(EAST)
			pixel_x = 30
		if(WEST)
			pixel_x = -30

	if(!chosen_sign)
		var/random_sign = pick(subtypesof(/datum/barsign))
		chosen_sign = new random_sign
	update_appearance()

/obj/machinery/barsign/update_name()
	. = ..()
	name = chosen_sign.name

/obj/machinery/barsign/update_desc()
	. = ..()
	desc = chosen_sign.desc

/obj/machinery/barsign/update_icon_state()
	if(!(machine_stat & BROKEN) && (!(machine_stat & NOPOWER) || machine_stat & EMPED) && chosen_sign && chosen_sign.icon_state)
		icon_state = chosen_sign.icon_state
	else
		icon_state = "off"

	return ..()

/obj/machinery/barsign/update_overlays()
	. = ..()

	if(((machine_stat & NOPOWER) && !(machine_stat & EMPED)) || (machine_stat & BROKEN))
		return

	if(chosen_sign && chosen_sign.light_mask)
		. += emissive_appearance(icon, "[chosen_sign.icon_state]-light-mask", src)

/obj/machinery/barsign/update_appearance(updates=ALL)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		set_light(0)
		return
	if(chosen_sign && chosen_sign.neon_color)
		set_light(MINIMUM_USEFUL_LIGHT_RANGE, 0.7, chosen_sign.neon_color)

/datum/barsign
	/// User-visible name of the sign.
	var/name
	/// Icon state associated with this sign
	var/icon_state
	/// Description shown in the sign's examine text.
	var/desc
	/// If a barsign has a light mask for emission effects
	var/light_mask = TRUE
	/// The emission color of the neon light
	var/neon_color

/datum/barsign/signoff
	name = "Off"
	icon_state = "off"
	desc = "This sign doesn't seem to be on."
	light_mask = FALSE

/datum/barsign/maltesefalcon
	name = "Maltese Falcon"
	icon_state = "maltesefalcon"
	desc = "The Maltese Falcon, Space Bar and Grill."
	neon_color = COLOR_BLUE_GRAY

/datum/barsign/thebark
	name = "The Bark"
	icon_state = "thebark"
	desc = "Ian's bar of choice."
	neon_color = COLOR_ORANGE

/datum/barsign/harmbaton
	name = "The Harmbaton"
	icon_state = "theharmbaton"
	desc = "A great dining experience for both security members and assistants."
	neon_color = COLOR_TAN_ORANGE

/datum/barsign/thesingulo
	name = "The Singulo"
	icon_state = "thesingulo"
	desc = "Where people go that'd rather not be called by their name."
	neon_color = COLOR_VIOLET

/datum/barsign/thedrunkcarp
	name = "The Drunk Carp"
	icon_state = "thedrunkcarp"
	desc = "Don't drink and swim."
	neon_color = COLOR_DEEP_MAGENTA

/datum/barsign/scotchservinwillys
	name = "Scotch Servin Willy's"
	icon_state = "scotchservinwillys"
	desc = "Willy sure moved up in the world from clown to bartender."
	neon_color = COLOR_PALE_ORANGE

/datum/barsign/officerbeersky
	name = "Officer Beersky's"
	icon_state = "officerbeersky"
	desc = "Man eat a dong, these drinks are great."
	neon_color = COLOR_EMERALD_GREEN

/datum/barsign/thecavern
	name = "The Cavern"
	icon_state = "thecavern"
	desc = "Fine drinks while listening to some fine tunes."
	neon_color = COLOR_VIBRANT_LIME

/datum/barsign/theouterspess
	name = "The Outer Spess"
	icon_state = "theouterspess"
	desc = "This bar isn't actually located in outer space."
	neon_color = COLOR_CYAN

/datum/barsign/slipperyshots
	name = "Slippery Shots"
	icon_state = "slipperyshots"
	desc = "Slippery slope to drunkenness with our shots!"
	neon_color = COLOR_MOSSY_GREEN

/datum/barsign/thegreytide
	name = "The Grey Tide"
	icon_state = "thegreytide"
	desc = "Abandon your toolboxing ways and enjoy a lazy beer!"
	neon_color = COLOR_CYAN

/datum/barsign/honkednloaded
	name = "Honked 'n' Loaded"
	icon_state = "honkednloaded"
	desc = "Honk."
	neon_color = COLOR_SOFT_RED

/datum/barsign/thenest
	name = "The Nest"
	icon_state = "thenest"
	desc = "A good place to retire for a drink after a long night of crime fighting."
	neon_color = COLOR_DUSKY_BLUE

/datum/barsign/thecoderbus
	name = "The Coderbus"
	icon_state = "thecoderbus"
	desc = "A very controversial bar known for its wide variety of constantly-changing drinks."
	neon_color = COLOR_WHITE

/datum/barsign/theadminbus
	name = "The Adminbus"
	icon_state = "theadminbus"
	desc = "An establishment visited mainly by space-judges. It isn't bombed nearly as much as court hearings."
	neon_color = COLOR_WHITE

/datum/barsign/oldcockinn
	name = "The Old Cock Inn"
	icon_state = "oldcockinn"
	desc = "Something about this sign fills you with despair."
	neon_color = COLOR_LOBBY_RED

/datum/barsign/thewretchedhive
	name = "The Wretched Hive"
	icon_state = "thewretchedhive"
	desc = "Legally obligated to instruct you to check your drinks for acid before consumption."
	neon_color = COLOR_LIME

/datum/barsign/robustacafe
	name = "The Robusta Cafe"
	icon_state = "robustacafe"
	desc = "Holder of the 'Most Lethal Barfights' record 5 years uncontested."
	neon_color = COLOR_RED_GRAY

/datum/barsign/emergencyrumparty
	name = "The Emergency Rum Party"
	icon_state = "emergencyrumparty"
	desc = "Recently relicensed after a long closure."
	neon_color = COLOR_RED

/datum/barsign/combocafe
	name = "The Combo Cafe"
	icon_state = "combocafe"
	desc = "Renowned system-wide for their utterly uncreative drink combinations."
	neon_color = COLOR_LIME

/datum/barsign/vladssaladbar
	name = "Vlad's Salad Bar"
	icon_state = "vladssaladbar"
	desc = "Under new management. Vlad was always a bit too trigger happy with that shotgun."
	neon_color = COLOR_DEEP_MOSS_GREEN

/datum/barsign/theshaken
	name = "The Shaken"
	icon_state = "theshaken"
	desc = "This establishment does not serve stirred drinks."
	neon_color = COLOR_VERY_SOFT_YELLOW

/datum/barsign/thealenath
	name = "The Ale' Nath"
	icon_state = "thealenath"
	desc = "All right, buddy. I think you've had EI NATH. Time to get a cab."
	neon_color = COLOR_RED

/datum/barsign/thenet
	name = "The Net"
	icon_state = "thenet"
	desc = "You just seem to get caught up in it for hours."
	neon_color = COLOR_GREEN

/datum/barsign/maidcafe
	name = "Maid Cafe"
	icon_state = "maidcafe"
	desc = "Welcome back, master!"
	neon_color = COLOR_MOSTLY_PURE_PINK

/datum/barsign/thelightbulb
	name = "The Lightbulb"
	icon_state = "thelightbulb"
	desc = "A cafe popular among moths and moffs. Once shut down for a week after the bartender used mothballs to protect her spare uniforms."
	neon_color = COLOR_VERY_SOFT_YELLOW

/datum/barsign/orangejuice
	name = "Oranges' Juicery"
	icon_state = "orangejuice"
	desc = "For those who wish to be optimally tactful to the non-alcoholic population."
	neon_color = COLOR_ORANGE

/datum/barsign/neon_flamingo
	name = "Neon Flamingo"
	icon_state = "neon-flamingo"
	desc = "A bus for all but the flamboyantly challenged."
	neon_color = COLOR_PINK

/obj/machinery/barsign/thedrunkcarp
	chosen_sign = new /datum/barsign/thedrunkcarp
