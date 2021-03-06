mtype = {ENTER, EXIT} ;
chan to_monitor = [2] of {mtype, chan} ;

active proctype Monitor() {
	chan reply ;
	chan blocked ;
	bool inuse = false ;
	bool haveblocked = false ;
	
	do
	:: to_monitor ? ENTER, reply ->
		if
		:: inuse ->
			blocked = reply ; 
			haveblocked = true ;
		:: ! inuse ->
			inuse = true ;
			reply ! true ;
		fi ;
	:: to_monitor ? EXIT, reply  ->
		if
		:: haveblockedd ->
			blocked ! true ;
			haveblocked = false ;
		:: ! haveblocked ->
			inuse = false ;
		fi ;
		reply ! true ;
	od ;
}

active[2] proctype User() {
	chan response = [0] of { bool } ;

	do
	::
		/* Outside CS */
		skip ;

		/* Enter CS */
		to_monitor ! Enter, response ;
		response ? _ ;

		printf("U%d in CS\n", _pid) ;
		skip ;
		printf("U%d exiting CS\n", _pid) ;

		/* Exit CS */
		to_monitor ! EXIT, response ;
		response ? _ ;

		/* Outside CS */
		skip ;
	od ;
}