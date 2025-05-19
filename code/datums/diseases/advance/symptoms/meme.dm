/datum/symptom/meme
	name = "Hysteria"
	desc = "The virus causes mass hysteria involving a random concept."
	stealth = 1
	resistance = 1
	stage_speed = -1
	transmission = 3
	level = 9
	severity = 0
	base_message_chance = 50
	symptom_delay_min = 15 SECONDS
	symptom_delay_max = 45 SECONDS

	var/emote
	var/emotelist = list("flip", "spin", "smile", "floorspin", "merp", "yawn", "snap", "clap", "scream", "roarbark")

/datum/symptom/meme/Copy()
	var/datum/symptom/meme/new_symp = new type
	new_symp.name = name
	new_symp.id = id
	new_symp.neutered = neutered
	if(emote)
		new_symp.emote = emote
	return new_symp

/datum/symptom/meme/Start(datum/disease/advance/A)
	if(!..())
		return
	if(!emote)
		emote = pick(emotelist)

/datum/symptom/meme/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/human/H = A.affected_mob
	if(H.stat == DEAD)
		return
	if(prob(20 * A.stage))
		H.emote(emote)
		if(A.stage >= 5 && prob(20) && (A.transmission >= 14))
			for(var/mob/living/carbon/human/H in oviewers(H, 4))
				var/obj/item/organ/internal/eyes/eyes = H.organs_by_name[O_EYES]
				if(!eyes || H.is_blind())
					continue
				if(H.ForceContractDisease(A))
					H.emote(emote)
