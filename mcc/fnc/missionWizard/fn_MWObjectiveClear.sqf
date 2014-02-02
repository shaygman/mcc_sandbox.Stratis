//======================================================MCC_fnc_MWObjectiveClear=========================================================================================================
// Create a clear area objective
// Example:[_objPos,_isCQB,_side,_faction] call MCC_fnc_MWObjectiveClear; 
// _objPos = position, objectice position
//_isCQB = Boolean, true - for CQB areay false if it doesn't matters. 
//_side = enemy side
//_faction = enemy Faction
// Return - nothing
//========================================================================================================================================================================================
private ["_objPos","_isCQB","_side","_faction","_preciseMarkers","_trg","_range","_doc","_sidePlayer","_name"];

_objPos = _this select 0;
_isCQB = _this select 1;
_side = _this select 2;
_faction = _this select 3;
_sidePlayer = _this select 4;
_preciseMarkers = _this select 5;

_name = format ["%1", ["MCCMWClearObjective_",1] call bis_fnc_counter]; 

if (_isCQB) then
{
	_range = 50;
	_array = [_objPos, 100] call MCC_fnc_MWFindbuildingPos;
	_objPos = getpos (([_objPos, 100] call MCC_fnc_MWFindbuildingPos) select 0);
	
}
else
{
	_range = 100;
	
	//Lets spawn an FOB
	_doc = ["o_fobSmall","o_fobLarge"] call BIS_fnc_selectRandom;
	_dummyObject =[_objPos, random 360,_doc] call MCC_fnc_objectMapper;
	waituntil {alive _dummyObject};
}; 

//Lets populate it
[_objPos,_range, 0, 2,_faction,str _side] call MCC_fnc_garrison;

sleep 2;

//Create Trigger
_trg= createTrigger["EmptyDetector",_objPos];
_trg setTriggerArea[_range,_range,0,false];
_trg setTriggerActivation [str _side, "NOT PRESENT",false];

//Create Marker
[[1, "ColorRed",[_range*1.5,_range*1.5], "ELLIPSE", "DiagGrid", "Empty", ("clearArea" + _name), _objPos],"MCC_fnc_makeMarker",true,false] spawn BIS_fnc_MP;

//Create Task
[_trg,"clear_area",_preciseMarkers] call MCC_fnc_MWCreateTask; 


//Waituntil there are no more enemy units in the area
[_trg,_name] spawn 
{
	private ["_trg"];
	_trg 		= _this select 0;
	_name		= _this select 1;
	
	while {!(triggeractivated _trg)} do {sleep 5}; 
	deleteVehicle _trg;
	[[2, "",[], "", "", "Empty", _name, []],"MCC_fnc_makeMarker",true,false] spawn BIS_fnc_MP;
};

/*
//Create logic Area
_dummyGroup = creategroup civilian; 
_area = _dummyGroup createunit ["LocationArea_F", [0, 90, 90],[],0.5,"NONE"];	
_area synchronizeObjectsAdd [_trg];

//Create logic sector
_zone = _dummyGroup createunit ["ModuleSector_F", [0, 90, 90],[],0.5,"NONE"];	
_zone setvariable ["Name",format ["Objective %1",_name],true];
_zone setvariable ["Designation","Objective",true];
_zone setvariable ["CostPlayers","0.1",true];

_zone synchronizeObjectsAdd [MCC_sideWest,MCC_sideEast,MCC_sideResistance,_area];




[_zone,_trg,_area,_dummyGroup,_sidePlayer] spawn 
{
	private ["_zone","_trg","_area","_dummyGroup","_sidePlayer"];
	_zone 		= _this select 0;
	_trg 		= _this select 1;
	_area 		= _this select 2;
	_dummyGroup = _this select 3;
	_sidePlayer = _this select 4;
	
	
	while {(_zone getvariable "owner") != _sidePlayer} do {sleep 1}; 
	sleep 10;
	deletevehicle _zone;
	deletevehicle _trg;
	deletevehicle _area;
	deletegroup _dummyGroup;
};
*/