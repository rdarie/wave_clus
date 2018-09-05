% Extract neural timestamps (including sorted unit info) from a nev file
% using the Neuroshare library

clear all
close all

% Change to the path for the neuroshare nev dll
DLLName = 'C:\Documents and Settings\Carlos Vargas Irwin\My Documents\CVI\MatLab\NevLIb-3-05\Windows\nsNEVLibrary.dll'

%% Let the user select a NEV file
[fname, pathname] = uigetfile('*.nev', ':::: Select a NEV file ...');
filename = strcat(pathname, fname);

% load neuroshare library
extension = DLLName(end-15:end);
if ~strcmpi(extension,'nsNEVLibrary.dll') & ~strcmpi(extension,'nsPLXLibrary.dll')
    fprintf('Error in : ScanFile_ns.m: \n');
    fprintf('Only NEV and PLX formats are supported. \n');
    fprintf('Download a neuroshare DLL to add support for other formats. \n');
    return;
end;
%%%%%
% Load the appropriate DLL
fprintf('    Loading:   %s...',DLLName);
[nsresult] = ns_SetLibrary(DLLName);
fprintf('  OK\n');


[nsresult, file_h] = ns_OpenFile(filename);
[nsresult, FileInfo] = ns_GetFileInfo(file_h);


nunits = 0;
for eid = 1 : FileInfo.EntityCount

    [nsresult, EntityInfo] = ns_GetEntityInfo(file_h, eid);

    if EntityInfo.EntityType == 4 % if this is a neural event

        [nsresult, nsNeuralInfo] = ns_GetNeuralInfo(file_h, eid);
        if nsNeuralInfo.SourceUnitID > 0
            nunits = nunits+1;
            [nsresult, sorted_timestamps{nunits}] = ns_GetNeuralData(file_h, eid, 1, EntityInfo.ItemCount);

            unit_index(1,nunits) = nsNeuralInfo.SourceEntityID;
            unit_index(2,nunits) = nsNeuralInfo.SourceUnitID;
        end

    end
end


save( [ filename(1:end-4) '_gNevTs' ], 'sorted_timestamps', 'unit_index');



