//======================================================MCC_fnc_MWSpawnInfantry=========================================================================================================
// Spawn infantry groups in the zone. 
// Example:[_totalEnemyUnits,_zoneNumber] call MCC_fnc_MWSpawnInfantry; 
// Return - handler
//========================================================================================================================================================================================
private ["_menArraySpecial","_unitPlaced","_totalEnemyUnits","_script_handler","_spawnbehavior","_group"];
_totalEnemyUnits	= _this select 0;
_zoneNumber			= _this select 1;
_spawnbehavior		= _this select 2;

_menArraySpecial = [];
if ((count MCC_MWGroupArrayMenRecon)>0) then {_menArraySpecial = _menArraySpecial + MCC_MWGroupArrayMenRecon};
if ((count MCC_MWGroupArrayMenSniper)>0) then {_menArraySpecial = _menArraySpecial + MCC_MWGroupArrayMenSniper};
if ((count MCC_MWGroupArrayMenSupport)>0) then {_menArraySpecial = _menArraySpecial + MCC_MWGroupArrayMenSupport};
	
_unitPlaced = 0;

if (count MCC_MWGroupArrayMen > 0) then 
{
	//Infantry
	while {_unitPlaced < _totalEnemyUnits} do
	{
		//Regular or SF
		if (random 1 < 0.2 && ((count _menArraySpecial)>0)) then
		{
			_group = _menArraySpecial call BIS_fnc_selectRandom;
		}
		else
		{
			_group = MCC_MWGroupArrayMen call BIS_fnc_selectRandom;
		};
		
		//count units
		_unitPlaced = _unitPlaced + (_group select 1);
		
		//Spawn them
		_script_handler = [_zoneNumber,"GROUP","LAND",true,_group select 0,_group select 2,_spawnbehavior,_group select 0] call MCC_fnc_MWSpawnInZone; 
		waituntil {_script_handler};
	}; 
}
else
{
	diag_log "MCC: Mission Wizard Error: No group available in the selected enemy faction"; 
};

_unitPlaced;


				
		

		