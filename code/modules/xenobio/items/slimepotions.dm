// These things get applied to slimes to do things.

/obj/item/slimepotion
	name = "slime agent"
	desc = "A flask containing strange, mysterious substances excreted by a slime."
	icon = 'icons/obj/chemical.dmi'
	w_class = ITEMSIZE_TINY
	origin_tech = list(TECH_BIO = 4)

// This is actually applied to an extract, so no attack() overriding needed.
/obj/item/slimepotion/enhancer
	name = "extract enhancer agent"
	desc = "A potent chemical mix that will give a slime extract an additional two uses."
	icon_state = "potcyan"
	description_info = "This will even work on inert slime extracts, if it wasn't enhanced before.  Extracts enhanced cannot be enhanced again."

// Makes slimes less likely to mutate.
/obj/item/slimepotion/stabilizer
	name = "slime stabilizer agent"
	desc = "A potent chemical mix that will reduce the chance of a slime mutating."
	icon_state = "potcyan"
	description_info = "The slime needs to be alive for this to work.  It will reduce the chances of mutation by 15%."

/obj/item/slimepotion/stabilizer/attack(mob/living/simple_mob/slime/xenobio/M, mob/user)
	if(!istype(M))
		to_chat(user, span_warning("The stabilizer only works on slimes!"))
		return ..()
	if(M.stat == DEAD)
		to_chat(user, span_warning("The slime is dead!"))
		return ..()
	if(M.mutation_chance == 0)
		to_chat(user, span_warning("The slime already has no chance of mutating!"))
		return ..()

	to_chat(user, span_notice("You feed the slime the stabilizer. It is now less likely to mutate."))
	M.mutation_chance = between(0, M.mutation_chance - 15, 100)
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	qdel(src)


// The opposite, makes the slime more likely to mutate.
/obj/item/slimepotion/mutator
	name = "slime mutator agent"
	desc = "A potent chemical mix that will increase the chance of a slime mutating."
	description_info = "The slime needs to be alive for this to work.  It will increase the chances of mutation by 12%."
	icon_state = "potred"

/obj/item/slimepotion/mutator/attack(mob/living/simple_mob/slime/xenobio/M, mob/user)
	if(!istype(M))
		to_chat(user, span_warning("The mutator only works on slimes!"))
		return ..()
	if(M.stat == DEAD)
		to_chat(user, span_warning("The slime is dead!"))
		return ..()
	if(M.mutation_chance == 100)
		to_chat(user, span_warning("The slime is already guaranteed to mutate!"))
		return ..()

	to_chat(user, span_notice("You feed the slime the mutator. It is now more likely to mutate."))
	M.mutation_chance = between(0, M.mutation_chance + 12, 100)
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	qdel(src)


// Makes the slime friendly forever.
/obj/item/slimepotion/docility
	name = "slime docility agent"
	desc = "A potent chemical mix that nullifies a slime's hunger, causing it to become docile and tame.  It might also work on other creatures?"
	icon_state = "potlightpink"
	description_info = "The target needs to be alive, not already passive, and be an animal or slime type entity."
	var/currently_using = FALSE						// To avoid same potion being usable multiple times

/obj/item/slimepotion/docility/attack(mob/living/simple_mob/M, mob/user)
	if(!istype(M))
		to_chat(user, span_warning("The agent only works on creatures!"))
		return ..()
	if(M.stat == DEAD)
		to_chat(user, span_warning("\The [M] is dead!"))
		return ..()
	if(!M.has_AI())
		to_chat(user, span_warning("\The [M] is too strongly willed for this to affect them.")) // Most likely player controlled.
		return
	if(currently_using)
		to_chat(user, span_warning("This agent has already been used!")) // Possibly trying to cheese the dialogue box and use same potion on multiple targets.
		return

	currently_using = TRUE
	var/datum/ai_holder/AI = M.ai_holder

	// Slimes.
	if(istype(M, /mob/living/simple_mob/slime/xenobio))
		var/mob/living/simple_mob/slime/xenobio/S = M
		if(S.harmless)
			to_chat(user, span_warning("The slime is already docile!"))
			return ..()

		S.pacify()
		S.nutrition = 700
		to_chat(M, span_warning("You absorb the agent and feel your intense desire to feed melt away."))
		to_chat(user, span_notice("You feed the slime the agent, removing its hunger and calming it."))

	// Simple Mobs.
	else if(isanimal(M))
		var/mob/living/simple_mob/SM = M
		if(!(SM.mob_class & (MOB_CLASS_SLIME|MOB_CLASS_ANIMAL))) // So you can't use this on Russians/syndies/hivebots/etc.
			to_chat(user, span_warning("\The [SM] only works on slimes and animals."))
			return ..()
		if(!AI.hostile)
			to_chat(user, span_warning("\The [SM] is already passive!"))
			return ..()

		AI.hostile = FALSE
		to_chat(M, span_warning("You consume the agent and feel a serene sense of peace."))
		to_chat(user, span_notice("You feed \the [SM] the agent, calming it."))

	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	AI.remove_target() // So hostile things stop attacking people even if not hostile anymore.
	var/newname = copytext(sanitize(tgui_input_text(user, "Would you like to give \the [M] a name?", "Name your new pet", M.name, MAX_NAME_LEN)),1,MAX_NAME_LEN)

	if(newname)
		M.name = newname
		M.real_name = newname
	qdel(src)


// Makes slimes make more extracts.
/obj/item/slimepotion/steroid
	name = "slime steroid agent"
	desc = "A potent chemical mix that will increase the amount of extracts obtained from harvesting a slime."
	description_info = "The slime needs to be alive and not an adult for this to work.  It will increase the amount of extracts gained by one, up to a max of five per slime.  \
	Extra extracts are not passed down to offspring when reproducing."
	icon_state = "potpurple"

/obj/item/slimepotion/steroid/attack(mob/living/simple_mob/slime/xenobio/M, mob/user)
	if(!istype(M))
		to_chat(user, span_warning("The steroid only works on slimes!"))
		return ..()
	if(M.stat == DEAD)
		to_chat(user, span_warning("The slime is dead!"))
		return ..()
	if(M.is_adult) //Can't steroidify adults
		to_chat(user, span_warning("Only baby slimes can use the steroid!"))
		return ..()
	if(M.cores >= 5)
		to_chat(user, span_warning("The slime already has the maximum amount of extract!"))
		return ..()

	to_chat(user, span_notice("You feed the slime the steroid. It will now produce one more extract."))
	M.cores++
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	qdel(src)


// Makes slimes not try to murder other slime colors.
/obj/item/slimepotion/unity
	name = "slime unity agent"
	desc = "A potent chemical mix that makes the slime feel and be seen as all the colors at once, and as a result not be considered an enemy to any other color."
	description_info = "The slime needs to be alive for this to work.  Slimes unified will not attack or be attacked by other colored slimes, and this will \
	carry over to offspring when reproducing."
	icon_state = "potpink"

/obj/item/slimepotion/unity/attack(mob/living/simple_mob/slime/M, mob/user)
	if(!istype(M))
		to_chat(user, span_warning("The agent only works on slimes!"))
		return ..()
	if(M.stat == DEAD)
		to_chat(user, span_warning("The slime is dead!"))
		return ..()
	if(M.unity == TRUE)
		to_chat(user, span_warning("The slime is already unified!"))
		return ..()

	to_chat(user, span_notice("You feed the slime the agent. It will now be friendly to all other slimes."))
	to_chat(M, span_notice("\The [user] feeds you \the [src], and you suspect that all the other slimes will be \
	your friends, at least if you don't attack them first."))
	M.unify()
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	qdel(src)

// Makes slimes not kill (most) humanoids but still fight spiders/carp/bears/etc.
/obj/item/slimepotion/loyalty
	name = "slime loyalty agent"
	desc = "A potent chemical mix that makes an animal deeply loyal to the species of whoever applies this, and will attack threats to them."
	description_info = "The slime or other animal needs to be alive for this to work.  The slime this is applied to will have their 'faction' change to \
	the user's faction, which means the slime will attack things that are hostile to the user's faction, such as carp, spiders, and other slimes."
	icon_state = "potlightpink"

/obj/item/slimepotion/loyalty/attack(mob/living/simple_mob/M, mob/user)
	if(!istype(M))
		to_chat(user, span_warning("The agent only works on creatures!"))
		return ..()
	if(!(M.mob_class & (MOB_CLASS_SLIME|MOB_CLASS_ANIMAL))) // So you can't use this on Russians/syndies/hivebots/etc.
		to_chat(user, span_warning("\The [M] only works on slimes and animals."))
		return ..()
	if(M.stat == DEAD)
		to_chat(user, span_warning("The animal is dead!"))
		return ..()
	if(M.faction == user.faction)
		to_chat(user, span_warning("\The [M] is already loyal to your species!"))
		return ..()
	if(!M.has_AI())
		to_chat(user, span_warning("\The [M] is too strong-willed for this to affect them."))
		return ..()

	var/datum/ai_holder/AI = M.ai_holder

	to_chat(user, span_notice("You feed \the [M] the agent. It will now try to murder things that want to murder you instead."))
	to_chat(M, span_notice("\The [user] feeds you \the [src], and feel that the others will regard you as an outsider now."))
	M.faction = user.faction
	AI.remove_target() // So hostile things stop attacking people even if not hostile anymore.
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	qdel(src)


// User befriends the slime with this.
/obj/item/slimepotion/friendship
	name = "slime friendship agent"
	desc = "A potent chemical mix that makes an animal deeply loyal to the the specific entity which feeds them this agent."
	description_info = "The slime or other animal needs to be alive for this to work.  The slime this is applied to will consider the user \
	their 'friend', and will never attack them.  This might also work on other things besides slimes."
	icon_state = "potlightpink"

/obj/item/slimepotion/friendship/attack(mob/living/simple_mob/M, mob/user)
	if(!istype(M))
		to_chat(user, span_warning("The agent only works on creatures!"))
		return ..()
	if(!(M.mob_class & (MOB_CLASS_SLIME|MOB_CLASS_ANIMAL))) // So you can't use this on Russians/syndies/hivebots/etc.
		to_chat(user, span_warning("\The [M] only works on slimes and animals."))
		return ..()
	if(M.stat == DEAD)
		to_chat(user, span_warning("\The [M] is dead!"))
		return ..()
	if(user in M.friends)
		to_chat(user, span_warning("\The [M] is already loyal to you!"))
		return ..()
	if(!M.has_AI())
		to_chat(user, span_warning("\The [M] is too strong-willed for this to affect them."))
		return ..()

	var/datum/ai_holder/AI = M.ai_holder

	to_chat(user, span_notice("You feed \the [M] the agent. It will now be your best friend."))
	to_chat(M, span_notice("\The [user] feeds you \the [src], and feel that \the [user] wants to be best friends with you."))
	M.friends.Add(user)
	AI.remove_target() // So hostile things stop attacking people even if not hostile anymore.
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	qdel(src)


// Feeds the slime instantly.
/obj/item/slimepotion/feeding
	name = "slime feeding agent"
	desc = "A potent chemical mix that will instantly sediate the slime."
	description_info = "The slime needs to be alive for this to work.  It will instantly grow the slime enough to reproduce."
	icon_state = "potorange"

/obj/item/slimepotion/feeding/attack(mob/living/simple_mob/slime/xenobio/M, mob/user)
	if(!istype(M))
		to_chat(user, span_warning("The feeding agent only works on slimes!"))
		return ..()
	if(M.stat == DEAD)
		to_chat(user, span_warning("The slime is dead!"))
		return ..()

	to_chat(user, span_notice("You feed the slime the feeding agent. It will now instantly reproduce."))
	M.amount_grown = 10
	M.make_adult()
	M.amount_grown = 10
	M.reproduce()
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	qdel(src)
