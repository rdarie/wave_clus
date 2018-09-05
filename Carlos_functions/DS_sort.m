
% Want to know how this works? Check out DS_sort_parameters.m

%%%%%%%%%% code follows, no need to read further! Unless you love code.

amp_fig_h = 210;
figure(amp_fig_h);
dens_fig_h = 10;
figure(dens_fig_h);

%load file using NPMK toolbox!
NEV = openNEV(filename, 'read', 'report',  'nowarning','nosave', 'nomat' );


tic % how long does this take anyways?



savefname = [filename(1:end-4) '_DSXII.nev'];
if (show_progress)
	plot_out_path = [NEV.MetaTags.FilePath '/sort_plots'];
	[~, ~, mkdirmesstr] = mkdir(plot_out_path);
	if ~(strcmp(mkdirmesstr,'MATLAB:MKDIR:DirectoryExists')|| strcmp(mkdirmesstr,''))
		error(sprintf('Directory %s couldn''t be created.\n', plot_out_path));
	end

end
if(save_nev)    %save results in a new sorted nev file

    %check if sorted file already exists! (for example, if sorting was
    %interrupetd
    sort_exists = fopen(savefname);
    if(sort_exists == -1) %if it does not exist, create a new file with the same header as the original
        %%%%%%%%%%%%%%%%
        copyNevHeader(filename, savefname);
        %%%%%%%%%%%%%%%%
        %begin sorting at electrode # 1 in list
        starte = 1;
    else % the file already exists


        %close file for now
        fclose(sort_exists);
        %load previous sorting results & parameters
       % load([ savefname(1:end-4) '_sorted_data' ]);
        load([ savefname(1:end-4) '_sort_parameters']);
        %Begin sorting at the appropriate place in the electrode list
        starte = last_sorted_e +1;


        disp([':::::::::: Sorted file already exists! Sort will continue from breakpoint at electrode  --->  ' int2str(last_sorted_e +1) ]);


    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

last_sorted_e = 0;
nunits = 0;
% for each electrode number
for n = starte:length(e_list)
    % beginning of try-catch block to deal with any problematic channels...
    try

    e = e_list(n);

    disp([':::::::::::::::::::::::: Sorting Channel --->  ' int2str(e) ]);

    disp([':::::::: Extracting waves and timestamps...']);


    if (str2num(NEV.MetaTags.FileSpec) >=2.3)
        waves = double(NEV.Data.Spikes.Waveform(:,find(NEV.Data.Spikes.Electrode == e))) / 4;   % divide amplitudes by four for filespec 2.3
    else
        waves = double(NEV.Data.Spikes.Waveform(:,find(NEV.Data.Spikes.Electrode == e)));
    end

    timestamps = double(NEV.Data.Spikes.TimeStamp(:,find(NEV.Data.Spikes.Electrode == e)));



%            %%%   crop data for testing purposes
%            waves = waves(:,1:10000);
%            timestamps = timestamps(1:10000);
%            %%%


    [points nw] = size(waves);
    if( points == 1)
    waves = waves';
    end
    [points nw] = size(waves);

    noise_index = 1:nw; %overwritten if any sorting templates are found
    if (nw>100) % if there are any waves for this electrode nubmer

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
        [cent_reg, outline, mean_waves, mw_sd, cr_wnum, pc_means, sortmat_us, sortmat] = DENGRICC_XI(pcp,waves,grid,lmaxrange,minden,show_progress-2);

        if(isempty(mean_waves))
            disp([':::::::: No valid templates extracted from the density matrix...']);
        else
            % set parameters for this channel
            [ templates{n}, cent_reg_p{n}, outlines_p{n}, cr_wnum_p{n},   mw_sd_p{n}, threshold(n), overlap_threshold(n), template_threshold(n)] = autoset_parameters( waves, cent_reg, outline, cr_wnum, mean_waves,  mw_sd, threshold_coverage, overlap_threshold_coverage, template_threshold_coverage, threshold_bounds, overlap_threshold_bounds, template_threshold_bounds, amplitude_variation_threshold, temp_var_lim, trough_peak_width_lim);

            if ~ isempty(templates{n})

                %                     if(show_progress)
                %                             close all
                %                             figure(20)
                %                             title([fname(1:end-4) '_DSXI_sig_' num2str(e)]')
                %                             hold on
                %                     end

                disp([':::::::: Applying Templates...']);
				if show_progress
					[sorted_ts, noise_index, rec_waves, noise_amp(n)]= SWADE_XI(waves, timestamps, pcp, cent_reg_p{n}, outlines_p{n}, cr_wnum_p{n}, templates{n},  mw_sd_p{n}, threshold(n),amplitude_variation_threshold, overlap_threshold(n), template_threshold(n), dens_fig_h);
				else
					[sorted_ts, noise_index, rec_waves, noise_amp(n)]= SWADE_XI(waves, timestamps, pcp, cent_reg_p{n}, outlines_p{n}, cr_wnum_p{n}, templates{n},  mw_sd_p{n}, threshold(n),amplitude_variation_threshold, overlap_threshold(n), template_threshold(n), 0);
				end

                if(~isempty(sorted_ts{1}))
                    if(show_progress)
                        %print('-djpeg', ['sort_results_' num2str(e)]);
                        print('-dpng', ['-f' num2str(dens_fig_h)], [plot_out_path '/' fname(1:end-4) '_DSXII_sig_' num2str(e)]);
                    end


                    if(show_progress>1) %display amp vs. time plots

                        clf(amp_fig_h)
                        colstr = 'rbgmcrbgmc';
                        for nrw = 1:length(rec_waves)
                            [pt nrecwaves] = size(rec_waves{nrw});
                            all_amp = zeros(1,nrecwaves);
                            for wav = 1:nrecwaves
                            all_amp(wav) = max(rec_waves{nrw}(:,wav)) - min(rec_waves{nrw}(:,wav));
                            end
                            ax_h = subplot(1,length(rec_waves),nrw, 'parent', amp_fig_h);
                            plot(sorted_ts{nrw}/1800000, all_amp,[colstr(nrw) '.'], 'parent', ax_h);
                            hold(ax_h, 'on');
                            set(ax_h, 'fontsize', 13)
                            xlabel('time (min)', 'parent', ax_h)
                            ylabel('amplitude (µV)', 'parent', ax_h)

                            axis(ax_h, [ 0 max(sorted_ts{1}/1800000) 0  (max(max([templates{n}])) - min(min([templates{n}])) )*2] )
                        end


                        print('-dpng', ['-f' num2str(amp_fig_h)], [plot_out_path '/' fname(1:end-4) '_DSXII_sig_' num2str(e) '_AvT']);

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
                            insertSpike(savefname, sorted_ts{nsc}, ect, u, rec_waves{nsc}*4);
                            %%%%%%%%%%%%%%%%
                        end
                    end

                    %%%%% Save matlab file
                    if(save_mat)
                        for i = 1:length(sorted_timestamps)
                            sorted_timestamps{i} = sorted_timestamps{i}/30000;
                        end
                        save( [ savefname(1:end-4) '_sorted_data' ], 'sorted_timestamps', 'unit_index', 'templates', 'e_list');
                    end
                    %save parameters
                    last_sorted_e = n;
                    save( [ savefname(1:end-4) '_sort_parameters'], 'show_progress', 'save_mat', 'save_nev', 'save_noise', 'temp_var_lim', 'trough_peak_width_lim', 'cent_reg_p', 'outlines_p', 'cr_wnum_p', 'templates',  'mw_sd_p', 'amplitude_variation_threshold', 'threshold', 'overlap_threshold', 'template_threshold', 'e_list', 'last_sorted_e', 'noise_amp', 'filename', 'savefname');
                    %%%%%%%%%%%

                end
            end
        end % if(isempty(mean_waves)

        if( save_nev && save_noise)
            %add noise waveforms to NEV
            ect = zeros(1,length(noise_index)) + e;
            u = zeros(1,length(noise_index));
            disp([':::::::: writing noise waves to nev...']);
            %%%%%%%%%%%%%%%%
            insertSpike(savefname, timestamps(noise_index), ect, u, waves(:,noise_index)*4);
            %%%%%%%%%%%%%%%%
        end


    end %(nw>0)

        catch %any errors sorting a given channel
            display([' ----!---- Error: Unable to sort Channel ' int2str(e) ' ----!----'])
            display(lasterr)
            display([' ----!---------------------------------------------!----'])
            if(save_noise)
                %add noise waveforms to NEV
                ect = zeros(1,length(noise_index)) + e;
                u = zeros(1,length(noise_index));
                disp([':::::::: writing noise waves to nev...']);
                %%%%%%%%%%%%%%%%
                insertSpike(savefname, timestamps(noise_index), ect, u, waves(:,noise_index)*4);
                %%%%%%%%%%%%%%%%
            end
        end

end  % for n = 1:length(e_list)

%clear mean_waves_m minden n nch nsc nunits nw pc pcp sclusters show_progress sortmat sortmat_us timestamps w wav waves dec e elec grid index lmaxrange threshold

% close nev file

if(save_nev && save_events)
    %closeNEV(nevOb)
    %%%%%%%%%%%%%%%%%
    %Copy events from original nev file
	saveNEVWithExtraData(savefname, savefname, 'comment_struct', NEV.Data.Comments, 'serdig_struct', NEV.Data.SerialDigitalIO);
    %%%%%%%%%%%%%%%%%
end



toc
