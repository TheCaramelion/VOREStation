///Returns the distance between two atoms
/proc/get_dist_euclidean(atom/first_location, atom/second_location)
	var/dx = first_location.x - second_location.x
	var/dy = first_location.y - second_location.y

	var/dist = sqrt(dx ** 2 + dy ** 2)

	return dist

/proc/get_adjacent_turfs(atom/center)
	var/list/hand_back = list()
	var/turf/simulated/floor/new_turf = get_step(center, NORTH)
	if(istype(new_turf))
		hand_back += new_turf
	new_turf = get_step(center, SOUTH)
	if(istype(new_turf))
		hand_back += new_turf
	new_turf = get_step(center, EAST)
	if(istype(new_turf))
		hand_back += new_turf
	new_turf = get_step(center, WEST)
	if(istype(new_turf))
		hand_back += new_turf
	return hand_back
