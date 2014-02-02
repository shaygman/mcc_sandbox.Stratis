#define MCC_SANDBOX2_IDD 2000
#define MCC_EVAC_TYPE 2020
#define MCC_EVAC_CLASS 2021
#define MCC_EVAC_SELECTED 2022
disableSerialization;
private ["_evacArray","_insetionArray","_mccdialog","_option","_type","_class","_comboBox",
		 "_vehicleDisplayName","_displayname","_index","_countVehicles"];
_mccdialog = findDisplay MCC_SANDBOX2_IDD;	


if !mcc_isloading then {
	if (mcc_missionmaker == (name player)) then	{
		_option = _this select 0;
		_type 	= lbCurSel MCC_EVAC_TYPE;
		switch (_type) do		//Which evac do we want
		{
		case 0:			//Choppers
			{
				_evacArray = U_GEN_HELICOPTER;
			};
		case 1:			//Vehicles
			{
				_evacArray = U_GEN_CAR;
			};
		case 2:			//Tracked
			{
				_evacArray = U_GEN_TANK;
			};
		case 3:			//Ships
			{
				_evacArray = U_GEN_SHIP;
			};			
		};
		if ((lbCurSel MCC_EVAC_CLASS) == -1) exitWith {}; 
		MCCEvacHeliType = (_evacArray select (lbCurSel MCC_EVAC_CLASS)) select 1; 
		
		if (_option == 0) then {							//Spawn on LHD
			if (MCCLHDSpawned) then {
			hint "Evac Vehicle spawned on LHD";
			_pos = getmarkerpos "pos4";
			[[MCCEvacHeliType, _pos],"MCC_fnc_evacSpawn",false,false] spawn BIS_fnc_MP;
			mcc_safe = mcc_safe + FORMAT ["
										[['%1',%2],'MCC_fnc_evacSpawn',false,false] spawn BIS_fnc_MP;
										"								 
										, MCCEvacHeliType
										, _pos
										];
			} else {
					hint "LHD is not available, evac chopper can't be spawned"
				};
		};
		
		if (_option == 1) then {						//Spawn on land
		hint "click on map to spawn evac vechicle"; 
		onMapSingleClick " 	hint ""Evac Vehicle spawned.""; 
							[[MCCEvacHeliType, _pos],""MCC_fnc_evacSpawn"",false,false] spawn BIS_fnc_MP;
							mcc_safe=mcc_safe + FORMAT ['
								[[""%1"",%2],""MCC_fnc_evacSpawn"",false,false] spawn BIS_fnc_MP;
								sleep 1;'								 
								, MCCEvacHeliType
								, _pos
								];
							onMapSingleClick """";
							";
		};
	_countVehicles = count MCC_evacVehicles; 					//Wait until the vehicle is spawned
	waituntil {_countVehicles != count MCC_evacVehicles};
	_comboBox = _mccdialog displayCtrl MCC_EVAC_SELECTED;		//fill combobox Fly in Hight
	lbClear _comboBox;
		{
			if (alive _x) then	{
				_vehicleDisplayName 	= getText(configFile >> "CfgVehicles" >> typeof _x >> "displayname");
				_displayname 			= format ["%1, %2",_x,_vehicleDisplayName];
				_index 					= _comboBox lbAdd _displayname;
			} else {
				_displayname 			= "N/A";
				_index 					= _comboBox lbAdd _displayname;
				};
		} foreach MCC_evacVehicles;
	_comboBox lbSetCurSel MCC_evacVehicles_index;
	}	else {
			player globalchat "Access Denied"
		};
};	

