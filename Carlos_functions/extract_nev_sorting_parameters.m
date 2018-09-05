
%%%%%   - Automatic Sorting using DENsity GRId Contour Clustering with Subtractive WAveform DEcomposition %%%%%
%
% ::: What it does :::
% * In a nutshell *
% Autosort_nev will read data from a nev file. It will project waveforms
% into 2D principal component space. High density areas in this space will
% be used to extract templates representing the shape of spikes from
% different neurons. These templates are then used to classify the
% waveforms using template matching.
%
% ::::: Running the Program
%
% For ease of handling, the algorithm runs as a script. To edit the
% parameters used, open the file named 'sort_nev.m' and look for the
% label that says 'Change Parameters Here'. Specific parameters are
% described in detail in this section. Once you have set the parameters in
% the file, simply type 'sort_nev' to run the program. You will be
% prompted for the nev file to sort.
% If you want to sort several files in a row (and don't want to stay around to prompt each)
% you can use the 'sort_batch' script. Here you can type in a series of
% filenames and pathnames for the program to go through (see file for
% examples).
%
%
% * The outputs *
%
% - nev file output -
% The original nev file you select will remain unchanged. The headers and
% event codes will be copied to a new nev file with the same name plus '_DS8'.
% Waves were spike overlapping is detected will be separated and inserted
% into the new nev file with different timestamps. 'Noise' waveforms will
% also be included in the new nev file in order to check the sorting results.
% The sorted timestamps are also stored in the sorted_ts cell array in MatLab.
% The matrix 'unit_index' indicates the unit and channel for each entry.
%
% - Automatic jpeg generation -
% The program will graphically display the sorting process by
% generating jpeg files in the same directory where the nev file is located.
% You can examine these while the program runs. They show the principal
% component projection of the waves, the centers of each cluster, the
% templates (+/- the sd of the waveforms assigned to each), noise waveforms
% (yellow), and interspike interval for each sorted unit.If you don't want them,
% set the show_progress variable in the m file to  0.
%
%

close all
clear all
pack


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Change parameters Here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%these you will probably not want to change....
grid = 100  % determines how pc space is partitioned
lmaxrange = 5 % determines the range of local max in the density matrix
minden = 5  % minimum required density for template extraction regions (% of global max)
%%%%%%%%%%

show_progress = 1 % this turns the automatic generation of jpegs on and off



% The e_list parameter sets the list of electrodes the program will sort
% (to save time, you can include only 'good' channels, if you have this information beforehand)
% To sort all the channels, simply set it to: e_list = [1:128] or e_list = [1:96]

  e_list = [1:128]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%   No need to worry about
%%%%%%%%%%%%%%%%%%%%%%%%%%%%   anything beyond this point....
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


tic



%% Let the user select a NEV file
[fname, pathname] = uigetfile('*.nev', ':::: Select a NEV file to sort...');
filename = strcat(pathname, fname);
% Change to the selected directory
cd(pathname);


% if(save_nev)
% %save results in a new nev file
% %%%%%%%%%%%%%%%%
% savefname = [filename(1:end-4) '_DSX2.nev']
% copyNevHeader(filename, savefname);
% %%%%%%%%%%%%%%%%
% end



%%%%% SCAN NEV FILE WITH NEUROSHARE LIBRARY
%%%%Get Library location from user
[libname, libpath] = uigetfile('*.dll', ':::: Please find nsNEVLibrary.dll or  nsPLXLibrary.dll ...');
DLLName = strcat(libpath, libname);
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SCAN
[sFileInfo] = ScanFile_ns(filename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



nunits = 0;
% for each electrode number
for n = 1:length(e_list)

    try % beginning of try-catch block to deal with any problematic channels...

        e = e_list(n);

        disp([':::::::::::::::::::::::: Sorting Channel --->  ' int2str(e) ]);

        disp([':::::::: Extracting waves and timestamps...']);
        [waves, timestamps] = ReadWaves_ns(sFileInfo, e);
        timestamps = timestamps * 30000; % adjust to 30KHz sampling

        %crop data for testing purposes
        % waves = waves(:,1:20000);
        % timestamps = timestamps(1:20000);

        [points nw] = size(waves);
        if (nw>0) % if there are any waves for this electrode nubmer

            disp([':::::::: Calculating Principal Components...']);
            % Use subset of waves to calculate principal components
            dec = round(nw / 3000);
            if(dec>1)
                pc = getPC(waves(:,1:dec:nw));
            else
                pc = getPC(waves);
            end
            %%%%%%%%%%
            disp([':::::::: Projecting waves onto PC space...']);
            pcp = getPCP(waves,pc,2);

            disp([':::::::: Analyzing density matrix & extracting templates...']);
            [cent_reg, outline, mean_waves, mw_sd, cr_wnum, pc_means, sortmat_us, sortmat] = DENGRICC_X(pcp,waves,grid,lmaxrange,minden,show_progress-1);

            % set parameters for this channel
            [ templates{n}, cent_reg_p{n}, outlines_p{n}, cr_wnum_p{n},   mw_sd_p{n}, threshold{n}, overlap_threshold{n}, template_threshold{n}] = set_parameters( waves, cent_reg, outline, cr_wnum, mean_waves,  mw_sd, threshold_bounds, overlap_threshold_bounds, template_threshold_bounds, temp_var_lim);


        end

    catch %any errors sorting a given channel
        display([' ----!---- Error: Unable to sort Channel ' int2str(e) ' ----!----'])
        display(lasterr)
        display([' ----!---------------------------------------------!----'])
    end

end  % for n = 1:length(e_list)

%clear mean_waves_m minden n nch nsc nunits nw pc pcp sclusters show_progress sortmat sortmat_us timestamps w wav waves dec e elec grid index lmaxrange threshold

% close nev file
 ns_CloseFile(sFileInfo.file_h);


if(save_nev)
    %closeNEV(nevOb)
    %%%%%%%%%%%%%%%%%%
    %Copy events from original nev file
    copyNevEvents(filename, savefname);
    %%%%%%%%%%%%%%%%%%
end

if(save_mat)
    save( [ savefname(1:end-4) '_sort_parameters'], 'cent_reg_p', 'outlines_p', 'cr_wnum_p', 'templates',  'mw_sd_p', 'threshold', 'overlap_threshold', 'template_threshold', 'e_list');
end
disp([':::::::: Parameter file generated --> ' savefname(1:end-4)]);

% all done with MEX...
clear mexprog

toc



