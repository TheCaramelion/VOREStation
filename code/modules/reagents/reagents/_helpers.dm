/atom/movable/proc/can_be_injected_by(var/atom/injector)
	if(!Adjacent(get_turf(injector)))
		return FALSE
	if(!reagents)
		return FALSE
	if(!reagents.get_free_space())
		return FALSE
	return TRUE

// Helper for anything checking if it can inject a container like a syringe.
/atom/movable/proc/is_injectable_container()
	return is_open_container() || \
		istype(src, /obj/item/reagent_containers/food) || \
		istype(src, /obj/item/slime_extract) || \
		istype(src, /obj/item/clothing/mask/smokable/cigarette) || \
		istype(src, /obj/item/storage/fancy/cigarettes)

/obj/can_be_injected_by(var/atom/injector)
	if(!..())
		return FALSE
	// Then check if this is a type of container that can be injected
	return is_injectable_container()

/mob/living/can_be_injected_by(var/atom/injector)
	return ..() && (can_inject(null, 0, BP_TORSO) || can_inject(null, 0, BP_GROIN))

///Returns a random reagent object, with the option to blacklist reagents.
/proc/get_random_reagent_id(list/blacklist)
	var/static/list/reagent_static_list = list() //This is static, and will be used by default if a blacklist is not passed.
	var/list/reagent_list_to_process
	if(blacklist) //If we do have a blacklist, we recompile a new list with the excluded reagents not present and pick from there.
		reagent_list_to_process = list()
	else
		reagent_list_to_process = reagent_static_list

	if(!reagent_list_to_process.len)
		for(var/datum/reagent/reagent_path as anything in subtypesof(/datum/reagent))
			if(is_path_in_list(reagent_path, blacklist))
				continue

	var/picked_reagent = pick(reagent_list_to_process)
	return picked_reagent
