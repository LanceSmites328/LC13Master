
/// Chems that are produced via mixing abnormality chems.

/datum/reagent/reminiscence
	name = "reminiscence"
	description = "Reminds you of those good times..."
	color = "#9fb1a6"
	taste_description = "sour"
	taste_mult = 5
	glass_name = "glass of yesterday"
	glass_desc = "It wasn't there before."

/datum/reagent/reminiscence/on_mob_life(mob/living/M)
	. = ..()
	M.apply_damage(20, WHITE_DAMAGE, null, M.run_armor_check(null, WHITE_DAMAGE))
	if(prob(8))
		to_chat(M, "<span class='deadsay>Why couldn't it have been yesterday...</span>")
