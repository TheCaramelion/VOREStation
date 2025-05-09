// Base AIs for simple mobs.
// Mob-specific AIs are in their mob's file.

/datum/ai_holder/simple_mob
	hostile = TRUE // The majority of simplemobs are hostile.
	retaliate = TRUE	// The majority of simplemobs will fight back.
	cooperative = TRUE
	returns_home = FALSE
	can_flee = FALSE
	speak_chance = 1 // If the mob's saylist is empty, nothing will happen.
	wander = TRUE
	base_wander_delay = 4

// For non-hostile animals, and pets like Ian and Runtime.
/datum/ai_holder/simple_mob/passive
	hostile = FALSE
	retaliate = FALSE
	can_flee = TRUE
	violent_breakthrough = FALSE
	base_wander_delay = 8 //vorestation edit, to make pets slow.
	belly_attack = FALSE //They already don't fight back, so this ensures that catgirls and similar are still edible when they are spawned as retaliate or aggressive by semi-random mob spawners.

// Won't wander away as quickly, ideal for event-spawned mobs like carp or drones.
/datum/ai_holder/simple_mob/event
	base_wander_delay = 8

// Will keep the mob within a limited radius of its home, useful for guarding an area
/datum/ai_holder/simple_mob/guard
	returns_home = TRUE

// Won't return home while it's busy doing something else, like chasing a player
/datum/ai_holder/simple_mob/guard/give_chase
	home_low_priority = TRUE

// Doesn't really act until told to by something on the outside.
/datum/ai_holder/simple_mob/inert
	hostile = FALSE
	retaliate = FALSE
	can_flee = FALSE
	wander = FALSE
	speak_chance = 0
	cooperative = FALSE
	violent_breakthrough = FALSE // So it can open doors but not attack windows and shatter the literal illusion.

// Used for technomancer illusions, to resemble player movement better.
/datum/ai_holder/simple_mob/inert/astar
	use_astar = TRUE

// Ranged mobs.

/datum/ai_holder/simple_mob/ranged
//	ranged = TRUE

// Tries to not waste ammo.
/datum/ai_holder/simple_mob/ranged/careful
	conserve_ammo = TRUE

/datum/ai_holder/simple_mob/ranged/pointblank
	pointblank = TRUE

// Runs away from its target if within a certain distance.
/datum/ai_holder/simple_mob/ranged/kiting
	pointblank = TRUE // So we don't need to copypaste post_melee_attack().
	var/run_if_this_close = 4 // If anything gets within this range, it'll try to move away.
	var/moonwalk = TRUE // If true, mob turns to face the target while kiting, otherwise they turn in the direction they moved towards.

/datum/ai_holder/simple_mob/ranged/kiting/threatening
	threaten = TRUE
	threaten_delay = 1 SECOND // Less of a threat and more of pre-attack notice.
	threaten_timeout = 30 SECONDS
	conserve_ammo = TRUE

// For event-spawned malf drones.
/datum/ai_holder/simple_mob/ranged/kiting/threatening/event
	base_wander_delay = 8

/datum/ai_holder/simple_mob/ranged/kiting/no_moonwalk
	moonwalk = FALSE

/datum/ai_holder/simple_mob/ranged/kiting/on_engagement(atom/A)
	if(get_dist(holder, A) < run_if_this_close)
		holder.IMove(get_step_away(holder, A, run_if_this_close))
		if(moonwalk)
			holder.face_atom(A)

// Closes distance from the target even while in range.
/datum/ai_holder/simple_mob/ranged/aggressive
	pointblank = TRUE
	var/closest_distance = 1 // How close to get to the target. By default they will get into melee range (and then pointblank them).

/datum/ai_holder/simple_mob/ranged/aggressive/on_engagement(atom/A)
	if(get_dist(holder, A) > closest_distance)
		holder.IMove(get_step_towards(holder, A))
		holder.face_atom(A)

// Yakkity saxes while firing at you.
/datum/ai_holder/hostile/ranged/robust/on_engagement(atom/movable/AM)
	step_rand(holder)
	holder.face_atom(AM)

// Only attacks you if you're in front of it.
/datum/ai_holder/simple_mob/ranged/guard_limit
	guard_limit = TRUE
	returns_home = TRUE

/datum/ai_holder/simple_mob/ranged/guard_limit/pointblank
	pointblank = TRUE

/datum/ai_holder/simple_mob/ranged/guard_limit/aggressive
	pointblank = TRUE
	var/closest_distance = 1

/datum/ai_holder/simple_mob/ranged/guard_limit/kiting
	pointblank = TRUE // So we don't need to copypaste post_melee_attack().
	var/run_if_this_close = 4 // If anything gets within this range, it'll try to move away.
	var/moonwalk = TRUE // If true, mob turns to face the target while kiting, otherwise they turn in the direction they moved towards.

// Switches intents based on specific criteria.
// Used for special mobs who do different things based on intents (and aren't slimes).
// Intent switching is generally done in pre_[ranged/special]_attack(), so that the mob can use the right attack for the right time.
/datum/ai_holder/simple_mob/intentional


// These try to avoid collateral damage.
/datum/ai_holder/simple_mob/restrained
	violent_breakthrough = FALSE
	conserve_ammo = TRUE
	destructive = FALSE

// This does the opposite of the above subtype.
/datum/ai_holder/simple_mob/destructive
	destructive = TRUE

// Melee mobs.

/datum/ai_holder/simple_mob/melee

// Dances around the enemy its fighting, making it harder to fight back.
/datum/ai_holder/simple_mob/melee/evasive

/datum/ai_holder/simple_mob/melee/evasive/post_melee_attack(atom/A)
	if(holder.Adjacent(A))
		holder.IMove(get_step(holder, pick(GLOB.alldirs)))
		holder.face_atom(A)



// This AI hits something, then runs away for awhile.
// It will (almost) always flee if they are uncloaked, AND their target is not stunned.
/datum/ai_holder/simple_mob/melee/hit_and_run
	can_flee = TRUE

// Used for the 'running' part of hit and run.
/datum/ai_holder/simple_mob/melee/hit_and_run/special_flee_check()
	if(!holder.is_cloaked())
		if(isliving(target))
			var/mob/living/L = target
			return !L.incapacitated(INCAPACITATION_DISABLED) // Don't flee if our target is stunned in some form, even if uncloaked. This is so the mob keeps attacking a stunned opponent.
		return TRUE // We're out in the open, uncloaked, and our target isn't stunned, so lets flee.
	return FALSE

// Can only target people in view range, will return home
/datum/ai_holder/simple_mob/melee/guard_limit
	guard_limit = TRUE
	returns_home = TRUE

/datum/ai_holder/simple_mob/melee/evasive/guard_limit
	guard_limit = TRUE
	returns_home = TRUE

// Simple mobs that aren't hostile, but will fight back.
/datum/ai_holder/simple_mob/retaliate
	hostile = FALSE
	retaliate = TRUE

/datum/ai_holder/simple_mob/retaliate/chill
	base_wander_delay = 8

/datum/ai_holder/simple_mob/retaliate/edible
	belly_attack = FALSE

// Simple mobs that retaliate and support others in their faction who get attacked.
/datum/ai_holder/simple_mob/retaliate/cooperative
	cooperative = TRUE

// With all the bells and whistles
/datum/ai_holder/simple_mob/humanoid
	intelligence_level = AI_SMART //Purportedly
	retaliate = TRUE //If attacked, attack back
	threaten = TRUE //Verbal threats
	firing_lanes = TRUE //Avoid shooting allies
	conserve_ammo = TRUE //Don't shoot when it can't hit target
	can_breakthrough = TRUE //Can break through doors
	violent_breakthrough = FALSE //Won't try to break through walls (humans can, but usually don't)
	speak_chance = 2 //Babble chance
	cooperative = TRUE //Assist each other
	wander = TRUE //Wander around
	returns_home = TRUE //But not too far
	use_astar = TRUE //Path smartly
	home_low_priority = TRUE //Following/helping is more important

// The hostile subtype is implied to be trained combatants who use ""tactics""
/datum/ai_holder/simple_mob/humanoid/hostile
	var/run_if_this_close = 4 // If anything gets within this range, it'll try to move away.
	hostile = TRUE //Attack!

// Juke
/datum/ai_holder/simple_mob/humanoid/hostile/post_melee_attack(atom/A)
	holder.IMove(get_step(holder, pick(GLOB.alldirs)))
	holder.face_atom(A)

/datum/ai_holder/simple_mob/humanoid/hostile/post_ranged_attack(atom/A)
	//Pick a random turf to step into
	var/turf/T = get_step(holder, pick(GLOB.alldirs))
	if((A in check_trajectory(A, T))) // Can we even hit them from there?
		holder.IMove(T)
		holder.face_atom(A)

	if(get_dist(holder, A) < run_if_this_close)
		holder.IMove(get_step_away(holder, A))
		holder.face_atom(A)

/datum/ai_holder/simple_mob/passive/speedy
	base_wander_delay = 1

// For setting up possible stealth missions
/datum/ai_holder/simple_mob/humanoid/hostile/guard_limit
	guard_limit = TRUE
