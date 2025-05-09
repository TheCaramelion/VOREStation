/datum/unit_test/all_robot_sprites_must_be_valid
	name = "ROBOTS: Robot sprites must be valid"
	var/signal_failed = FALSE

/datum/unit_test/all_robot_sprites_must_be_valid/start_test()
	var/failed = 0

	for(var/sprite in subtypesof(/datum/robot_sprite))
		var/datum/robot_sprite/RS = new sprite()
		if(!RS.name) // Parent type, ignore me
			continue

		if(!RS.sprite_icon)
			log_unit_test("[RS.type]: Robots - Robot sprite \"[RS.name]\", missing sprite_icon.")
			failed = TRUE
			continue

		var/list/checks = list(
			"[ROBOT_HAS_SPEED_SPRITE]" = "-roll",
			"[ROBOT_HAS_SHIELD_SPRITE]" = "-shield",
			"[ROBOT_HAS_SHIELD_SPEED_SPRITE]" = "-speed_shield",
			"[ROBOT_HAS_MELEE_SPRITE]" = "-melee",
			"[ROBOT_HAS_DAGGER_SPRITE]" = "-dagger",
			"[ROBOT_HAS_BLADE_SPRITE]" = "-blade",
			"[ROBOT_HAS_GUN_SPRITE]" = "-gun",
			"[ROBOT_HAS_LASER_SPRITE]" = "-laser",
			"[ROBOT_HAS_TASER_SPRITE]" = "-taser",
			"[ROBOT_HAS_DISABLER_SPRITE]" = "-disabler"
		)
		for(var/C in checks)
			if(RS.sprite_flag_check(text2num(C)))
				if(check_state(RS,checks[C]))
					failed = TRUE
		// eyes, lights, markings
		if(RS.has_eye_sprites)
			if(check_state(RS,"-eyes"))
				failed = TRUE
		if(RS.has_eye_light_sprites)
			if(check_state(RS,"-lights"))
				failed = TRUE
		if(LAZYLEN(RS.sprite_decals))
			for(var/decal in RS.sprite_decals)
				if(check_state(RS,"-[decal]"))
					failed = TRUE
		if(LAZYLEN(RS.sprite_animations))
			for(var/animation in RS.sprite_animations)
				if(check_state(RS,"-[animation]"))
					failed = TRUE
		// Control panel
		if(RS.has_custom_open_sprites)
			if(check_state(RS,"-openpanel_nc"))
				failed = TRUE
			if(check_state(RS,"-openpanel_c"))
				failed = TRUE
			if(check_state(RS,"-openpanel_w"))
				failed = TRUE
		// Glow State
		if(RS.has_glow_sprites)
			if(check_state(RS,"-glow"))
				failed = TRUE
		// Bellies
		if(RS.has_vore_belly_sprites && !RS.belly_capacity_list)
			if(RS.has_sleeper_light_indicator)
				// belly r/g light
				if(check_state(RS,"-sleeper-r"))
					failed = TRUE
				if(check_state(RS,"-sleeper-g"))
					failed = TRUE
				if(RS.has_vore_belly_resting_sprites)
					for(var/rest_style in RS.rest_sprite_options)
						rest_style = lowertext(rest_style)
						if(rest_style == "default")
							rest_style = "rest"
						if(check_state(RS,"-sleeper-r-[rest_style]"))
							failed = TRUE
						if(check_state(RS,"-sleeper-g-[rest_style]"))
							failed = TRUE
				// struggling
				if(RS.has_vore_struggle_sprite)
					if(check_state(RS,"-sleeper-r-struggle"))
						failed = TRUE
					if(check_state(RS,"-sleeper-g-struggle"))
						failed = TRUE
					if(RS.has_vore_belly_resting_sprites)
						for(var/rest_style in RS.rest_sprite_options)
							rest_style = lowertext(rest_style)
							if(rest_style == "default")
								rest_style = "rest"
							if(check_state(RS,"-sleeper-r-[rest_style]-struggle"))
								failed = TRUE
							if(check_state(RS,"-sleeper-g-[rest_style]-struggle"))
								failed = TRUE
			else
				// belly
				if(check_state(RS,"-sleeper"))
					failed = TRUE
				if(RS.has_vore_belly_resting_sprites)
					for(var/rest_style in RS.rest_sprite_options)
						rest_style = lowertext(rest_style)
						if(rest_style == "default")
							rest_style = "rest"
						if(check_state(RS,"-sleeper-[rest_style]"))
							failed = TRUE
				// struggling
				if(RS.has_vore_struggle_sprite)
					if(check_state(RS,"-sleeper-struggle"))
						failed = TRUE
					if(RS.has_vore_belly_resting_sprites)
						for(var/rest_style in RS.rest_sprite_options)
							rest_style = lowertext(rest_style)
							if(rest_style == "default")
								rest_style = "rest"
							if(check_state(RS,"-sleeper-[rest_style]-struggle"))
								failed = TRUE
		else if (RS.belly_capacity_list)
			for(var/belly in RS.belly_capacity_list)
				for(var/num = 1 to RS.belly_capacity_list[belly])
					// big belly
					if(check_state(RS,"-[belly]-[num]"))
						failed = TRUE
					if(RS.has_vore_belly_resting_sprites)
						for(var/rest_style in RS.rest_sprite_options)
							rest_style = lowertext(rest_style)
							if(rest_style == "default")
								rest_style = "rest"
							if(check_state(RS,"-[belly]-[num]-[rest_style]"))
								failed = TRUE
					// struggling
					if(RS.has_vore_struggle_sprite)
						if(check_state(RS,"-[belly]-[num]-struggle"))
							failed = TRUE
						if(RS.has_vore_belly_resting_sprites)
							for(var/rest_style in RS.rest_sprite_options)
								rest_style = lowertext(rest_style)
								if(rest_style == "default")
									rest_style = "rest"
								if(check_state(RS,"-[belly]-[num]-[rest_style]-struggle"))
									failed = TRUE
			if(RS.belly_light_list)
				for(var/belly in RS.belly_light_list)
					for(var/num = 1 to RS.belly_light_list[belly])
						// multi belly r/g light
						if(check_state(RS,"-[belly]-[num]-r"))
							failed = TRUE
						if(check_state(RS,"-[belly]-[num]-g"))
							failed = TRUE
						if(RS.has_vore_belly_resting_sprites)
							for(var/rest_style in RS.rest_sprite_options)
								rest_style = lowertext(rest_style)
								if(rest_style == "default")
									rest_style = "rest"
								if(check_state(RS,"-[belly]-[num]-r-[rest_style]"))
									failed = TRUE
								if(check_state(RS,"-[belly]-[num]-g-[rest_style]"))
									failed = TRUE
						// struggling
						if(RS.has_vore_struggle_sprite)
							if(check_state(RS,"-[belly]-[num]-r-struggle"))
								failed = TRUE
							if(check_state(RS,"-[belly]-[num]-g-struggle"))
								failed = TRUE
							if(RS.has_vore_belly_resting_sprites)
								for(var/rest_style in RS.rest_sprite_options)
									rest_style = lowertext(rest_style)
									if(rest_style == "default")
										rest_style = "rest"
									if(check_state(RS,"-[belly]-[num]-r-[rest_style]-struggle"))
										failed = TRUE
									if(check_state(RS,"-[belly]-[num]-g-[rest_style]-struggle"))
										failed = TRUE
		// reseting
		for(var/rest_style in RS.rest_sprite_options)
			rest_style = lowertext(rest_style)
			if(rest_style == "default")
				rest_style = "rest"
			if(check_state(RS,"-[rest_style]"))
				failed = TRUE
			if(RS.has_glow_sprites)
				if(check_state(RS,"-[rest_style]-glow"))
					failed = TRUE
			if(RS.has_rest_lights_sprites)
				if(check_state(RS,"-[rest_style]-lights"))
					failed = TRUE
			if(RS.has_rest_eyes_sprites)
				if(check_state(RS,"-[rest_style]-eyes"))
					failed = TRUE
		// death
		if(RS.has_dead_sprite)
			if(check_state(RS,"-wreck"))
				failed = TRUE
		if(RS.has_dead_sprite_overlay) // Only one per dmi
			if(!("wreck-overlay" in cached_icon_states(RS.sprite_icon)))
				log_unit_test("[RS.type]: Robots - Robot sprite \"[RS.name]\", missing icon_state wreck-overlay, in dmi \"[RS.sprite_icon]\".")
				failed = TRUE
		// offset
		var/icon/I = new(RS.sprite_icon)
		if(RS.icon_x != I.Width())
			log_unit_test("[RS.type]: Robots - Robot sprite \"[RS.name]\", icon_x \"[RS.icon_x]\" did not match dmi configured width \"[I.Width()]\"")
			failed = TRUE
		if(RS.icon_y != I.Height())
			log_unit_test("[RS.type]: Robots - Robot sprite \"[RS.name]\", icon_y \"[RS.icon_y]\" did not match dmi configured height \"[I.Height()]\"")
			failed = TRUE
		if(RS.icon_y != RS.vis_height)
			log_unit_test("[RS.type]: Robots - Robot sprite \"[RS.name]\", vis_height \"[RS.vis_height]\" did not match icon_y \"[RS.icon_y]\"")
			failed = TRUE
		var/legal_offset = (I.Width() - world.icon_size) / 2
		if(RS.pixel_x != -legal_offset)
			log_unit_test("[RS.type]: Robots - Robot sprite \"[RS.name]\", pixel_x \"[RS.pixel_x]\" did not have correct offset, should be \"[-legal_offset]\"")
			failed = TRUE
		qdel(I)
		qdel(RS)

	if(failed)
		fail("One or more /datum/robot_sprite items had invalid flags or icons")
	else
		pass("All /datum/robot_sprite are valid.")
	return 1

/datum/unit_test/all_robot_sprites_must_be_valid/proc/check_state(var/datum/robot_sprite/RS,var/append)
	var/check_state = "[RS.sprite_icon_state][append]"
	if(!(check_state in cached_icon_states(RS.sprite_icon)))
		log_unit_test("[RS.type]: Robots - Robot sprite \"[RS.name]\", enabled but missing icon_state \"[check_state]\", in dmi \"[RS.sprite_icon]\".")
		return TRUE
	return FALSE
