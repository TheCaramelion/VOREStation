//not a computer
/obj/machinery/scanner
	name = "identity analyzer"
	var/outputdir = 0
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "scanner_idle"
	density = TRUE
	anchored = TRUE
	var/lastuser = null

/obj/machinery/scanner/Initialize(mapload)
	. = ..()
	if(!outputdir)
		switch(dir)
			if(1)
				outputdir = 2
			if(2)
				outputdir = 1
			if(4)
				outputdir = 8
			if(8)
				outputdir = 4
		if(!outputdir)
			outputdir = 8

/obj/machinery/scanner/process()
	if(stat & NOPOWER)
		return
	use_power(50)

/obj/machinery/scanner/power_change()
	..()
	if(stat & NOPOWER)
		spawn(rand(0, 15))
			icon_state = "scanner_off"
	else
		icon_state = "scanner_idle"

/obj/machinery/scanner/attack_hand(mob/living/carbon/human/user)
	if(stat & NOPOWER)
		return
	if(!ishuman(user) || lastuser == user.real_name)
		return
	use_power(500)
	flick("scanner_on",src)
	lastuser = user.real_name
	var/mname = user.real_name
	var/dna = user.dna.unique_enzymes
	var/bloodtype = user.dna.b_type
	var/fingerprint = md5(user.dna.uni_identity)
	var/list/marks = list()
	var/age = user.age
	var/gender = user.gender
	/* no dbstuff yet
	var/datum/db_query/cquery = SSdbcore.NewQuery("SELECT * from jobban WHERE ckey='[user.ckey]'")
	if(!cquery.Execute()) return
	else
		while(cquery.NextRow())
			var/list/row = cquery.GetRowData()
			marks += row["rank"]
	qdel(cquery)
	*/
	var/text = "\
	" span_huge("<center>Report</center>") + "<br>\
	" + span_bold(span_underline("Name")) + " : [mname]\
	" + span_bold(span_underline("Age")) + " : [age]\
	" + span_bold(span_underline("Sex")) + " : [gender]\
	" + span_bold(span_underline("DNA")) + " : [dna]\
	" + span_bold(span_underline("Blood Type")) + " : [bloodtype]\
	" + span_bold(span_underline("Fingerprint")) + " : [fingerprint]\
	" + span_bold(span_underline("Black Marks")) + " :<br> "
	for(var/A in marks)
		text += span_danger("[A]") + "<br>"
	to_chat(user, span_notice("You feel a sting as the scanner extracts some of your blood."))
	var/turf/T = get_step(src,outputdir)
	var/obj/item/paper/print = new(T)
	print.name = "[mname] Report"
	print.info = text
	print.stamped = 1

	for(var/datum/data/record/test in GLOB.data_core.general)
		if(test.fields["name"] == mname)
			return

	var/datum/data/record/G = new()
	var/datum/data/record/M = new()
	var/datum/data/record/S = new()
	var/datum/data/record/L = new()
	G.fields["rank"] = "Unassigned"
	G.fields["real_rank"] = G.fields["rank"]
	G.fields["name"] = mname
	G.fields["id"] = generate_record_id()
	M.fields["name"] = G.fields["name"]
	M.fields["id"] = G.fields["id"]
	S.fields["name"] = G.fields["name"]
	S.fields["id"] = G.fields["id"]
	if(gender == FEMALE)
		G.fields["sex"] = "Female"
	else
		G.fields["sex"] = "Male"
	G.fields["age"] = text("[]", age)
	G.fields["fingerprint"] = text("[]", fingerprint)
	G.fields["p_stat"] = "Active"
	G.fields["m_stat"] = "Stable"
	M.fields["b_type"] = text("[]", bloodtype)
	M.fields["b_dna"] = dna
	M.fields["mi_dis"] = "None"
	M.fields["mi_dis_d"] = "No minor disabilities have been declared."
	M.fields["ma_dis"] = "None"
	M.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
	M.fields["alg"] = "None"
	M.fields["alg_d"] = "No allergies have been detected in this patient."
	M.fields["cdi"] = "None"
	M.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
	M.fields["notes"] = "No notes."
	S.fields["criminal"] = "None"
	S.fields["mi_crim"] = "None"
	S.fields["mi_crim_d"] = "No minor crime convictions."
	S.fields["ma_crim"] = "None"
	S.fields["ma_crim_d"] = "No major crime convictions."
	S.fields["notes"] = "No notes."

	//Begin locked reporting
	L.fields["name"] = mname
	L.fields["sex"] = gender
	L.fields["age"] = age
	L.fields["id"] = md5("[mname][user.mind.assigned_role]")
	L.fields["rank"] = "Unknown"
	L.fields["real_rank"] = L.fields["rank"]
	L.fields["b_type"] = bloodtype
	L.fields["b_dna"] = dna
	L.fields["enzymes"] = user.dna.struc_enzymes
	L.fields["identity"] = user.dna.uni_identity
	L.fields["image"] = getFlatIcon(user,0)//What the person looks like. Naked, in this case.
	//End locked reporting

	GLOB.data_core.general += G
	data_core.medical += M
	data_core.security += S
	data_core.locked += L
