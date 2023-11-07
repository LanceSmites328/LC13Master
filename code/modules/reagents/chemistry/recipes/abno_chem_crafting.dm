/// No applicable category
#define AC_CAT_NONE "AC_NONE"
/// Makes PE, gets randomized on round-start
#define AC_CAT_PE "AC_PE"
/// Makes another reagent of any kind.
#define AC_CAT_REAGENT "AC_REAGENT"
/// Makes a more powerful reagent.
#define AC_CAT_REFINE "AC_REFINE"

GLOBAL_LIST_EMPTY(abnormality_chem_recipes)

/datum/ac_recipe
	var/name = "Base Abnormality Chem Recipe"
	var/desc = "Makes nothing."

	var/craft_category = AC_CAT_NONE

	/// Resulting Chems from crafting, ASSOC with type and quantity. Moved to Buffer on creation.
	var/list/chem_result = list() // list(/datum/reagent/consumable/nutriment = 5)
	/// Resulting objects from crafting, ASSOC with type and quantity. Moved to loc on creation.
	var/list/item_result = list() // list(/obj/item/rawpe = 1)

	/// Required abno chems for creation, ASSOC with type and quantity.
	var/list/chem_req = list() // list(/datum/reagent/abnormality/bald = 5)

/datum/ac_recipe/New()
	. = ..()
	GLOB.abnormality_chem_recipes += src

/datum/ac_recipe/proc/Craft(obj/machinery/abnormality_chemstation/chemstation)
	// Check to see if we have enough to even do this.
	for(var/R in chem_req)
		if(!chemstation.reagents.has_reagent(R, chem_req[R]))
			return FALSE
	// Take that amount away.
	for(var/R in chem_req)
		chemstation.reagents.remove_reagent(R, chem_req[R])

	if(LAZYLEN(chem_result))
		chemstation.reagents.add_reagent_list(chem_result)

	for(var/I in item_result)
		if(item_result[I])
			for(var/count = 1 to item_result[I])
				new I(get_turf(chemstation))
		else
			new I(get_turf(chemstation))

	return TRUE

/datum/ac_recipe/pe
	name = "Refined PE \[Simple\]"
	desc = "Creates refined PE."
	craft_category = AC_CAT_PE

	var/pe_amount = 1
	var/req_amount = 3
	var/random_amount = TRUE
	var/threat_list = list(ZAYIN_LEVEL, TETH_LEVEL)

/datum/ac_recipe/pe/New()
	. = ..()
	randomize()

/datum/ac_recipe/pe/proc/randomize()
	if(random_amount)
		req_amount = rand(1, req_amount)

	item_result = list(/obj/item/refinedpe = round(pe_amount * req_amount/2, 1))

	var/list/potential_chems = list()
	for(var/type_path in subtypesof(/mob/living/simple_animal/hostile/abnormality))
		var/mob/living/simple_animal/hostile/abnormality/abno = type_path
		if(!(initial(abno.threat_level) in threat_list))
			continue
		var/datum/reagent/abnormality/abno_chem = initial(abno.chem_type)
		if(!abno_chem)
			continue
		potential_chems.Add(abno_chem)

	if(!LAZYLEN(potential_chems))
		return

	var/chem_amount = 5
	if(LAZYLEN(potential_chems) < req_amount)
		while(req_amount > LAZYLEN(potential_chems))
			req_amount /= 2
			chem_amount += 5

	req_amount = max(round(req_amount, 1), 1)

	for(var/I = 1 to req_amount)
		var/datum/reagent/abnormality/abno_chem = pick(potential_chems)
		potential_chems.Remove(abno_chem)
		chem_req[abno_chem] = chem_amount

	return

/datum/ac_recipe/pe/medium
	name = "Refined PE \[Complex\]"
	pe_amount = 2
	threat_list = list(TETH_LEVEL, HE_LEVEL)

/datum/ac_recipe/pe/hard
	name = "Refined PE \[Complicated\]"
	pe_amount = 5
	threat_list = list(WAW_LEVEL, ALEPH_LEVEL)

/datum/ac_recipe/reagent
	craft_category = AC_CAT_REAGENT

/datum/ac_recipe/reagent/beer
	name = "Abno-Chem Beer Recipe"
	desc = "Makes beer."

	chem_result = list(/datum/reagent/consumable/ethanol/beer = 10)
	chem_req = list(/datum/reagent/abnormality/nutrition = 5)

/datum/ac_recipe/refine
	name = "Refined Recipe"
	desc = "Creates a refined item."
	craft_category = AC_CAT_REFINE

/datum/ac_recipe/refine/gift
	name = " Gift Refinery"
	desc = "Creates N/A's E.G.O. Gift."
	var/mob/living/simple_animal/hostile/abnormality/linked_abno

/datum/ac_recipe/refine/gift/New(mob/living/simple_animal/hostile/abnormality/abno)
	. = ..()
	if(!ispath(abno))
		qdel(src)
		return
	name = "[initial(abno.name)]"+initial(name)
	desc = "Creates [initial(abno.name)]'s E.G.O. Gift."
	linked_abno = abno
	var/req_amount = 3 * initial(abno.chem_yield) * initial(abno.threat_level)
	chem_req = list(initial(abno.chem_type) = req_amount)

/datum/ac_recipe/refine/gift/Craft(obj/machinery/abnormality_chemstation/chemstation)
	. = ..()
	if(!.)
		return
	new /obj/item/ego_gift(get_turf(chemstation), initial(linked_abno.gift_type))

/obj/item/ego_gift
	name = "Appliable E.G.O. Gift"
	desc = "Use in-hand to gain the E.G.O. Gift inside."
	icon = 'icons/obj/mining.dmi'
	icon_state = "capsule"
	var/datum/ego_gifts/result

/obj/item/ego_gift/New(loc, datum/ego_gifts/gift_arg, ...)
	. = ..()
	if(!gift_arg)
		qdel(src)
		return
	result = new gift_arg

/obj/item/ego_gift/attack_self(mob/living/carbon/human/user)
	. = ..()
	if(!istype(user))
		to_chat(user, "<span class='warning'>H-how do you have hands????</span>")
		return
	user.Apply_Gift(result)
	to_chat(user, "<span class='nicegreen'>[src] grants you [result]!</span>")
	qdel(src)
