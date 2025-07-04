/datum/symptom/robotic_adaptation
	name = "Biometallic Replication"
	desc = "The virus can manipulate metal and silicate compounds, becoming able to infect robotic beings."
	stealth = 0
	resistance = 1
	stage_speed = 4
	transmission = -1
	level = 9
	severity = 0
	symptom_delay_min = 20 SECONDS
	symptom_delay_max = 50 SECONDS
	prefixes = list("Robo")
	bodies = list("Robot")
	suffixes = list("-217")

	var/replaceorgans = FALSE
	var/replacebody = FALSE
	var/robustbits = FALSE

	threshold_descs = list(
		"Stage Speed 4" = "The virus will replace the host's organic organs with mundane, biometallic versions.",
		"Resistance 4" = "The virus will eventually convert the host's entire body to biometallic materials, and maintain its cellular integrity.",
		"Stage Speed 12" = "Biometallic mass created by the virus will be superior to typical organic mass."
	)

/datum/symptom/robotic_adaptation/OnAdd(datum/disease/advance/A)
	A.virus_modifiers |= INFECT_SYNTHETICS

/datum/symptom/robotic_adaptation/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stage_rate >= 4)
		severity += 1
		if(A.stage_rate >= 12)
			severity -= 3
	if(A.resistance >= 4)
		severity += 1

/datum/symptom/robotic_adaptation/Start(datum/disease/advance/A)
	. = ..()
	if(A.stage_rate >= 4)
		replaceorgans = TRUE
	if(A.resistance >= 4)
		replacebody = TRUE
	if(A.stage_rate >= 12)
		robustbits = TRUE

/datum/symptom/robotic_adaptation/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/human/H = A.affected_mob
	switch(A.stage)
		if(3, 4)
			if(replaceorgans && H.stat != DEAD)
				to_chat(H, span_warning("[pick("You feel a grinding pain in your abdomen.", "You exhale a jet of steam.")]"))
		if(5)
			if(replaceorgans || replacebody)
				Replace(H)
	return
