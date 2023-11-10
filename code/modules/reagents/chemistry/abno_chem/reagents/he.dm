// False Apple - /mob/living/simple_animal/hostile/abnormality/golden_apple
/datum/reagent/abnormality/ambrosia
	name = "Ambrosia"
	description = "A powerful serum extracted from an abnormality."
	color = "#03FCD3"
	taste_description = "apple juice"
	glass_name = "glass of ambrosia"
	glass_desc = "A glass of apple juice."
	metabolization_rate = 3 * REAGENTS_METABOLISM//metabolizes at 24u/minute

/datum/reagent/abnormality/ambrosia/on_mob_add(mob/living/L)
	..()
	if(L.has_status_effect(/datum/status_effect/stacking/golden_sheen))//this fixes a runtime
		return
	L.apply_status_effect(/datum/status_effect/stacking/golden_sheen)
	to_chat(L, "<span class='nicegreen'>Your body glows warmly.</span>")

/datum/reagent/abnormality/ambrosia/on_mob_life(mob/living/L)
	var/datum/status_effect/stacking/golden_sheen/G = L.has_status_effect(/datum/status_effect/stacking/golden_sheen)
	if(prob(10))
		to_chat(L, "<span class='nicegreen'>Your glow shimmers!</span>")
		G.add_stacks(1)
		G.refresh()
	return ..()
