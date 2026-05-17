//The code execution of the emote datum is located at code/datums/emotes.dm
/mob/proc/emote(act, m_type = null, message = null, ignore_status = FALSE, var/arguments)
	var/param = message
	var/custom_param = findtext(act, " ") // Someone was given as a parameter
	if(custom_param)
		param = copytext(act, custom_param + 1, length(act) + 1)
		act = copytext(act, 1, custom_param)

	var/datum/emote/E
	E = E.emote_list[lowertext(act)]
	if(!E)
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")
	else
		E.run_emote(src, param, m_type, ignore_status, arguments)

/datum/emote/flip
	key = "flip"
	key_third_person = "flips"
	restraint_check = TRUE
	mob_type_allowed_typelist = list(/mob/living, /mob/dead/observer)
	mob_type_blacklist_typelist = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/carbon/brain)
	mob_type_ignore_stat_typelist = list(/mob/dead/observer)

/datum/emote/flip/run_emote(mob/user, params)
	. = ..()
	if(.)
		var/prev_dir = user.dir
		for(var/i in list(1, 4, 2, 8, 1, 4, 2, 8, 1, 4, 2, 8, 1, 4, 2, 8))
			user.dir = i
			sleep(1)
		user.dir = prev_dir

/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	restraint_check = TRUE
	mob_type_allowed_typelist = list(/mob/living, /mob/dead/observer)
	mob_type_blacklist_typelist = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/carbon/brain)
	mob_type_ignore_stat_typelist = list(/mob/dead/observer)

/datum/emote/spin/run_emote(mob/user)
	. = ..()
	if(.)
		user.speen()

/datum/emote/me
	key = "me"
	restraint_check = FALSE

/datum/emote/me/run_emote(mob/user, params, m_type)
	. = TRUE
	if (user.stat)
		return

	var/message = params

	if(copytext(message,1,5) == "says")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
		return
	else if(copytext(message,1,9) == "exclaims")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
		return
	else if(copytext(message,1,6) == "yells")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
		return
	else if(copytext(message,1,5) == "asks")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
		return

	var/msg = "<b>[user]</b> " + message

	var/turf/T = get_turf(user) // for pAIs

	for(var/mob/M in dead_mob_list)
		if (!M.client)
			continue //skip leavers
		if(isobserver(M) && M.client.prefs && (M.client.prefs.get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_GHOSTSIGHT) && !(M in viewers(user)))
			M.show_message(formatFollow(user) + " " + msg)

	if(emote_type & EMOTE_VISIBLE)
		user.visible_message(msg)
		if(!(emote_type & EMOTE_NO_RUNECHAT))
			for(var/mob/O in viewers(world.view, user))
				if(O.client && O?.client?.prefs.get_pref(/datum/preference_setting/toggle/mob_chat_on_map) && get_dist(O, user) < client_view_num(O?.client.view))
					O.create_chat_message(user, null, message, "", list("italics"))
	else if(emote_type & EMOTE_AUDIBLE)
		for(var/mob/O in get_hearers_in_view(world.view, user))
			O.show_message(msg)
			if(!(emote_type & EMOTE_NO_RUNECHAT))
				if(O.client && O?.client?.prefs.get_pref(/datum/preference_setting/toggle/mob_chat_on_map) && get_dist(O, user) < client_view_num(O?.client.view))
					O.create_chat_message(user, null, message, "", list("italics"))

	var/location = T ? "[T.x],[T.y],[T.z]" : "nullspace"
	log_emote("[user.name]/[user.key] (@[location]): [message]")

/datum/emote/doctos
	key = "doctos"
	key_third_person = "doctoses"
	message = "loudly screams \"DOCTOS\"."
	mob_type_allowed_typelist = list(/mob/living, /mob/dead/observer)

/datum/emote/doctos/run_emote(mob/user)
	. = ..()
	var/doctos_state = "normal"
	var/list/soundlist = list(
		'sound/voice/emotes/universal/doctos/doctos1.ogg',
		'sound/voice/emotes/universal/doctos/doctos2.ogg',
		'sound/voice/emotes/universal/doctos/doctos3.ogg',
		'sound/voice/emotes/universal/doctos/doctos4.ogg',
		'sound/voice/emotes/universal/doctos/doctos5.ogg',
		'sound/voice/emotes/universal/doctos/doctos6.ogg',
		'sound/voice/emotes/universal/doctos/doctos7.ogg',
		'sound/voice/emotes/universal/doctos/doctos8.ogg',
	)


	if (user.gender == FEMALE)
		// >mfw no skin tone in veegee
		// if(ishuman(user))
		// 	var/mob/living/carbon/human/H = user
		// 	H.skin_tone
		doctos_state = "female"
		soundlist = list(
			'sound/voice/emotes/universal/doctos/doctosfemale1.ogg',
			'sound/voice/emotes/universal/doctos/doctosfemale2.ogg',
			'sound/voice/emotes/universal/doctos/doctosfemale3.ogg'
		)
	else
		if (prob(1))
			doctos_state = "caveman"
			soundlist = list('sound/voice/emotes/universal/doctos/doctoscaveman.ogg')

	var/image/overlay = image(
		icon = 'icons/mob/emotes/universal/doctos.dmi',
		icon_state = "[doctos_state]",
		loc = user.loc,
		layer = ABOVE_HUD_PLANE,
		pixel_y = 32
	)
	overlay.alpha = 0

	// god knows what the guy who implemented this was doing!
	// is there a better way
	for (var/client/C in clients)
		C.images |= overlay

	animate(overlay, alpha = 255, time = 2)

	playsound(user, pick(soundlist), 30, FALSE)

	spawn(10)
		animate(overlay, alpha = 0, time = 2)
		spawn(2)
		for (var/client/C in clients)
			C.images -= overlay

/datum/emote/kek
	key = "kek"
	key_third_person = "keks"
	message = "keks."
	message_mime = "laughs like a frog."

/datum/emote/kek/run_emote(mob/user)
	. = ..()
	var/list/soundlist = list(
		'sound/voice/emotes/universal/kek/kek1.ogg',
		'sound/voice/emotes/universal/kek/kek2.ogg',
		'sound/voice/emotes/universal/kek/kek3.ogg',
		'sound/voice/emotes/universal/kek/kek4.ogg',
		'sound/voice/emotes/universal/kek/kek5.ogg',
		'sound/voice/emotes/universal/kek/kek6.ogg'
	)

	var/image/overlay = image(
		icon = 'icons/mob/emotes/universal/kek.dmi',
		icon_state = "kek",
		loc = user.loc,
		layer = ABOVE_HUD_PLANE,
		pixel_y = 32
	)
	overlay.alpha = 0

	for (var/client/C in clients)
		C.images |= overlay

	animate(overlay, alpha = 255, time = 2)

	playsound(user, pick(soundlist), 30, FALSE)

	spawn(10)
		animate(overlay, alpha = 0, time = 2)
		spawn(2)
		for (var/client/C in clients)
			C.images -= overlay

/datum/emote/geg
	key = "geg"
	key_third_person = "gegs"
	message = "gegs."
	message_mime = "laughs like a 'jakker."

/datum/emote/geg/run_emote(mob/user)
	. = ..()
	var/list/soundlist = list(
		'sound/voice/emotes/universal/geg/geg1.ogg',
		'sound/voice/emotes/universal/geg/geg2.ogg',
		'sound/voice/emotes/universal/geg/geg3.ogg',
		'sound/voice/emotes/universal/geg/geg4.ogg',
	)

	var/image/overlay = image(
		icon = 'icons/mob/emotes/universal/geg.dmi',
		icon_state = "geg",
		loc = user.loc,
		layer = ABOVE_HUD_PLANE,
		pixel_y = 32,
		pixel_x = 8
	)
	overlay.alpha = 0

	for (var/client/C in clients)
		C.images |= overlay

	animate(overlay, alpha = 255, time = 2)

	playsound(user, pick(soundlist), 30, FALSE)

	spawn(10)
		animate(overlay, alpha = 0, time = 2)
		spawn(2)
		for (var/client/C in clients)
			C.images -= overlay




/mob/proc/emote_dead(var/message)
	if(client.prefs.muted & MUTE_DEADCHAT)
		to_chat(src, "<span class='warning'>You cannot send deadchat emotes (muted).</span>")
		return

	if(!(client.prefs.get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_DEAD))
		to_chat(src, "<span class='warning'>You have deadchat muted.</span>")
		return

	var/input
	if(!message)
		input = copytext(sanitize(input(src, "Choose an emote to display.") as text|null), 1, MAX_MESSAGE_LEN)
	else
		input = message

	if(input)
		message = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <b>[src]</b> [message]</span>"
	else
		return


	if(message)
		for(var/mob/M in player_list)
			if(istype(M, /mob/new_player))
				continue

			if(M.client && M.client.holder && (M.client.holder.rights & R_ADMIN|R_MOD) && (M.client.prefs.get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_DEAD)) // Show the emote to admins/mods
				to_chat(M, message)

			else if(M.stat == DEAD && (M.client.prefs.get_pref(/datum/preference_setting/binary_flag/toggles) & CHAT_DEAD)) // Show the emote to regular ghosts with deadchat toggled on
				M.show_message(message, 2)
