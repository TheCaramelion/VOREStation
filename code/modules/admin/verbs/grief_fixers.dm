/client/proc/fixatmos()
	set category = "Admin.Game"
	set name = "Fix Atmospherics Grief"

	if(!check_rights(R_ADMIN|R_DEBUG|R_EVENT)) return


	if(tgui_alert(usr, "WARNING: Executing this command will perform a full reset of atmosphere. All pipelines will lose any gas that may be in them, and all zones will be reset to contain air mix as on roundstart. The supermatter engine will also be stopped (to prevent overheat due to removal of coolant). Do not use unless the station is suffering serious atmospheric issues due to grief or bug.", "Full Atmosphere Reboot", list("No", "Yes")) != "Yes")
		return
	feedback_add_details("admin_verb","FA")

	log_and_message_admins("Full atmosphere reset initiated by [usr].")
	to_world(span_danger("Initiating restart of atmosphere. The server may lag a bit."))
	sleep(10)
	var/current_time = world.timeofday

	// Depower the supermatter, as it would quickly blow up once we remove all gases from the pipes.
	for(var/obj/machinery/power/supermatter/S in GLOB.machines)
		S.power = 0
	to_chat(usr, "\[1/5\] - Supermatter depowered")

	// Remove all gases from all pipenets
	for(var/datum/pipe_network/PN in SSmachines.networks)
		for(var/datum/gas_mixture/G in PN.gases)
			G.gas = list()
			G.update_values()

	to_chat(usr, "\[2/5\] - All pipenets purged of gas.")

	// Delete all zones.
	for(var/zone/Z in world)
		Z.c_invalidate()

	to_chat(usr, "\[3/5\] - All ZAS Zones removed.")

	var/list/unsorted_overlays = list()
	for(var/id in GLOB.gas_data.tile_overlay)
		unsorted_overlays |= GLOB.gas_data.tile_overlay[id]


	for(var/turf/simulated/T in world)
		T.air = null
		T.vis_contents.Remove(unsorted_overlays)
		T.zone = null

	to_chat(usr, "\[4/5\] - All turfs reset to roundstart values.")

	SSair.RebootZAS()

	to_chat(usr, "\[5/5\] - ZAS Rebooted")
	to_world(span_danger("Atmosphere restart completed in " + span_bold("[(world.timeofday - current_time)/10]") + " seconds."))
