
/// Chems that are produced via mixing abnormality chems or otherwise.

/datum/reagent/abnormality/abno_flesh
	name = "Abnormality Flesh"
	description = "What... is this?"
	color = "#4b0d3dff"
	taste_description = "disgusting"
	taste_mult = 10
	health_restore = -10

/datum/reagent/abnormality/reminiscence
	name = "Reminiscence"
	description = "Reminds you of those good times..."
	color = "#9fb1a6"
	taste_description = "sour"
	taste_mult = 5
	glass_name = "glass of yesterday"
	glass_desc = "It wasn't there before."
	damage_mods = list(0.5, 1, 0.5, 0.5) // Take 20 White damage per 0.2 units, with 2 second duration each unit.
	special_properties = list("subject took heavy white damage over the duration")

/datum/reagent/abnormality/reminiscence/on_mob_life(mob/living/M)
	. = ..()
	M.apply_damage(20*REM, WHITE_DAMAGE, null, M.run_armor_check(null, WHITE_DAMAGE))
	if(prob(8))
		to_chat(M, "<span class='deadsay>Why couldn't it have been yesterday...</span>")
