
/datum/money_account
	var/owner_name = ""
	var/account_number = 0
	var/remote_access_pin = 0
	var/money = 0
	var/list/transaction_log = list()
	var/suspended = 0
	var/security_level = 0	//0 - auto-identify from worn ID, require only account number
							//1 - require manual login / account number and pin
							//2 - require card and manual login
	var/offmap = FALSE //Should this account be hidden from station consoles?

/datum/transaction
	var/target_name = ""
	var/purpose = ""
	var/amount = 0
	var/date = ""
	var/time = ""
	var/source_terminal = ""

/proc/create_account(var/new_owner_name = "Default user", var/starting_funds = 0, var/obj/machinery/account_database/source_db, var/offmap = FALSE)

	//create a new account
	var/datum/money_account/M = new()
	M.offmap = offmap
	M.owner_name = new_owner_name
	M.remote_access_pin = rand(1111, 111111)
	M.money = starting_funds

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = new_owner_name
	T.purpose = "Account creation"
	T.amount = starting_funds
	if(!source_db)
		//set a random date, time and location some time over the past few decades
		T.date = "[num2text(rand(1,28))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], 23[rand(12,19)]"
		T.time = "[rand(0,24)]:[rand(11,59)]"
		T.source_terminal = "NTGalaxyNet Terminal #[rand(111,1111)]"

		M.account_number = rand(111111, 999999)
	else
		T.date = GLOB.current_date_string
		T.time = stationtime2text()
		T.source_terminal = source_db.machine_id

		M.account_number = GLOB.next_account_number
		GLOB.next_account_number += rand(1,25)

		//create a sealed package containing the account details
		var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(source_db.loc)

		var/obj/item/paper/R = new /obj/item/paper(P)
		P.wrapped = R
		R.name = "Account information: [M.owner_name]"
		R.info = span_bold("Account details (confidential)") + "<br><hr><br>"
		R.info += "<i>Account holder:</i> [M.owner_name]<br>"
		R.info += "<i>Account number:</i> [M.account_number]<br>"
		R.info += "<i>Account pin:</i> [M.remote_access_pin]<br>"
		R.info += "<i>Starting balance:</i> $[M.money]<br>"
		R.info += "<i>Date and time:</i> [stationtime2text()], [GLOB.current_date_string]<br><br>"
		R.info += "<i>Creation terminal ID:</i> [source_db.machine_id]<br>"
		R.info += "<i>Authorised NT officer overseeing creation:</i> [source_db.held_card.registered_name]<br>"

		//stamp the paper
		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		stampoverlay.icon_state = "paper_stamp-cent"
		if(!R.stamped)
			R.stamped = new
		R.stamped += /obj/item/stamp
		R.add_overlay(stampoverlay)
		R.stamps += "<HR><i>This paper has been stamped by the Accounts Database.</i>"

	//add the account
	M.transaction_log.Add(T)
	GLOB.all_money_accounts.Add(M)

	return M

/proc/charge_to_account(var/attempt_account_number, var/source_name, var/purpose, var/terminal_id, var/amount)
	for(var/datum/money_account/D in GLOB.all_money_accounts)
		if(D.account_number == attempt_account_number && !D.suspended)
			D.money += amount

			//create a transaction log entry
			var/datum/transaction/T = new()
			T.target_name = source_name
			T.purpose = purpose
			if(amount < 0)
				T.amount = "([amount])"
			else
				T.amount = "[amount]"
			T.date = GLOB.current_date_string
			T.time = stationtime2text()
			T.source_terminal = terminal_id
			D.transaction_log.Add(T)

			return 1

	return 0

//this returns the first account datum that matches the supplied accnum/pin combination, it returns null if the combination did not match any account
/proc/attempt_account_access(var/attempt_account_number, var/attempt_pin_number, var/security_level_passed = 0)
	for(var/datum/money_account/D in GLOB.all_money_accounts)
		if(D.account_number == attempt_account_number)
			if( D.security_level <= security_level_passed && (!D.security_level || D.remote_access_pin == attempt_pin_number) )
				return D
			break

/proc/get_account(var/account_number)
	for(var/datum/money_account/D in GLOB.all_money_accounts)
		if(D.account_number == account_number)
			return D

//Performing purchases by ID card
/proc/purchase_with_id_card(obj/item/card/id/I, mob/M, var/purchase_title = "Company", var/purchase_terminal = "Terminal", var/purchase_desc = "Purchase of Something", var/price = 0)
	// Check if account can pay at all
	var/datum/money_account/customer_account = get_account(I.associated_account_number)
	if(!customer_account)
		to_chat(M, span_warning("Error: Unable to access account. Please contact technical support if problem persists."))
		return FALSE
	if(customer_account.suspended)
		to_chat(M, span_warning("Unable to access account: account suspended."))
		return FALSE
	// Have the customer punch in the PIN before checking if there's enough money. Prevents people from figuring out acct is
	// empty at high security levels
	if(customer_account.security_level != 0) //If card requires pin authentication (ie seclevel 1 or 2)
		var/attempt_pin = tgui_input_number(M, "Enter pin code", "Vendor transaction")
		customer_account = attempt_account_access(I.associated_account_number, attempt_pin, 2)
		if(!customer_account)
			to_chat(M, span_warning("Unable to access account: incorrect credentials."))
			return FALSE
	if(price > customer_account.money)
		to_chat(M, span_warning("Insufficient funds in account."))
		return FALSE
	// debit money from the purchaser's account
	customer_account.money -= price
	// create entry in the purchaser's account log
	var/datum/transaction/T = new()
	T.target_name = "[purchase_title] (via [purchase_terminal])"
	T.purpose = purchase_desc
	if(price > 0)
		T.amount = "([price])"
	else
		T.amount = "[price]"
	T.source_terminal = purchase_terminal
	T.date = GLOB.current_date_string
	T.time = stationtime2text()
	// Okay to move the money at this point
	customer_account.transaction_log.Add(T)
	return TRUE
