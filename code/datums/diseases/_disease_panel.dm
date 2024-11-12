/client/proc/DiseasePanel()
	set category = "Fun.Event Kit"
	set name = "Diseases Panel"

	if(!check_rights(R_FUN))
		return FALSE

	var/datum/disease_panel/spawner = new()
	spawner.tgui_interact(src.mob)

/datum/disease_panel/New()
	. = ..()

/datum/disease_panel/tgui_state(mob/user)
	return GLOB.tgui_admin_state

/datum/disease_panel/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DiseasePanel", "Disease Panel")
		ui.open()

/datum/disease_panel/Destroy()
	. = ..()

/datum/disease_panel/tgui_static_data(mob/user)
	var/list/data = list()
	. = data

	var/list/diseases = subtypesof(/datum/disease)
	var/list/symptoms = subtypesof(/datum/symptom)
	var/list/infectee = list()

	var/list/diseasesData = list()
	var/list/symptomsData = list()

	for (var/thing in diseases)
		var/datum/disease/D = thing
		if(istype(D, /datum/disease/advance))
			continue
		diseasesData += list(list(
			"commonName" = D.name,
			"description" = D.desc,
			"treatment" = D.cure_text,
			"transmission" = D.spread_text
		))

	for (var/thing in symptoms)
		var/datum/symptom/S = thing
		symptomsData += list(list(
			"name" = S.name,
			"stealth" = S.stealth,
			"resistance" = S.resistance,
			"stageSpeed" = S.stage_speed,
			"transmittable" = S.transmittable,
			"severity" = S.severity
		))

	for (var/thing in human_mob_list)
		var/mob/living/carbon/human/H = thing
		if (H.ckey)
			infectee += H

	data["diseases"] = diseasesData
	data["symptoms"] = symptomsData
	data["infectee"] = infectee

/datum/disease_panel/tgui_act(action)
	. = ..()
	if(.)
		return
	if(!check_rights_for(usr.client, R_FUN))
		return
