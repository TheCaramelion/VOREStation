SUBSYSTEM_DEF(weather)
	name = "Weather"
	dependencies = list(
		/datum/controller/subsystem/mapping
	)
	wait = 10
	runlevels = RUNLEVEL_GAME
	var/list/processing = list()
	var/list/eligible_zlevels = list()
	var/list/next_hit_by_zlevel = list()

/datum/controller/subsystem/weather/fire(resumed = FALSE)
	for(var/datum/weather/weather_event as anything in processing)
		if(!length(weather_event.sybs))
