
% Want to know how this works? Check out DS_sort_parameters.m

%%%%%%%%%% code follows, no need to read further! Unless you love code.


% % Let the user select a NEV file
% [fname, pathname] = uigetfile('*.nev', ':::: Select a NEV file to sort...');

 filename = strcat(pathname, fname);
% %%Change to the selected directory
cd(pathname);


if(save_nev)
%save results in a new nev file
%%%%%%%%%%%%%%%%
savefname = [filename(1:end-4) '_DSXI.nev']
copyNevHeader(filename, savefname);
%%%%%%%%%%%%%%%%
end


%%%%% SCAN NEV FILE WITH NEUROSHARE LIBRARY

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

tic % how long does this take, anyways?



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
         noise_index = 1:nw; %overwritten if any sorting templates are found

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

            disp([':::::::: Obtaining sorting parameters from loaded datafile ( _DSXI_sort_parameters.mat )...']);
            % ASSUME SORTING PARAMETERS HAVE ALREADY BEEN CALCULATED!

            if ~ isempty(templates{n})
                disp([':::::::: Applying Templates...']);
                [sorted_ts, noise_index, rec_waves]= SWADE_XI(waves, timestamps, pcp, cent_reg_p{n}, outlines_p{n}, cr_wnum_p{n}, templates{n},  mw_sd_p{n}, threshold(n),amplitude_variation_threshold, overlap_threshold(n), template_threshold(n), show_progress);

                if(~isempty(sorted_ts{1}))
                    if(show_progress)
                        figure(20)
                        %print('-djpeg', ['sort_results_' num2str(e)]);
                            print('-dpng', [fname(1:end-4) '_DSXI_sig_' num2str(e)]);
                    end
                    % create an index of sorted timestamps
                    %    unit_index --> 2x#units matrix. The top row should have the channel number
                    %              and the bottom row the unit number.
                    disp([':::::::: Saving Results...']);
                    for nsc = 1:length(sorted_ts)
                        nunits = nunits+1;
                        %Store results in matlab (just timestamps, so it does not take too much space)
                        unit_index(1,nunits) = e;
                        unit_index(2,nunits) = nsc;
                        sorted_timestamps{nunits} = sorted_ts{nsc};
                        if(save_nev)
                            % save results to new nev file
                            ect = zeros(1,length(sorted_ts{nsc})) + e;
                            u = zeros(1,length(sorted_ts{nsc})) + nsc;
                            disp([':::::::: writing spike waves to nev...']);
                            %%%%%%%%%%%%%%%%
                            insertSpike(savefname, sorted_ts{nsc}, ect, u, rec_waves{nsc});
                            %%%%%%%%%%%%%%%%
                        end
                    end

                end

            end

            if(save_noise)
                %add noise waveforms to NEV
                ect = zeros(1,length(noise_index)) + e;
                u = zeros(1,length(noise_index));
                disp([':::::::: writing noise waves to nev...']);
                %%%%%%%%%%%%%%%%
                insertSpike(savefname, timestamps(noise_index), ect, u, waves(:,noise_index));
                %%%%%%%%%%%%%%%%
            end

        end %(nw>0)

    catch %any errors sorting a given channel
        display([' ----!---- Error: Unable to sort Channel ' int2str(e) ' ----!----'])
        display(lasterr)
        display([' ----!---------------------------------------------!----'])
        if(save_noise & length(timestamps)>1)
            %add noise waveforms to NEV
            ect = zeros(1,length(noise_index)) + e;
            u = zeros(1,length(noise_index));
            disp([':::::::: writing noise waves to nev...']);
            %%%%%%%%%%%%%%%%
            insertSpike(savefname, timestamps(noise_index), ect, u, waves(:,noise_index));
            %%%%%%%%%%%%%%%%
        end
    end

end  % for n = 1:length(e_list)

%clear mean_waves_m minden n nch nsc nunits nw pc pcp sclusters show_progress sortmat sortmat_us timestamps w wav waves dec e elec grid index lmaxrange threshold

% close nev file
 ns_CloseFile(sFileInfo.file_h);


if(save_nev)
%    closeNEV(nevOb)
    %%%%%%%%%%%%%%%%%
    %Copy events from original nev file
    copyNevEvents(filename, savefname);
    %%%%%%%%%%%%%%%%%
end

if(save_mat)
    for i = 1:length(sorted_timestamps)
        sorted_timestamps{i} = sorted_timestamps{i}/30000;
    end
    save( [ savefname(1:end-4) '_sorted_data' ], 'sorted_timestamps', 'unit_index', 'templates', 'e_list');
end
%save parameters
save( [ savefname(1:end-4) '_sort_parameters'], 'show_progress', 'save_mat', 'save_nev', 'save_noise', 'temp_var_lim', 'trough_peak_width_lim', 'cent_reg_p', 'outlines_p', 'cr_wnum_p', 'templates',  'mw_sd_p', 'amplitude_variation_threshold', 'threshold', 'overlap_threshold', 'template_threshold', 'e_list', 'noise_amp');




% all done with MEX...
clear mexprog

toc
