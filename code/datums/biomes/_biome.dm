///This datum handles the transitioning from a turf to a specific biome, and handles spawning decorative structures and mobs.
/datum/biome
	///Type of turf this biome creates
	var/turf_type
	/// Chance of having a structure from the flora types list spawn
	var/flora_density = 0
	/// Chance of spawning special features, such as geysers.
	var/feature_density = 0
	/// Chance of having a mob from the fauna types list spawn
	var/fauna_density = 0
	/// Weighted list of type paths of flora that can be spawned when the
	/// turf spawns flora.
	var/list/flora_types = list()
	/// Weighted list of extra features that can spawn in the biome, such as
	/// geysers. Gets expanded automatically.
	var/list/feature_types = list()
	/// Weighted list of type paths of fauna that can be spawned when the
	/// turf spawns fauna.
	var/list/fauna_types = list()

/datum/biome/New()
	. = ..()
	if(length(flora_types))
		flora_types = expand_weights(fill_with_ones(flora_types))

	if(length(fauna_types))
		fauna_types = expand_weights(fill_with_ones(fauna_types))

	if(length(feature_types))
		feature_types = expand_weights(feature_types)

/datum/biome/proc/generate_turf(turf/gen_turf)
	gen_turf.ChangeTurf(turf_type)
	if(length(flora_types) && prob(flora_density))
		var/obj/structure/flora = pick(flora_types)
		new flora(gen_turf)
		return

	if(length(feature_types) && prob(feature_density))
		var/atom/picked_feature = pick(feature_types)
		new picked_feature(gen_turf)
		return

	if(length(fauna_types) && prob(fauna_density))
		var/mob/fauna = pick(fauna_types)
		new fauna(gen_turf)

/// This proc handles the creation of a turf of a specific biome type, assuming
/// that the turf has not been initialized yet. Don't call this unless you know
/// what you're doing.
/datum/biome/proc/generate_turf_for_terrain(turf/gen_turf)
	var/turf/new_turf = new turf_type(gen_turf)
	return new_turf

/datum/biome/proc/generate_turfs_for_terrain(lits/turf/gen_turfs)
	var/list/turf/new_turfs = list()

	for(var/turf/gen_turf as anything in gen_turfs)
		var/turf/new_turf = new turf_type(gen_turf)
		new_turs += new_turf

		CHECK_TICK

	return new_turfs

/// This proc handles populating the given turf based on whether flora,
/// features and fauna are allowed.
/datum/biome/proc/populate_turf(turf/target_turf, flora_allowed, features_allowed, fauna_allowed)
	if(flora_allowed && length(flora_types) && prob(flora_density))
		var/obj/structure/flora = pick(flora_types)
		new flora(target_turf)
		return TRUE

	if(features_allowed && prob(feature_density))
		var/can_spawn = TRUE

		var/atom/picked_feature = pick(feature_types)

		for(var/obj/structure/existing_feature in range(7, target_turf))
			if(istype(existing_feature, picked_feature))
				can_spawn = FALSE
				break

		if(can_spawn)
			new picked_feature(target_turf)
			return TRUE

	if(fauna_allowed && length(fauna_types) && prob(fauna_density))
		var/mob/picked_mob = pick(fauna_types)
		new picked_mob(target_turf)
		return TRUE
	return FALSE

/**
 * This proc handles populating the given turfs based on whether flora, features
 * and fauna are allowed. Does not take megafauna into account.
 *
 * Does nothing if `flora_allowed`, `features_allowed` and `fauna_allowed` are
 * `FALSE`, or if there's no flora, feature or fauna types for the matching
 * allowed type. Aka, we return early if the proc wouldn't do anything anyway.
 */
/datum/biome/proc/populate_turfs(list/turf/target_turfs, flora_allowed, features_allowed, fauna_allowed)
	if(!(flora_allowed && length(flora_types)) && !(features_allowed && length(feature_types)) && !(fauna_allowed && length(fauna_types)))
		return

	for(var/turf/target_turf as anything in target_turfs)
		// We do the CHECK_TICK here because there's a bunch of continue calls
		// in this.
		CHECK_TICK

		if(flora_allowed && length(flora_types) && prob(flora_density))
			var/obj/structure/flora = pick(flora_types)
			new flora(target_turf)
			continue

		if(features_allowed && prob(feature_density))
			var/can_spawn = TRUE

			var/atom/picked_feature = pick(feature_types)

			for(var/obj/structure/existing_feature in range(7, target_turf))
				if(istype(existing_feature, picked_feature))
					can_spawn = FALSE
					break

			if(can_spawn)
				new picked_feature(target_turf)
				continue

		if(fauna_allowed && length(fauna_types) && prob(fauna_density))
			var/mob/picked_mob = pick(fauna_types)
			new picked_mob(target_turf)
