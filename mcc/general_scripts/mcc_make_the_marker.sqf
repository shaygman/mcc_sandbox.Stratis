private ["_marker","_nul","_markerlabel"];


MCC_Marker_type = "RECTANGLE";
MCC_Marker_dir = 0;
MCC_MarkerZoneColor = "colorYellow";
MCC_MarkerZoneType = "mil_join";


//safe the zone size in the array for later use
mcc_zone_pos  set [mcc_zone_number,mcc_zone_markposition];
mcc_zone_size set [mcc_zone_number,[mcc_zone_marker_X,mcc_zone_marker_Y]];
mcc_zone_locations set [mcc_zone_number,mcc_hc];


//obviously when we are loading there is no need to safe it again since that will influence the load process by double output
if (!mcc_isloading && !MCC_capture_state) then 
	{
		mcc_safe=mcc_safe + FORMAT ["
								  mcc_zone_markposition=%1;
								  mcc_zone_number=%2;
								  mcc_zone_marker_X=%3;
								  mcc_zone_marker_Y=%4;
								  mcc_zone_markername='%5';
								  mcc_hc=%6;
								  mcc_zone_pos  set [mcc_zone_number,mcc_zone_markposition];
								  mcc_zone_size set [mcc_zone_number,[mcc_zone_marker_X,mcc_zone_marker_Y]];
								  mcc_zone_locations set [mcc_zone_number,mcc_hc];
								  script_handler = [0] execVM '%7mcc\general_scripts\mcc_make_the_marker.sqf';
								  waitUntil {scriptDone script_handler};
								  "
								,mcc_zone_markposition
								,mcc_zone_number
								,mcc_zone_marker_X
								,mcc_zone_marker_Y
								,mcc_zone_markername
								,mcc_hc
								,MCC_path
								];

						
		deleteMarkerLocal mcc_zone_markername;					
		_marker = createMarkerLocal [mcc_zone_markername, mcc_zone_markposition];
		_marker setMarkerShapeLocal MCC_Marker_type;
		_marker setMarkerDirLocal MCC_Marker_dir;
		_marker setMarkerSizeLocal (mcc_zone_size select mcc_zone_number);
		_marker setMarkerAlpha 0.4; 
		mcc_zone_markername	setMarkerColorLocal MCC_MarkerZoneColor;
		
		deleteMarkerLocal (format["LABEL_%1",mcc_zone_markername]);
		_markerlabel = createMarkerLocal [(format["LABEL_%1",mcc_zone_markername]), mcc_zone_markposition];
		_markerlabel setMarkerShapeLocal "ICON"; 
		(format["LABEL_%1",mcc_zone_markername]) setMarkerTypeLocal MCC_MarkerZoneType;
		(format["LABEL_%1",mcc_zone_markername]) setMarkerTextLocal mcc_zone_markername;
		(format["LABEL_%1",mcc_zone_markername]) setMarkerColorLocal "ColorRed";
		
		mcc_zone_markposition = (getmarkerpos mcc_zone_markername);					
		mcc_zone_pos  set [mcc_zone_number,mcc_zone_markposition];
		mcc_isnewzone = true;
		
		_nul= [0] execVM MCC_path + "mcc\general_scripts\mcc_SpawnStuff.sqf";
	};

	if (mcc_isloading) then
	{
		deleteMarkerLocal mcc_zone_markername;					
		_marker = createMarkerLocal [mcc_zone_markername, mcc_zone_markposition];
		_marker setMarkerShapeLocal MCC_Marker_type;
		_marker setMarkerDirLocal MCC_Marker_dir;
		_marker setMarkerSizeLocal (mcc_zone_size select mcc_zone_number);
		_marker setMarkerAlpha 0.4; 
		mcc_zone_markername	setMarkerColorLocal MCC_MarkerZoneColor;
		
		deleteMarkerLocal (format["LABEL_%1",mcc_zone_markername]);
		_markerlabel = createMarkerLocal [(format["LABEL_%1",mcc_zone_markername]), mcc_zone_markposition];
		_markerlabel setMarkerShapeLocal "ICON"; 
		(format["LABEL_%1",mcc_zone_markername]) setMarkerTypeLocal MCC_MarkerZoneType;
		(format["LABEL_%1",mcc_zone_markername]) setMarkerTextLocal mcc_zone_markername;
		(format["LABEL_%1",mcc_zone_markername]) setMarkerColorLocal "ColorRed";
		
		diag_log format ["Loading Zone Marker: %1, %2, %3, %4, %5", mcc_zone_number, mcc_zone_markername, MCC_Marker_type, MCC_Marker_dir, MCC_MarkerZoneColor];
		
		mcc_zone_markposition = (getmarkerpos mcc_zone_markername);					
		mcc_zone_pos  set [mcc_zone_number,mcc_zone_markposition];
		
		mcc_isnewzone = true;
		_nul= [0] execVM MCC_path + "mcc\general_scripts\mcc_SpawnStuff.sqf";
	};
	
	if (MCC_capture_state) then
	{
		MCC_capture_var=MCC_capture_var + FORMAT ["
								  mcc_zone_markposition=%1;
								  mcc_zone_number=%2;
								  mcc_zone_marker_X=%3;
								  mcc_zone_marker_Y=%4;
								  mcc_zone_markername='%5';
								  mcc_hc=%6;
								  mcc_zone_size set [mcc_zone_number,[mcc_zone_marker_X,mcc_zone_marker_Y]];
								  mcc_zone_locations set [mcc_zone_number,mcc_hc];	
								  script_handler = [0] execVM '"+MCC_path+"mcc\general_scripts\mcc_make_the_marker.sqf';
								  "
								,mcc_zone_markposition
								,mcc_zone_number
								,mcc_zone_marker_X
								,mcc_zone_marker_Y
								,mcc_zone_markername
								,mcc_hc
								];
		hint "Action captured";						
	};

//safe the info cause ups makes marker info not valid because of disappear of marker
