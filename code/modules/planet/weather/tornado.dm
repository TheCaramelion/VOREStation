/obj/effect/tornado
	name = "tornado"
	desc = "Why are you looking at this? RUN"
	density = FALSE
	anchored = TRUE

	icon = 'icons/effects/anomalies.dmi'
	icon_state = "vortex"

	var/lifespan = 5 MINUTES
	var/death_time

	var/category = 0
	var/pull_range = 10
	var/spin = 1
	var/move_chance = 90

	var/obj/effect/countdown/tornado/countdown
	var/datum/weather_holder/w_holder

/obj/effect/tornado/Initialize(mapload, new_lifespan, datum/weather_holder/new_holder)
	. = ..()

	START_PROCESSING(SSobj, src)

	if(new_holder)
		w_holder = new_holder

	if(new_lifespan)
		lifespan = new_lifespan
	death_time = world.time + lifespan

	countdown = new(src)

	countdown.start()

/obj/effect/tornado/process(seconds_per_tick)
	attempt_move(seconds_per_tick)
	attempt_pull()
	if(death_time < world.time)
		qdel(src)

/obj/effect/tornado/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(countdown)
	return ..()

/obj/effect/tornado/proc/attempt_move(seconds_per_tick)
	if(!prob(move_chance))
		return

	var/step_dir
	if(w_holder && w_holder.wind_dir)
		step_dir = w_holder.wind_dir
	else
		step_dir = pick(GLOB.alldirs)

	var/turf/simulated/T = get_step(src, step_dir)
	if(!istype(T) || !T.is_outdoors())
		return

	step(src, step_dir)

/obj/effect/tornado/proc/is_path_blocked(atom/movable/victim)
	var/turf/start = get_turf(src)
	var/turf/end = get_turf(victim)
	for(var/turf/T as anything in get_line(start, end))
		if(T == start || T == end)
			continue
		if(T.density)
			return TRUE
		for(var/obj/O in T)
			if(O.density)
				return TRUE
	return FALSE

/obj/effect/tornado/proc/attempt_pull()
	for(var/atom/movable/victim in orange(pull_range, src))
		if(victim == src || victim.anchored || isobserver(victim) || iseffect(victim))
			continue

		var/dist = get_dist(victim, src)

		if(!prob(100 - (dist * 8)))
			continue

		if(is_path_blocked(victim))
			continue

		var/pull_dir = get_dir(victim, src)
		if(!pull_dir)
			pull_dir = pick(GLOB.alldirs)
		else
			switch(dist)
				if(1 to 2)
					pull_dir = turn(pull_dir, 90 * spin)
				if(3 to 4)
					pull_dir = turn(pull_dir, 45 * spin)

		do_toss(victim, pull_dir)

/obj/effect/tornado/proc/do_toss(atom/movable/AM, pull_dir)
	var/atom/target = get_edge_target_turf(AM, pull_dir)
	AM.throw_at(target, 5, 1)
