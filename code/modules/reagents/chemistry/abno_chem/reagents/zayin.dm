
// Chems from Zayin Abnormalities

// Bald is Awesome - /mob/living/simple_animal/hostile/abnormality/bald
/datum/reagent/abnormality/bald
	name = "Essence of Baldness"
	description = "Some weird-looking juice..."
	color = "#ffffff"
	special_properties = list("substance may alter subject physiology")
	sanity_restore = 1

/datum/reagent/abnormality/bald/on_mob_metabolize(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/balder = L
		if(balder.hairstyle != "Bald")
			balder.hairstyle = "Bald"
			balder.update_hair()
	return ..()

// Bottle of Tears - /mob/living/simple_animal/hostile/abnormality/bottle
/datum/reagent/abnormality/bottle
	name = "Crumbs"
	description = "A small pile of slightly soggy crumbs."
	reagent_state = SOLID
	color = "#ad8978"
	health_restore = 2
	stat_changes = list(-4, -4, -4, -4)

// Fairy Festival - /mob/living/simple_animal/hostile/abnormality/fairy_festival
/datum/reagent/abnormality/fairy_festival
	name = "Nectar of an Unknown Flower"
	description = "The fairies got this for you..."
	color = "#e4d0b2"
	health_restore = 2
	damage_mods = list(1.2, 1, 1, 1)

// One Sin - /mob/living/simple_animal/hostile/abnormality/onesin
/datum/reagent/abnormality/onesin
	name = "Holy Light"
	description = "It\'s calming, even if you can\'t quite look at it straight."
	color = "#eff16d"
	sanity_restore = -2
	special_properties = list("may alter sanity of those near the subject")

/datum/reagent/abnormality/onesin/on_mob_life(mob/living/L)
	for(var/mob/living/carbon/human/nearby in livinginview(9, get_turf(L)))
		nearby.adjustSanityLoss(-1)
	return ..()

// Quiet Day - /mob/living/simple_animal/hostile/abnormality/quiet_day
/datum/reagent/abnormality/quiet_day
	name = "Liquid Nostalgia"
	description = "A deep, dark-colored goo. Looking at it, you're almost convinced you see something more."
	color = "#110320"
	sanity_restore = -2
	stat_changes = list(2, 2, 2, 2) // Sort of reverse bottle. Stat gain for ongoing sanity loss. Not a huge stat gain since it's split into four, but something.

//Audiovisual stuff
/mob/living/simple_animal/hostile/abnormality/quiet_day/Initialize()
	. = ..()
	soundloop = new(list(src), TRUE)

/mob/living/simple_animal/hostile/abnormality/quiet_day/Destroy()
	QDEL_NULL(soundloop)
	..()

// Sleeping Beauty - /mob/living/simple_animal/hostile/abnormality/sleeping
/datum/reagent/abnormality/sleeping
	name = "Puffy clouds"
	description = "Looks like condensed clouds."
	color = "#759ad1"
	special_properties = list("substance may cause drowsiness")
	sanity_restore = 4 // Literally the only context in which this is safe to use is if you're perfectly safe or under attack from a solely white damage abnormality.

/datum/reagent/abnormality/sleeping/on_mob_metabolize(mob/living/L)
	if(!iscarbon(L))
		return
	var/mob/living/carbon/C = L
	to_chat(C, "<span class='warning'>You feel tired...</span>")
	C.blur_eyes(5)
	addtimer(CALLBACK (C, .mob/living/proc/AdjustSleeping, 20), 2 SECONDS)
	return ..()

/datum/reagent/abnormality/sleeping/on_mob_life(mob/living/L)
	if(!iscarbon(L))
		return
	var/mob/living/carbon/C = L
	addtimer(CALLBACK (C, .mob/living/proc/AdjustSleeping, 20), 2 SECONDS)
	return ..()

// We Can Change Anything - /mob/living/simple_animal/hostile/abnormality/we_can_change_anything
/datum/reagent/abnormality/we_can_change_anything
	name = "Dubious Red Goo"
	description = "You have a strong suspicion about where this came from, but..."
	color = "#8f1108"
	health_restore = -1
	damage_mods = list(0.9, 1, 1, 1)

// Wellcheers - /mob/living/simple_animal/hostile/abnormality/wellcheers
/datum/reagent/abnormality/wellcheers_zero
	name = "Wellcheers Zero"
	description = "Low-impact soda for the high-energy lifestyle."
	special_properties = list("substance may have erratic effects on subject's physical and mental state")
	color = "#b2e0c0"

/datum/reagent/abnormality/wellcheers_zero/on_mob_life(mob/living/L)
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	H.adjustBruteLoss(rand(-2, 3) * REAGENTS_EFFECT_MULTIPLIER)
	H.adjustSanityLoss(rand(-2, 3) * REAGENTS_EFFECT_MULTIPLIER)
	return ..()

// Sunset Traveler - /mob/living/simple_animal/hostile/abnormality/sunset_traveller
/datum/reagent/abnormality/sunset_traveller
	name = "Leisure"
	description = "Feels warm to the touch... perhaps it's time to take a break."
	color = "#ff9e2f"
	health_restore = 3 // Slows you and heals you
	special_properties = list("subject was slowed by 10%")

/datum/reagent/abnormality/sunset_traveller/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/sunset_traveller)

/datum/reagent/abnormality/sunset_traveller/on_mob_end_metabolize(mob/living/L)
	. = ..()
	L.remove_movespeed_modifier(/datum/movespeed_modifier/sunset_traveller)

/datum/movespeed_modifier/sunset_traveller
	multiplicative_slowdown = 1.1

// Pile of Mail - /mob/living/simple_animal/hostile/abnormality/mailpile
/datum/reagent/abnormality/mailpile
	name = "Alphabet Soup"
	description = "A bunch of letters floating around in a yellow-ish soup."
	color = "#ceab38"
	special_properties = list("subject moved 10% faster", "subject grew tired")

/datum/reagent/abnormality/mailpile/on_mob_life(mob/living/L)
	. = ..()
	L.apply_damage(4, STAMINA)

/datum/reagent/abnormality/mailpile/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/mailpile)

/datum/reagent/abnormality/mailpile/on_mob_end_metabolize(mob/living/L)
	. = ..()
	L.remove_movespeed_modifier(/datum/movespeed_modifier/mailpile)

/datum/movespeed_modifier/mailpile
	multiplicative_slowdown = 0.9

// Hammer of Light - /mob/living/simple_animal/hostile/abnormality/hammer_light
/datum/reagent/abnormality/hammer_light
	name = "Righteousness"
	description = "A pale, almost holy, light in liquid form."
	color = "#ceab38"
	damage_mods = list(1, 1, 1, 0.9)
