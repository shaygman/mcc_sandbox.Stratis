//CAS Script by Shay_gman 08.01.12
private ["_ammount", "_spawnkind", "_pos", "_spawn", "_away", "_pilot1", "_pilotGroup1", "_wp", "_wp2", "_plane1", "_planepos",
		"_planeType", "_planeAltitude", "_target", "_fakeTarget", "_lasertargets", "_nukeType", "_bomb2", "_cas_name", "_poswp", "_distA","_distB", "_nul",
		"_loop","_x","_wp","_plane2","_pilot2","_pilotGroup2","_typeOfAircraft", "_distStart", "_distEngage", "_targetList", "_startTime", "_casMarker", "_casApproach"];
		
_ammount				= _this select 0;
_spawnkind				= _this select 1 select 0;
_pos					= _this select 2;
_planeType				= _this select 3 select 0;
_spawn					= _this select 4;
_away					= _this select 5;

//=====================================================

//start the drop
if (tolower _planeType in ["west","east","guer","civ","logic"]) then 		//If it's an airdrop
{
	//Lets Spawn a plane
	_plane1 			= ["I_Heli_Transport_02_F", _spawn, _pos, 100, true] call MCC_fnc_createPlane;		//Spawn plane 1 
	_pilotGroup1		= group _plane1;
	_pilot1				= driver _plane1;
	
	if (tolower _planeType == "east") then 
	{
		_plane1 setObjectTextureGlobal [0,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
		_plane1 setObjectTextureGlobal [1,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
		_plane1 setObjectTextureGlobal [2,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
	};
	
	if (tolower _planeType == "west") then
	{
		_plane1 setObjectTextureGlobal [0,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
		_plane1 setObjectTextureGlobal [1,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
		_plane1 setObjectTextureGlobal [2,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
	};	
	
	_wp = (group _plane1) addWaypoint [[_pos select 0, _pos select 1, 0], 0];	//Add WP
	_wp setWaypointStatements ["true", ""];
	_wp setWaypointType "MOVE";
	_wp setWaypointSpeed "FULL";
	_wp setWaypointCombatMode "BLUE";
	_wp setWaypointCompletionRadius 50;
	_plane1 flyInHeight 200;
		
	waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 400) || (!alive _plane1)};
	_plane1 animate ["CargoRamp_Open", 1];
	sleep 1;
	//Make the drop
	if (!alive _plane1) exitWith {}; 
	//Delete the plane when finished
	[_pilotGroup1, _pilot1, _plane1, _away] spawn MCC_fnc_deletePlane;
	for [{_x=0},{_x < count _spawnkind},{_x=_x+1}] do 
	{
		_planepos = getpos _plane1;
		[_planepos, _spawnkind select _x, _pilot1] spawn MCC_fnc_CreateAmmoDrop;
		sleep 3 + random 3;
	};
	
}	
else 
{	
	if ( ( _spawnkind == "Gun-run short" || _spawnkind == "Gun-run long") ) then
	{
	
		diag_log format ["gun-run: [%1]", _this];
		
		if ( _planeType isKindOf "Plane" ) then 
		{
			_distStart = 1900;
			_distEngage = 1800;
			_planeAltitude = 250;
			_typeOfAircraft = 1; //plane
		} 
		else
		{
			_distStart = 1400;
			_distEngage = 1000;
			_planeAltitude = 100;
			_typeOfAircraft = 0; //helicopter
		};
			
		//Lets Spawn a plane
		_plane1 			= [_planeType, _spawn, _pos, _planeAltitude, false] call MCC_fnc_createPlane;		//Spawn plane 1 
		_pilotGroup1		= group _plane1;
		_pilot1				= driver _plane1;
		
		//set CAS name based on plane number
		_cas_name = format ["%1 %2",["Venom","Viking","Beamer"] call BIS_fnc_selectRandom,(round(random 19)) + 1];
	
		//workaround to crash plane in rare case it doesn't return to spawn/end location
		_plane1 setFuel 0.1;
		
		_pilotGroup1 move _pos; //Set waypoint
		
		_pilotGroup1 setCombatMode "BLUE";
		_pilotGroup1 setSpeedMode "FULL";
		_pilotGroup1 setBehaviour "CARELESS";
		_plane1 disableAI "AUTOTARGET";
		_plane1 disableAI "TARGET";
		
		//remove heavy weapons to force gun only as much as possible
		_plane1 removeMagazine "24Rnd_missiles";
		_plane1 removeMagazine "12Rnd_PG_missiles";

		_pilot1 setskill 1;
		_plane1 setskill 1;
		
		_poswp = [_pos select 0,_pos select 1,0];
		
		_wp = _pilotGroup1 addWaypoint [_poswp, 0];
		[_pilotGroup1, 1] setWaypointType "MOVE";

		_casMarker = createMarkerLocal [_cas_name,_poswp];
		_casMarker setMarkerTypeLocal "MIL_TRIANGLE";
		_casMarker setMarkerSizeLocal [0.8, 1.4];
		_casMarker setMarkertextLocal "CAS";
		_casMarker setMarkerColorLocal "ColorRed";
		_casMarker setMarkerDirLocal (direction _plane1);
		
		_casApproach = true;
		
		while { ( ( alive _plane1 ) && ( _casApproach ) ) } do 
		{	
			sleep 5;
			_distA = getPosATL _plane1;
			sleep 3;
			_distB = getPosATL _plane1;
	
			if ( (_distA distance _distB) < 10 ) then 
			{
				// chopper got stuck and is hovering at same location, so trigger function again
				{ deleteWaypoint _x; } foreach waypoints _pilotGroup1;
				sleep 0.1;
				_poswp = [_pos select 0,_pos select 1,0];
		
				_wp = _pilotGroup1 addWaypoint [_poswp, 0];
				[_pilotGroup1, 1] setWaypointType "MOVE";
			};
	
			waitUntil {sleep 1;(_plane1 distance _poswp) < 2000};
			_pilotGroup1 setBehaviour "COMBAT";
			_pilotGroup1 setCombatMode "YELLOW";
			
			[playerSide,'HQ'] sideChat format ["%1 entering target area, ETA %2 seconds", _cas_name, round ((_plane1 distance _pos) / ((speed _plane1) * 0.25 ))];
		
			//make invisible target primary target
			//ACE invisible targets: http://freeace.wikkii.com/wiki/Class_Lists_for_ACE2
			
			if (((side _plane1) getFriend east) < 0.6) then // enemy
			{
				//create "EAST" target
				_fakeTarget = "B_TargetSoldier" createVehicle _pos;
				_fakeTarget addRating -3000;
			}
			else
			{
				//create "WEST" target
				_fakeTarget = "O_TargetSoldier" createVehicle _pos;
				_fakeTarget addRating -3000;
			};

			_target = _fakeTarget;
			
		
			//Create list of real vehicle targets in 60 m radius of the designated gun-run area
			_targetList = _pos nearEntities [ ["Tank", "Wheeled_APC", "StaticWeapon", "Truck"], 100];
	
			if ( (count _targetList) > 0 ) then 
			{ 
				// If real vehicle found assign that one as gun-run target
				[playerSide,'HQ'] sideChat format ["%1 Target List: [%2] - [%3]", _cas_name, typeOf (_targetList select 0), _targetList];
				_target = _targetList select 0;
			};

			waitUntil {sleep 0.5;(_plane1 distance _target) < _distStart};
			
			// trigger script to cancel attack and collect garbage after x time
			[_cas_name, _target, _spawnkind, _plane1, _planeType, _fakeTarget] execVM MCC_path + "mcc\general_scripts\cas\clear_gunrun_target.sqf";
						
			waitUntil {(_plane1 distance _target) < _distEngage};

			_pilotGroup1 reveal [_target, 4];

			sleep 0.3;

			_plane1 enableAI "TARGET";
			_pilotGroup1 setCombatMode "YELLOW";
	
			_plane1 doTarget _target;
			_pilot1 doTarget _target;
			gunner _plane1 doTarget _target;
			
			(_plane1 turretUnit [0]) doTarget _target;
			(_plane1 turretUnit [1]) doTarget _target;
			
			_casApproach = false;
		};

		while { ( damage _fakeTarget < 0.8 ) } do
		{	
			_plane1 doFire _target;
			(gunner _plane1) doFire _target;
			(_plane1 turretUnit [0]) doFire _target;
			(_plane1 turretUnit [1]) doFire _target;
			sleep 0.1;
		};

		//clear_gunrun_target.sqf should have set the damage of target to 1 now
		[playerSide,'HQ'] sideChat format ["%1 is leaving the area", _cas_name];
		
		_plane1 doWatch objNull;
		(gunner _plane1) doWatch objNull;
		(_plane1 turretUnit [0]) doWatch objNull;
		(_plane1 turretUnit [1]) doWatch objNull;
		
		{ deleteWaypoint _x; } foreach waypoints _pilotGroup1;

		_pilotGroup1 setCombatMode "BLUE"; // Never fire
		//_pilotGroup1 setCombatMode "GREEN"; // Hold fire - Defend only
		_pilotGroup1 setSpeedMode "FULL";
		_pilotGroup1 setBehaviour "CARELESS";
		_plane1 disableAI "AUTOTARGET";
		_plane1 disableAI "TARGET";

		if ( _spawnkind == "Gun-run long") then
		{	
			// make "away" the spawn position while plane is flying in that direction
			_away = _spawn;
		};
		
		// assign new target located at '_away' location to shift focus
		if (((side _plane1) getFriend east) < 0.6) then // enemy
		{
			//create "EAST" target
			_fakeTarget = "B_TargetSoldier" createVehicle _away;
		}
		else
		{
			//create "WEST" target
			_fakeTarget = "B_TargetSoldier" createVehicle _away;
		};
		
		_plane1 doTarget _fakeTarget;
		_pilot1 doTarget _fakeTarget;
		
		sleep 0.1;
		
		{_x disableAI "AUTOTARGET"} forEach  crew _plane1;
		{_x disableAI "TARGET"} forEach  crew _plane1;
		
		sleep 0.1;
		_pilotGroup1 move _away;
		sleep 0.1;
		_pilot1 domove _away;
		sleep 0.1;
		
		_casMarker setMarkerDirLocal (direction _plane1);
		_casMarker setMarkerPosLocal _away;
		_casMarker setMarkertextLocal "CAS Exit";
		
		// move plane away to delete it
		if ( _typeOfAircraft == 1 ) then //plane
		{
			sleep 5;
			[_pilotGroup1, _pilot1, _plane1, _away, 150] spawn MCC_fnc_deletePlane;
		}
		else // chopper
		{
			sleep 3; // otherwise chopper will halt, climb, and continue
			[_pilotGroup1, _pilot1, _plane1, _away, 100] spawn MCC_fnc_deletePlane;
		};

		sleep 10;

		_distA = getPosATL _plane1;
		sleep 3;
		_distB = getPosATL _plane1;
		
		if ( (_distA distance _distB) < 10 ) then 
		{
			// chopper got stuck and is hovering at same location, so trigger function again
			{ deleteWaypoint _x; } foreach waypoints _pilotGroup1;
			sleep 0.1;
			[_pilotGroup1, _pilot1, _plane1, _away, 100] spawn MCC_fnc_deletePlane;
		};

		waitUntil { sleep 2;!( alive _plane1 ) };
		deletemarkerlocal _casMarker;
		// clear invisible targets
		if (IsNil "_fakeTarget") then {_fakeTarget = objNull};deleteVehicle _fakeTarget;
	}
	else		
	{
		//Lets Spawn a plane
		_plane1 			= [_planeType, _spawn, _pos, 150, false] call MCC_fnc_createPlane;		//Spawn plane 1 
		_pilotGroup1		= group _plane1;
		_pilot1				= driver _plane1;

		_plane2 			= [_planeType, _spawn, _pos, 150, false] call MCC_fnc_createPlane;		//Spawn plane 2 
		_pilotGroup2		= group _plane2;
		_pilot2				= driver _plane2;

		[_plane2] joinsilent _pilotGroup1;														//Join them together
		
		_wp = _pilotGroup1 addWaypoint [[_pos select 0, _pos select 1, 0], 0];	//Add WP
		_wp setWaypointStatements ["true", ""];
		_wp setWaypointSpeed "NORMAL";
		_wp setWaypointCompletionRadius 100;	
		
		if (_spawnkind == "S&D") then	{			//Set WP behaviour
			_wp setWaypointType "SAD";
			_wp setWaypointCombatMode "RED";
			}	else	{
				_wp setWaypointType "MOVE";
				_wp setWaypointCombatMode "BLUE";
				};
				
		switch (_spawnkind) do 
		{
			case "S&D":	//Seek and Destroy
			{
				 waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 2000) || (!alive _plane1)};
				_pilotGroup1 setSpeedMode "FULL";
				_pilotGroup1 setCombatMode "RED";
				_pilotGroup1 setBehaviour "COMBAT";
				_plane1 enableAI "AUTOTARGET";
				sleep 120;
			};
		
		   case "JDAM":	//JDAM Bomb
		   { 
		   waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 500) || (!alive _plane1)};
		   _nul=[_pos, getpos _plane1,"Bo_GBU12_LGB",100,false,""] execVM MCC_path + "mcc\general_scripts\CAS\missile_guide.sqf"
		   };
			
		   case "LGB":    //LGB 
			{  
			waitUntil {((_plane1 distance _pos) < 1000) || (!alive _plane1)}; 
			_lasertargets = nearestObjects[_pos,["LaserTarget"],1000]; 
			if (!isnull (_lasertargets select 0)) then 
				{ 
				_pos = getpos (_lasertargets select 0); 
				waitUntil {((_plane1 distance[_pos select 0, _pos select 1, 200]) < 300) || (!alive _plane1)}; 
				_nul=[(_lasertargets select 0), getpos _plane1,"Bo_GBU12_LGB",100,false,""] execVM MCC_path + "mcc\general_scripts\CAS\missile_guide.sqf" 
				}; 
			}; 
			
			case "Bombing-run":	//Bombing run
			{ 
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 400) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do 
					{
						_bomb = "Bo_Mk82" createvehicle [getpos _plane1 select 0,getpos _plane1 select 1,3000]; 	//make the bomb 
						_bomb setpos [getpos _plane1 select 0,(getpos _plane1 select 1)-4,(getpos _plane1 select 2) -2];
						_bomb setdir getdir _plane1;
						[[[netid _bomb,_bomb], format["bon_Shell_In_v0%1",[1,2,3,4,5,6,7] select round random 6]], "MCC_fnc_globalSay3D", true, false] spawn BIS_fnc_MP;
						sleep 0.25;
						_bomb setVelocity [((velocity vehicle _pilot1) select 0)/3, ((velocity vehicle _pilot1) select 1)/3,-30];
						_bomb2 = "Bo_Mk82" createvehicle [getpos _plane1 select 0,getpos _plane1 select 1,3000]; 	//make the bomb 
						_bomb2 setpos [getpos _plane1 select 0,(getpos _plane1 select 1)+4,(getpos _plane1 select 2) -2];
						_bomb2 setdir getdir _plane1;
						_bomb2 setVelocity [((velocity vehicle _pilot1) select 0)/3, ((velocity vehicle _pilot1) select 1)/3,-30];
						[[[netid _bomb2,_bomb2], format["bon_Shell_In_v0%1",[1,2,3,4,5,6,7] select round random 6]], "MCC_fnc_globalSay3D", true, false] spawn BIS_fnc_MP;
						sleep 0.25;
					};
			};
			
			case "Rockets-run":	//Rockets run
			{ 
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 800) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do 
					{
						_nul=[[(_pos select 0)+50 - random 100,(_pos select 1)+50 - random 100,_pos select 2], getpos _plane1,"M_AT",200,true,""] execVM MCC_path + "mcc\general_scripts\CAS\missile_guide.sqf";
						[[[netid _plane1,_plane1], "missileLunch"], "MCC_fnc_globalSay3D", true, false] spawn BIS_fnc_MP;
						sleep 0.6;
						_nul=[[(_pos select 0)+50 - random 100,(_pos select 1)+50 - random 100,_pos select 2], getpos _plane1,"M_AT",200,true,""] execVM MCC_path + "mcc\general_scripts\CAS\missile_guide.sqf";
						[[[netid _plane1,_plane1], "missileLunch"], "MCC_fnc_globalSay3D", true, false] spawn BIS_fnc_MP;
						sleep 0.6;
					};
			};
			
			case "AT run":	//S&D Armor
			{ 
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 800) || (!alive _plane1)};
				_targets = nearestObjects [[_pos select 0,_pos select 1,0] ,["Car","Tank"],200];	//Find targets: cars or tanks
				_x = 0;
				_loop = true; 
				while {_loop} do {
					if (_x<count _targets && _x < _ammount) then {
						_nul=[_targets select _x, getpos _plane1,"M_PG_AT",200,true,""] execVM  MCC_path + "mcc\general_scripts\CAS\missile_guide.sqf";
						sleep 1;
						_x = _x +1;
						} else {_loop = false};
					};
			};
			
			case "AA run":	//S&D Air
			{ 
				_plane1 flyInHeight 150;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 1500) || (!alive _plane1)};
				_targets = nearestObjects [[_pos select 0,_pos select 1,0] ,["Helicopter","Plane"],1000];	//Find targets: cars or tanks
				_x = 0;
				_loop = true; 
				while {_loop} do {
					if (_x<count _targets && _x < _ammount) then {
						_nul=[_targets select _x, getpos _plane1,"M_PG_AT",200,true,""] execVM  MCC_path + "mcc\general_scripts\CAS\missile_guide.sqf";
						sleep 1;
						_x = _x +1;
						} else {_loop = false};
					};
			};
			
			case "CBU-97(ACE)":	//MCC_fnc_CBU-97
			{ 
				_plane1 flyInHeight 150;
				_plane1 addWeapon "ACE_CBU97_Bomblauncher";
				for [{_i=1},{_i<=_ammount},{_i=_i+1}] do 
					{
						_plane1 addMagazine "ACE_CBU97";
					};
				_planepos = getpos _plane1;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 150]) < 700) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do 
					{
						_plane1 Fire ["ACE_CBU97_Bomblauncher"];
						sleep 1;
					};
			};
			
			case "CBU-87(ACE)":	//MCC_fnc_CBU-AP
			{ 
				_plane1 addWeapon "ACE_CBU87_Bomblauncher";
				for [{_i=1},{_i<=_ammount},{_i=_i+1}] do 
					{
						_plane1 addMagazine "ACE_CBU87";
					};
				_planepos = getpos _plane1;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 100]) < 800) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do 
					{
						_plane1 Fire ["ACE_CBU87_Bomblauncher"];
						sleep 1;
					};
			};
		
			case "BLU-107(ACE)":	//BLU-107
			{ 
				_plane1 flyInHeight 200;
				_plane1 addWeapon "ACE_BLU107_Bomblauncher";
				for [{_i=1},{_i<=_ammount},{_i=_i+1}] do 
					{
						_plane1 addMagazine "ACE_BLU107";
					};
				_planepos = getpos _plane1;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 150]) < 800) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do 
					{
						_plane1 Fire ["ACE_BLU107_Bomblauncher"];
						sleep 0.5;
					};
			};
			
			case "SADARM":	//MCC_fnc_SADARM
			{ 
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 200) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do 
					{
						_planepos = getpos _plane1;
						[_planepos, _pilot1] spawn MCC_fnc_SADARM;
						sleep 0.5 + random 0.5;
					};
			};
			
			case "CBU-Mines":	//MCC_fnc_CBU-Mines
			{ 
				CBU_type = MCC_CBU_MINES;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 200) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do 
					{
						_planepos = getpos _plane1;
						_bomb = "CruiseMissile2" createvehicle [_planepos select 0,_planepos select 1,3000]; 	//make the bomb 
						_bomb setpos [_planepos select 0,_planepos select 1,(_planepos select 2) -10];
						_bomb setdir getdir _plane1;
						_bomb setVelocity [((velocity vehicle _pilot1) select 0)/2, ((velocity vehicle _pilot1) select 1)/2,((velocity vehicle _pilot1) select 2)];
						[_bomb, CBU_type] spawn MCC_fnc_CBU;
						sleep 0.5 + random 0.5;
					};
			};
			
			case "CBU-WP(ACE)":	//MCC_fnc_CBU-Mines
			{ 
				CBU_type = MCC_CBU_WP;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 200) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do 
					{
						_planepos = getpos _plane1;
						_bomb = "CruiseMissile2" createvehicle [_planepos select 0,_planepos select 1,3000]; 	//make the bomb 
						_bomb setpos [_planepos select 0,_planepos select 1,(_planepos select 2) -10];
						_bomb setdir getdir _plane1;
						_bomb setVelocity [((velocity vehicle _pilot1) select 0)/2, ((velocity vehicle _pilot1) select 1)/2,((velocity vehicle _pilot1) select 2)];
						[_bomb, CBU_type] spawn MCC_fnc_CBU;
						sleep 0.5 + random 0.5;
					};
			};
			
			case "CBU-CS(ACE)":	//MCC_fnc_CBU-Mines
			{ 
				CBU_type = MCC_CBU_CS;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 200) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do 
					{
						_planepos = getpos _plane1;
						_bomb = "CruiseMissile2" createvehicle [_planepos select 0,_planepos select 1,3000]; 	//make the bomb 
						_bomb setpos [_planepos select 0,_planepos select 1,(_planepos select 2) -10];
						_bomb setdir getdir _plane1;
						_bomb setVelocity [((velocity vehicle _pilot1) select 0)/2, ((velocity vehicle _pilot1) select 1)/2,((velocity vehicle _pilot1) select 2)];
						[_bomb, CBU_type] spawn MCC_fnc_CBU;
						sleep 0.5 + random 0.5;
					};
			};
			
			case "Tactical MCC_NUKE(0.3k)":	//Tactical MCC_NUKE(0.3k)
			{ 
				_nukeType = "ACE_B61_03";
				[_plane1, _pos, _nukeType] spawn MCC_NUKE;					
			};
			
			case "Tactical MCC_NUKE(1.5k)":	//Tactical MCC_NUKE(1.5k)
			{ 
				_nukeType = "ACE_B61_15";
				[_plane1, _pos, _nukeType] spawn MCC_NUKE;					
			};
			
			case "Tactical MCC_NUKE(5.0k)":	//"Tactical MCC_NUKE(5.0k)"
			{ 
				_nukeType = "ACE_B61_50";
				[_plane1, _pos, _nukeType] spawn MCC_NUKE;					
			};
			
			case "Air Burst(0.3k)":	//Tactical MCC_NUKE(0.3k) MCC_NUKE_AIR
			{ 
				_nukeType = "ACE_B61_03";
				[_plane1, _pos, _nukeType] spawn MCC_NUKE_AIR;					
			};
			
			case "Air Burst(1.5k)":	//Tactical MCC_NUKE(1.5k) MCC_NUKE_AIR
			{ 
				_nukeType = "ACE_B61_15";
				[_plane1, _pos, _nukeType] spawn MCC_NUKE_AIR;					
			};
			
			case "Air Burst(5.0k)":	//Tactical MCC_NUKE(5.0k) MCC_NUKE_AIR
			{ 
				_nukeType = "ACE_B61_50";
				[_plane1, _pos, _nukeType] spawn MCC_NUKE_AIR;					
			}			
		};
		//Delete the plane when finished
		
		[_pilotGroup1, _pilot1, _plane1, _away] call MCC_fnc_deletePlane;
		[_pilotGroup2, _pilot2, _plane2, _away] call MCC_fnc_deletePlane;
	};
};

