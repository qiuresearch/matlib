% DBVIM       edit the currently debugged line
DBVIM_stack = dbstack;
if length( DBVIM_stack ) >= 2
    DBVIM_line = DBVIM_stack(2).line;
    DBVIM_name = DBVIM_stack(2).name;
    ovi( sprintf( '+%i', DBVIM_line ), DBVIM_name ); 
end
clear DBVIM DBVIM_line DBVIM_name
