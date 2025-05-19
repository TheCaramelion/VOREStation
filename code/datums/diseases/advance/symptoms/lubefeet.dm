/datum/symptom/lubefeet
	name = "Ducatopod"
	desc = "The host now sweats industrial lubricant from their feet, lubing tiles they walk on."
	stealth = 0
	resistance = 2
	stage_speed = 5
	transmission = -2
	level = 9
	severity = 2
	symptom_delay_min = 1 SECOND
	symptom_delay_max = 3 SECONDS
	base_message_chance = 15

	var/morelube = FALSE
	var/clownshoes = FALSE

	threshold_descs = list(
		"Transmission 10" = "The host sweats even more profusely, lubing almost eevery tile they walk over.",
		"Resistance 14" = "The host's feet turn into a pair of clown shoes."
	)

/datum/symptom/lubefeet/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 10)
		severity += 1

/datum/symptom/lubefeet/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 10)
		morelube = TRUE
	if(A.resistance >= 14)
		clownshoes = TRUE

/datum/symptom/lubefeet/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/L = A.affected_mob
	switch(A.stage)
		if(1, 2)
			if(base_message_chance)
				to_chat(L, span_notice("Your feet begin to sweat profusely..."))
		if(3, 4)
			if(L.stat != DEAD)
				to_chat(L, span_notice("You slide about inside your shoes!"))
			if(A.stage == 4)
				if(morelube)
					makelube(L, 40)
				else
					makelube(L, 20)
		if(5)
			if(L.stat != DEAD)
				to_chat(L, span_danger("You slide about inside your shoes!"))
			if(morelube)
				makelube(L, 40)
			else
				makelube(L, 20)
			L.reagents.add_reagent(REAGENT_ID_LUBE, 1)
			if(clownshoes)
				give_clown_shoes(A)

/datum/symptom/lubefeet/proc/makelube(mob/living/L, chance)
	if(prob(chance))
		var/turf/simulated/turf = get_turf(L)
		if(istype(turf))
			if(L.stat != DEAD)
				to_chat(L, span_danger("The lube pools into a puddle!"))
			turf.wet_floor(2)

/datum/symptom/lubefeet/End(datum/disease/advance/A)
	..()
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		if(istype(H.shoes, /obj/item/clothing/shoes/clown_shoes))
			var/obj/item/clothing/shoes = H.shoes
			shoes.forceMove(H.loc)
			qdel(shoes)
		return

/datum/symptom/lubefeet/proc/give_clown_shoes(datum/disease/advance/A)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		if(!istype(H.shoes, /obj/item/clothing/shoes/clown_shoes))
			H.shoes.forceMove(H.loc)
		var/obj/item/clothing/C = new /obj/item/clothing/shoes/clown_shoes(H)
		H.equip_to_slot_or_del(C, slot_shoes)
		return
