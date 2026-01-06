// points per minute
#define DROPSHIP_POINT_RATE 18 * ((6 - GLOB.current_orbit)/3)
#define SUPPLY_POINT_RATE 20 * (GLOB.current_orbit/3)

/// How much points we charge for fast delivery
#define FAST_DELIVERY_COST 150

SUBSYSTEM_DEF(points)
	name = "Points"

	priority = FIRE_PRIORITY_POINTS
	flags = SS_KEEP_TIMING

	wait = 10 SECONDS
	var/dropship_points = 0
	///Assoc list of supply points
	var/supply_points = list()
	///Assoc list of xeno points: xeno_points_by_hive["hivenum"]
	var/list/xeno_points_by_hive = list()

	var/ordernum = 1					//order number given to next order

	var/list/supply_packs = list()
	var/list/supply_packs_ui = list()
	var/list/supply_packs_contents = list()

	///Assoc list of item ready to be sent, categorised by faction
	var/list/shoppinglist = list()
	var/list/shopping_history = list()
	var/list/shopping_cart = list()
	var/list/export_history = list()
	var/list/requestlist = list()
	var/list/deniedrequests = list()
	var/list/approvedrequests = list()

	var/list/request_shopping_cart = list()

//Это явно должно быть выше, поправьте если разберётесь.
/datum/controller/subsystem/points
	///Assoc list of personal supply points
	var/personal_supply_points = list()
	///Personal supply points limit
	var/psp_limit = 600
	///Personal supply points base gain per update
	var/psp_base_gain = 5 //per minute
	///Used to delay fast delivery and for animation
	var/fast_delivery_is_active = TRUE
	///Reference to the balloon vis obj effect
	var/atom/movable/vis_obj/fulton_balloon/balloon
	var/obj/effect/fulton_extraction_holder/holder_obj

/datum/controller/subsystem/points/Recover()
	ordernum = SSpoints.ordernum
	supply_packs = SSpoints.supply_packs
	supply_packs_ui = SSpoints.supply_packs_ui
	supply_packs_contents = SSpoints.supply_packs_contents
	shoppinglist = SSpoints.shoppinglist
	shopping_history = SSpoints.shopping_history
	shopping_cart = SSpoints.shopping_cart
	export_history = SSpoints.export_history
	requestlist = SSpoints.requestlist
	deniedrequests = SSpoints.deniedrequests
	approvedrequests = SSpoints.approvedrequests
	request_shopping_cart = SSpoints.request_shopping_cart

/datum/controller/subsystem/points/Initialize()
	ordernum = rand(1, 9000)
	balloon = new()
	holder_obj = new()
	return SS_INIT_SUCCESS

/// Prepare the global supply pack list at the gamemode start
/datum/controller/subsystem/points/proc/prepare_supply_packs_list(is_mode_crash = FALSE)
	for(var/pack in subtypesof(/datum/supply_packs))
		var/datum/supply_packs/P = pack
		if(!initial(P.cost))
			continue
		if(is_mode_crash && P.crash_restricted)
			continue
		P = new pack()
		if(!P.contains)
			continue
		supply_packs[pack] = P
		LAZYADD(supply_packs_ui[P.group], pack)
		var/list/containsname = list()
		for(var/i in P.contains)
			var/atom/movable/path = i
			if(!path)
				continue
			if(!containsname[path])
				containsname[path] = list("name" = initial(path.name), "count" = 1)
			else
				containsname[path]["count"]++
		supply_packs_contents[pack] = list("name" = P.name, "item_notes" = P.notes, "container_name" = initial(P.containertype.name), "cost" = P.cost, "contains" = containsname)

/datum/controller/subsystem/points/fire(resumed = FALSE)
	if(iscrashgamemode(SSticker?.mode))
		return

	dropship_points += DROPSHIP_POINT_RATE / (1 MINUTES / wait)

	var/current_supply_point_rate = SUPPLY_POINT_RATE / (1 MINUTES / wait)
	for(var/key in supply_points)
		supply_points[key] += current_supply_point_rate
		if(key == FACTION_TERRAGOV)
			GLOB.round_statistics.points_from_orbit += current_supply_point_rate

	for(var/key in supply_points)
		for(var/mob/living/account in GLOB.alive_human_list_faction[key])
			if(account.job.title in GLOB.jobs_marines)
				personal_supply_points[account.ckey] = min(personal_supply_points[account.ckey] + (psp_base_gain / (1 MINUTES / wait)), psp_limit)

/datum/controller/subsystem/points/proc/buy_using_psp(mob/living/user)
	var/cost = 0
	var/list/ckey_shopping_cart = request_shopping_cart[user.ckey]
	if(!length_char(ckey_shopping_cart))
		return
	if(length_char(ckey_shopping_cart) > 20)
		return
	for(var/i in ckey_shopping_cart)
		var/datum/supply_packs/SP = supply_packs[i]
		cost += SP.cost * ckey_shopping_cart[i]
	if(cost > personal_supply_points[user.ckey])
		return
	var/list/datum/supply_order/orders = process_cart(user, ckey_shopping_cart)
	for(var/i in 1 to length_char(orders))
		orders[i].authorised_by = user.real_name
		LAZYADDASSOCSIMPLE(shoppinglist[user.faction], "[orders[i].id]", orders[i])
	personal_supply_points[user.ckey] -= cost
	ckey_shopping_cart.Cut()

/datum/controller/subsystem/points/proc/fast_delivery(datum/supply_order/our_order, mob/living/user)
	var/list/beacon_list = GLOB.supply_beacon.Copy()
	for(var/beacon_name in beacon_list)
		var/datum/supply_beacon/beacon = beacon_list[beacon_name]
		if(!is_ground_level(beacon.drop_location.z))
			beacon_list -= beacon_name
			continue // does this continue even does something?
	var/datum/supply_beacon/supply_beacon = beacon_list[tgui_input_list(user, "Select the beacon to send supplies", "Beacon choice", beacon_list)]
	if(!istype(supply_beacon))
		to_chat(user, span_warning("Beacon was not selected"))
		return

	if(!fast_delivery_is_active)
		to_chat(user, span_warning("Fast delivery is not ready"))
		return FALSE
	if(!iscrashgamemode(SSticker.mode)) // no RO on crash
		if(FAST_DELIVERY_COST > supply_points[our_order.faction])
			to_chat(user, span_warning("Cargo does not have enough points for fast delivery."))
			return

		supply_points[user.faction] -= FAST_DELIVERY_COST

	//Same checks as for supply console
	if(!supply_beacon)
		to_chat(user, span_warning("There was an issue with that beacon. Check it's still active."))
		return
	if(!istype(supply_beacon.drop_location))
		to_chat(user, span_warning("The [supply_beacon.name] was not detected on the ground."))
		return
	if(isspaceturf(supply_beacon.drop_location) || supply_beacon.drop_location.density)
		to_chat(user, span_warning("The [supply_beacon.name]'s landing zone appears to be obstructed or out of bounds."))
		return

	//Just in case
	if(!length_char(SSpoints.shoppinglist[our_order.faction]))
		return

	//Finally create the supply box

	var/turf/TC = locate(supply_beacon.drop_location.x, supply_beacon.drop_location.y, supply_beacon.drop_location.z)

	//spawn crate and clear shoping list
	delivery_to_turf(our_order, TC)

	//effects
	supply_beacon.drop_location.visible_message(span_boldnotice("A supply drop appears suddendly!"))
	playsound(supply_beacon.drop_location,'sound/effects/tadpolehovering.ogg', 30, TRUE)

/datum/controller/subsystem/points/proc/delivery_to_turf(datum/supply_order/our_order, turf/TC)
	var/datum/supply_packs/firstpack = our_order.pack[1]

	var/obj/structure/crate_type = firstpack.containertype || firstpack.contains[1]

	var/obj/structure/A = new crate_type(null)
	if(firstpack.containertype)
		A.name = "Order #[our_order.id] for [our_order.orderer]"

	var/list/contains = list()
	//spawn the stuff, finish generating the manifest while you're at it
	for(var/P in our_order.pack)
		var/datum/supply_packs/SP = P
		// yes i know
		if(SP.access)
			A.req_access = list()
			A.req_access += text2num(SP.access)

		if(SP.randomised_num_contained)
			if(length_char(SP.contains))
				for(var/j in 1 to SP.randomised_num_contained)
					contains += pick(SP.contains)
		else
			contains += SP.contains

	for(var/typepath in contains)
		if(!typepath)
			continue
		if(!firstpack.containertype)
			break
		new typepath(A)

	SSpoints.shoppinglist[our_order.faction] -= "[our_order.id]"
	SSpoints.shopping_history += our_order

	//animate delivery

	holder_obj.appearance = A.appearance
	holder_obj.forceMove(TC)

	balloon.icon_state = initial(balloon.icon_state)
	holder_obj.vis_contents += balloon

	addtimer(CALLBACK(src, PROC_REF(end_fast_delivery), A, TC), 3 SECONDS)

	flick("fulton_expand", balloon)
	balloon.icon_state = "fulton_balloon"

	holder_obj.pixel_z = 360
	animate(holder_obj, 3 SECONDS, pixel_z = 0)

/datum/controller/subsystem/points/proc/end_fast_delivery(atom/movable/A, turf/TC)
	A.forceMove(TC)
	holder_obj.moveToNullspace()
	holder_obj.pixel_z = initial(A.pixel_z)
	holder_obj.vis_contents -= balloon
	balloon.icon_state = initial(balloon.icon_state)
	fast_delivery_is_active = TRUE

///Add amount of psy points to the selected hive only if the gamemode support psypoints
/datum/controller/subsystem/points/proc/add_psy_points(hivenumber, amount)
	if(!CHECK_BITFIELD(SSticker.mode.round_type_flags, MODE_PSY_POINTS))
		return
	xeno_points_by_hive[hivenumber] += amount

/datum/controller/subsystem/points/proc/approve_request(datum/supply_order/O, mob/living/user)
	var/cost = 0
	for(var/i in O.pack)
		var/datum/supply_packs/SP = i
		cost += SP.cost
	if(cost > supply_points[user.faction])
		return
	var/obj/docking_port/mobile/supply_shuttle = SSshuttle.getShuttle(SHUTTLE_SUPPLY)
	if(length(shoppinglist[O.faction]) >= supply_shuttle.return_number_of_turfs())
		return
	requestlist -= "[O.id]"
	deniedrequests -= "[O.id]"
	approvedrequests["[O.id]"] = O
	O.authorised_by = user.real_name
	supply_points[user.faction] -= cost
	LAZYADDASSOCSIMPLE(shoppinglist[O.faction], "[O.id]", O)
	if(GLOB.directory[O.orderer])
		to_chat(GLOB.directory[O.orderer], span_notice("Your request [O.id] has been approved!"))
	if(GLOB.personal_statistics_list[O.orderer_ckey])
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[O.orderer_ckey]
		personal_statistics.req_points_used += cost

/datum/controller/subsystem/points/proc/deny_request(datum/supply_order/O)
	requestlist -= "[O.id]"
	deniedrequests["[O.id]"] = O
	O.authorised_by = "denied"
	if(GLOB.directory[O.orderer])
		to_chat(GLOB.directory[O.orderer], span_notice("Your request [O.id] has been denied!"))

/datum/controller/subsystem/points/proc/copy_order(datum/supply_order/O)
	var/datum/supply_order/NO = new
	NO.id = ++ordernum
	NO.orderer_ckey = O.orderer_ckey
	NO.orderer = O.orderer
	NO.orderer_rank = O.orderer_rank
	NO.faction = O.faction
	return NO

/datum/controller/subsystem/points/proc/process_cart(mob/living/user, list/cart)
	. = list()
	var/datum/supply_order/O = new
	O.id = ++ordernum
	O.orderer_ckey = user.ckey
	O.orderer = user.real_name
	O.pack = list()
	O.faction = user.faction
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		O.orderer_rank = H.get_assignment()
	var/list/access_packs = list()
	for(var/i in cart)
		var/datum/supply_packs/SP = supply_packs[i]
		for(var/num in 1 to cart[i])
			if(SP.containertype != null)
				if(SP.access)
					LAZYADD(access_packs["[SP.access]"], SP)
				else
					O.pack += SP
				continue
			var/datum/supply_order/NO = copy_order(O)
			NO.pack = list(SP)
			. += NO

	for(var/access in access_packs)
		var/datum/supply_order/AO = copy_order(O)
		AO.pack = list()
		. += AO
		for(var/pack in access_packs[access])
			AO.pack += pack

	if(length(O.pack))
		. += O
	else
		qdel(O)

/datum/controller/subsystem/points/proc/buy_cart(mob/living/user)
	var/cost = 0
	for(var/i in shopping_cart)
		var/datum/supply_packs/SP = supply_packs[i]
		cost += SP.cost * shopping_cart[i]
	if(cost > supply_points[user.faction])
		return
	var/list/datum/supply_order/orders = process_cart(user, shopping_cart)
	for(var/i in 1 to length(orders))
		orders[i].authorised_by = user.real_name
		LAZYADDASSOCSIMPLE(shoppinglist[user.faction], "[orders[i].id]", orders[i])
	supply_points[user.faction] -= cost
	shopping_cart.Cut()

/datum/controller/subsystem/points/proc/submit_request(mob/living/user, reason)
	var/list/ckey_shopping_cart = request_shopping_cart[user.ckey]
	if(!length(ckey_shopping_cart))
		return
	if(length(ckey_shopping_cart) > 20)
		return
	if(NON_ASCII_CHECK(reason))
		return
	if(length(reason) > MAX_LENGTH_REQ_REASON)
		reason = copytext(reason, 1, MAX_LENGTH_REQ_REASON)
	var/list/datum/supply_order/orders = process_cart(user, ckey_shopping_cart)
	for(var/i in 1 to length(orders))
		orders[i].reason = reason
		requestlist["[orders[i].id]"] = orders[i]
	ckey_shopping_cart.Cut()
