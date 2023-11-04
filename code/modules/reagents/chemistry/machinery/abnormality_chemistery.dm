/// COXSWAIN. WE NEED TO COOK.
#define AC_SCREEN_HOME "ac_home"
#define AC_SCREEN_MIX "ac_mix"
#define AC_SCREEN_CREATE "ac_create"
#define AC_SCREEN_OPTIONS "ac_options"

#define AC_DESTINATION_BUFFER "Buffer"
#define AC_DESTINATION_MIXER "Mixer"
#define AC_DESTINATION_CONTAINER "Container"
#define AC_DESTINATION_DESTROY "Destroy"

/obj/machinery/abnormality_chemstation
	name = "Abno-Chem Mixer"
	desc = "Used to mix chemicals from abnormalities in a variety of new forms."
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/abnormality_chemstation

	/// Held reagents container
	var/obj/item/reagent_containers/RC
	/// Mixer Container
	var/obj/item/reagent_containers/AC_mixer/mixer
	/// Whether separated reagents should be moved back to container or destroyed.
	var/move_not_destroy = TRUE
	/// Move Destination
	var/move_destination = AC_DESTINATION_BUFFER
	/// At the moment there should be 4 screens, listed in the defines
	var/screen = AC_SCREEN_HOME
	/// ASSOC recipe list
	var/list/recipe_list = list(AC_CAT_NONE = list(), AC_CAT_PE = list(), AC_CAT_REAGENT = list(), AC_CAT_REFINE = list())

/obj/machinery/abnormality_chemstation/Initialize()
	. = ..()
	create_reagents(500)
	reagents.flags = NO_REACT
	for(var/datum/ac_recipe/ACR in GLOB.abnormality_chem_recipes)
		LAZYADDASSOC(recipe_list, ACR.craft_category, list(ACR))
		recipe_list[ACR.craft_category][ACR] = FALSE
	mixer = new(src)

/obj/machinery/abnormality_chemstation/Destroy()
	QDEL_NULL(mixer)
	return ..()

/obj/machinery/abnormality_chemstation/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0", I))
		return

	else if(default_deconstruction_crowbar(I))
		return

	if(default_unfasten_wrench(user, I))
		return
	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		. = TRUE // no afterattack
		if(panel_open)
			to_chat(user, "<span class='warning'>You can't use the [src.name] while its panel is opened!</span>")
			return
		var/obj/item/reagent_containers/B = I
		if(!user.transferItemToLoc(B, src))
			return
		replace_container(user, B)
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		updateUsrDialog()
		update_icon()
	else
		return ..()

/obj/machinery/abnormality_chemstation/AltClick(mob/living/user)
	. = ..()
	if(!can_interact(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_container(user)

/obj/machinery/abnormality_chemstation/proc/replace_container(mob/living/user, obj/item/reagent_containers/new_container)
	if(!user)
		return FALSE
	if(RC)
		try_put_in_hand(RC, user)
		RC = null
	if(new_container)
		RC = new_container
	update_icon()
	return TRUE

/obj/machinery/abnormality_chemstation/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AbnoChem", name)
		ui.open()

/obj/machinery/abnormality_chemstation/ui_assets(mob/user) // Might not need this?
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/pills),
		get_asset_datum(/datum/asset/spritesheet/simple/condiments),
	)

/obj/machinery/abnormality_chemstation/ui_data(mob/user)
	. = list()
	.["screen"] = screen
	.["container"] = RC ? 1 : 0
	.["containerCurrentVolume"] = RC ? RC.reagents.total_volume : null
	.["containerMaxVolume"] = RC ? RC.volume : null
	.["move_not_destroy"] = move_not_destroy
	.["move_destination"] = move_destination

	var/container_contents[0]
	if(RC)
		for(var/datum/reagent/R in RC.reagents.reagent_list)
			container_contents.Add(list(list("name" = R.name, "id" = ckey(R.name), "volume" = R.volume))) // list in a list because Byond merges the first list...
	.["containerContents"] = container_contents

	var/buffer_contents[0]
	if(reagents.total_volume)
		for(var/datum/reagent/N in reagents.reagent_list)
			buffer_contents.Add(list(list("name" = N.name, "id" = ckey(N.name), "volume" = N.volume))) // ^
	.["bufferContents"] = buffer_contents

	var/mixer_contents[0]
	if(mixer.reagents.total_volume)
		for(var/datum/reagent/N in mixer.reagents.reagent_list)
			mixer_contents.Add(list(list("name" = N.name, "id" = ckey(N.name), "volume" = N.volume))) // ^
	.["mixerContents"] = mixer_contents

	if(screen == AC_SCREEN_CREATE)
		var/list/recipes = list()
		for(var/datum/ac_recipe/ACR in recipe_list["AC_PE"])
			var/list/reqs = list()
			for(var/R in ACR.chem_req)
				var/datum/reagent/AR = R
				var/vol = ACR.chem_req[AR] ? ACR.chem_req[AR] : 0
				reqs.Add(list(list(
					"name" = initial(AR.name),
					"id" = ckey(initial(AR.name)),
					"volume" = vol,
					"meets_req" = src.reagents.has_reagent(AR, vol) ? COLOR_GREEN : COLOR_RED
					)))
			recipes.Add(list(list("name" = ACR.name, "id" = ACR.name, "desc" = ACR.desc)))
			.["reqs"+ACR.name] = reqs
			.[ACR.name] = recipe_list["AC_PE"][ACR]

		.["recipes"] = recipes


/obj/machinery/abnormality_chemstation/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject")
			replace_container(usr)
			playsound(get_turf(src), 'sound/machines/terminal_select.ogg', 50, TRUE)
			return TRUE

		if("transfer")
			var/amount = text2num(params["amount"])
			if (amount == -1)
				amount = text2num(input("Enter the amount you want to transfer:", name, ""))
			. = action_transfer(usr, GLOB.name2reagent[params["id"]], amount, params["to"], params["from"])
			if(.)
				playsound(get_turf(src), 'sound/machines/terminal_prompt_confirm.ogg', 50, TRUE)
			else
				playsound(get_turf(src), 'sound/machines/terminal_prompt_deny.ogg', 50, TRUE)
			return

		if("create")
			src.say("[params["recipe_type"]]")
			. = action_create(params["recipe_type"])
			if(.)
				playsound(get_turf(src), 'sound/machines/terminal_prompt_confirm.ogg', 50, TRUE)
			else
				playsound(get_turf(src), 'sound/machines/terminal_prompt_deny.ogg', 50, TRUE)
			return

		if("changeScreen")
			screen = params["to_screen"]
			playsound(get_turf(src), 'sound/machines/terminal_select.ogg', 50, TRUE)
			return TRUE

		if("toggleMove")
			switch(move_destination)
				if(AC_DESTINATION_BUFFER)
					move_destination = AC_DESTINATION_MIXER
				if(AC_DESTINATION_MIXER)
					move_destination = AC_DESTINATION_CONTAINER
				if(AC_DESTINATION_CONTAINER)
					move_destination = AC_DESTINATION_DESTROY
				if(AC_DESTINATION_DESTROY)
					move_destination = AC_DESTINATION_BUFFER
			playsound(get_turf(src), 'sound/machines/terminal_select.ogg', 30, TRUE)
			return TRUE

		if("changeShow")
			for(var/datum/ac_recipe/AC in GLOB.abnormality_chem_recipes)
				if(AC.name != params["value"])
					continue
				recipe_list[AC.craft_category][AC] = !recipe_list[AC.craft_category][AC]
				break
			playsound(get_turf(src), 'sound/machines/terminal_select.ogg', 30, TRUE)
			return TRUE


/obj/machinery/abnormality_chemstation/proc/action_transfer(mob/user, reagent, amount, to_container, from_container)
	// Custom amount
	. = FALSE
	if(amount == null || amount <= 0)
		return
	if(to_container == AC_DESTINATION_DESTROY)
		if(from_container == AC_DESTINATION_BUFFER)
			. = reagents.remove_reagent(reagent, amount)
		if(from_container == AC_DESTINATION_MIXER)
			. = mixer.reagents.remove_reagent(reagent, amount)
		if(RC && from_container == AC_DESTINATION_CONTAINER)
			. = RC.reagents.remove_reagent(reagent, amount)
		return

	var/obj/reciever
	var/obj/sender

	switch(to_container)
		if(AC_DESTINATION_BUFFER)
			reciever = src
		if(AC_DESTINATION_MIXER)
			reciever = mixer
		if(AC_DESTINATION_CONTAINER)
			reciever = RC

	switch(from_container)
		if(AC_DESTINATION_BUFFER)
			sender = src
		if(AC_DESTINATION_MIXER)
			sender = mixer
		if(AC_DESTINATION_CONTAINER)
			sender = RC

	if(!reciever || !sender)
		CRASH("NO SENDER OR RECIEVER FOR TRANSFER: R [reciever] S [sender]")

	if(sender == reciever)
		return

	if(sender == RC)
		if(!ispath(reagent, /datum/reagent/abnormality))
			to_chat(user, "<span class='warning'>[src] doesn't accept non-abnormality chemicals!</span>")
			return

	return sender.reagents.trans_id_to(reciever, reagent, amount)

/obj/machinery/abnormality_chemstation/proc/action_create(recipe)
	for(var/datum/ac_recipe/rec in GLOB.abnormality_chem_recipes)
		if(rec.name == recipe)
			return rec.Craft(src)
	// we make new stuff here
	return FALSE


/obj/item/reagent_containers/AC_mixer
	name = "Abno-Chem Internal Mixer"
	desc = "Shouldn't be seeing this >:("
	volume = 100

/obj/item/reagent_containers/glass/beaker/ac_test
	volume = 1000

/obj/item/reagent_containers/glass/beaker/Initialize()
	. = ..()
	for(var/AR in subtypesof(/datum/reagent/abnormality))
		reagents.add_reagent(AR, 10)


#undef AC_SCREEN_HOME
#undef AC_SCREEN_MIX
#undef AC_SCREEN_CREATE
#undef AC_SCREEN_OPTIONS
