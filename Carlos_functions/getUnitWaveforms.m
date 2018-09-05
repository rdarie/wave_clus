% Extract neural timestamps (including sorted unit info) from a nev file
% using the Neuroshare library

clear all
close all

% Change to the path for the neuroshare nev dll
DLLName = 'C:\Documents and Settings\Carlos Vargas Irwin\My Documents\CVI\MatLab\NevLIb-3-05\Windows\nsNEVLibrary.dll'

%% Let the user select a NEV file
[fname, pathname] = uigetfile('*.nev', ':::: Select a NEV file ...');
filename = strcat(pathname, fname);

cd(pathname)

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

    
[sFileInfo] = ScanFile_ns(filename);
    
nunits = 0;
for eid = 1 : FileInfo.EntityCount

    [nsresult, EntityInfo] = ns_GetEntityInfo(file_h, eid);

    if EntityInfo.EntityType == 4 % if this is a neural event

        [nsresult, nsNeuralInfo] = ns_GetNeuralInfo(file_h, eid);
        
        if nsNeuralInfo.SourceUnitID > 0
            nunits = nunits+1;
            [nsresult, sorted_timestamps] = ns_GetNeuralData(file_h, eid, 1, EntityInfo.ItemCount);

            unit_index(1,1) = nsNeuralInfo.SourceEntityID;
            unit_index(2,1) = nsNeuralInfo.SourceUnitID;
            
            %%%%%%%%%%%SNR approximation
clear waves timestamps uid
            [waves, timestamps, uid] = ReadWaves_ns(sFileInfo,nsNeuralInfo.SourceEntityID);
                %get noise amplitude
                range_pos = zeros(5,1);
                range_neg = zeros(5,1);
                for n = 1:5
                    ne = noextremes( waves(n,:),95);
                    range_pos(n,1) = max(ne);
                    range_neg(n,1) = min(ne);
                end
            n_amp = mean(range_pos) - mean(range_neg);
            
            
            %get spike amplitude
            mwave = mean(waves(:,find(uid==nsNeuralInfo.SourceUnitID))');
            s_amp = max(mwave) - min(mwave); 
            noise_amp =  n_amp;
            spike_amp =  s_amp ;
            
            snr =  s_amp / n_amp;
            %%%%%%%%%%%  end SNR
             
            

save( [ filename(1:end-4) '_unit' int2str(unit_index(1,1)) '-' int2str(unit_index(2,1)) '_spikes' ], 'waves', 'mwave', 'timestamps', 'snr', 'unit_index', 'noise_amp', 'spike_amp' );

            
            
        end

    end
end



