function [sorted_timestamps, noise_waves, rec_waves, noise_amp, original_input_indices]= SWADE_XI(waves, timestamps, pcp, cent_reg_m, outlines_m, cr_wnum_m, mean_waves_m,  mw_sd_m, th, av_th, th_o, th_temp, fig_handle)
	% parameter fig_handle: If ~= 0, assume this is a figure handle and plot density + templates.
	% If there is no figure that has this handle, create a new figure.

%function [sorted_timestamps, noise_waves, rec_waves]= SWADE_X(waves, timestamps, pcp, cent_reg_m, outlines_m, cr_wnum_m, mean_waves_m,  mw_sd_m, th, av_th, th_o, th_temp, show)
%
%  Carlos Vargas-Irwin, Donoghue Lab   Last updated 10/11/05
% 
% David Xing made some modifications (added an additional output of indices of the original wave the sorted wave is derrived from) for integrating into wave_clus, 5/11/18

[points, numwaves] = size(waves);

%%%%%%%%%
%tic
%%%%%%%%%

ops = 0;

clear amp;
%preallocate for speed
for c = 1:length(cent_reg_m)
    rec_waves{c} = zeros(points,numwaves);
    sorted_timestamps{c} = zeros(1,numwaves);
    original_input_indices{c} = zeros(numwaves,1);
    count(c) = 0;
    %calculate amplitudes of final templates
    amp(c) =  max( mean_waves_m(:,c) ) - min( mean_waves_m(:,c) );
end
noise_count = 0;
noise_waves = zeros(1,numwaves);

fprintf('Template amplitudes:\n');
for ii = 1:length(amp)
	fprintf('\t%i:\t%6.1f\n', ii, amp(ii));
end

firstMatch = zeros(1,numwaves);

%%%%% Wave processing loop
if usejava('desktop')
	multiWaitbar('Waveforms', 0);
end

for w = 1:numwaves
    added = 0;


    if usejava('desktop') && ((mod(w, round(numwaves/100)) == 0) || (w == numwaves))
		multiWaitbar('Waveforms', w/numwaves);
    end;

    wav = waves(:,w);


    [tmatch, tshift]= temp_match_overlap_X( wav, mean_waves_m,th_o);

    r_waves = reconstruct_waves(wav, mean_waves_m, tshift, tmatch, th, av_th);



%             if length( find(tmatch == min(tmatch)) )>1 & (min(tmatch)<100) & (max(max(r_waves)))>200
%                display(['overlap recontsturction at waveform ' int2str(w)])
%                figure
%                plot(wav); hold on;
%                plot(r_waves,'r')
%                plot(mean_waves_m,'g')
%                tshift
%                tmatch
%                av_th
%                th
%             end

    for i = 1:length(tmatch)

        %%%%% ADD TO CLUSTER
        if  length( find(tmatch == min(tmatch)) )>1
            class_th = (th+(max(amp)* (av_th/100) ));
        else
            class_th = (th+(amp(i)* (av_th/100) ));
        end
%
%
%         if  length( find(temp_match == min(temp_match)) )>1
%             class_th = (threshold+(max(amp)* (av_th/100) ));
%         else
%             class_th = (threshold+(amp(t)* (av_th/100) ));
%         end
%


        if  (tmatch(i)< class_th ) % & (temp_match(t)==min(temp_match(t)))
            count(i) = count(i)+1;
            rec_waves{i}(:,count(i)) = r_waves(:,i);
            sorted_timestamps{i}(count(i)) = timestamps(w) + (tshift(i)*(1.6/points));
            original_input_indices{i}(count(i),1)=w;
            added = 1;
			if firstMatch(w) == 0
				firstMatch(w) = i;
			end
        end

    end

    % count possible overlaps
    if length(find(tmatch<inf)) > 1
        ops = ops+1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %check if pcp is in central region
%     clear in_cr;
%     for t = 1:length(cent_reg_m)
%         in_cr(t) = inpolygon(pcp(1,w),pcp(2,w),cent_reg_m{t}(:,1),cent_reg_m{t}(:,2));
%     end
%     %%%%%% ADD TO CLUSTER
%     if (sum(in_cr) > 0)   % if it is in an outline, and has not been assigned to the cluster, do so
%         m = find(in_cr==1);
%         if added ==0
%             added = 1;
%             count(m) = count(m)+1;
%             %tclusters{m}(count(m)) =  w;
%
%             sorted_timestamps{m}(count(m)) = timestamps(w);
%             rec_waves{m}(:,count(m)) = wav; %r_waves(:,m);      % ???????
%         end
%     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if added == 0 % if the waveform is to be classified as noise
        noise_count = noise_count + 1;
        noise_waves(noise_count) = w;
        
%         figure;
%         plot(wav)
%         hold on
%         plot(mean_waves_m);
        
    end

end

po = (ops/numwaves) *100;
disp([':::::::: Detected ' int2str(ops) ' possible overlapping spikes --> ' num2str(po) '%']);

if usejava('desktop')
	multiWaitbar('Waveforms', 'Close');
end



% crop unused matrix
for c = 1:length(cent_reg_m)
    rec_waves{c} = rec_waves{c}(:,1:count(c));
    sorted_timestamps{c} = sorted_timestamps{c}(1:count(c));
    original_input_indices{c} = original_input_indices{c}(1:count(c));
end
noise_waves = noise_waves(1:noise_count);

%%%%%%%%%
%toc
%%%%%%%%%


%     % remove clusters with less than 500 waveforms
%     dnr = [];
%     for c = 1:length(sorted_timestamps)
%         if(length(sorted_timestamps{c}) > 500)
%             dnr = [dnr c];
%         end
%     end
%     sorted_timestamps = {sorted_timestamps{dnr}};
%     mean_waves_m = mean_waves_m(:,dnr);
%     mergelist = {mergelist{dnr}};
%     %
%
%     if(length(dnr) == 0 )
%         sorted_timestamps{1} =  [];
%         mean_waves_m = [];
%         noise_waves = [1:numwaves];
%         rec_waves = [];
%     end

%cent_reg_m
%sorted_timestamps
if ~isempty(sorted_timestamps)
	fprintf('We found these units:\n');
	for ii = 1:length(sorted_timestamps)
		fprintf('\tTemplate %i: %i samples\n', ii, length(sorted_timestamps{ii}));
	end
end



%sdeval = std(al_wmat')';

% Calculate noise amplitude
%find envelope that includes 95 % of waveform values for first five samples
range_pos = zeros(5,1);
range_neg = zeros(5,1);
for n = 1:5
    ne = noextremes( waves(n,:), 95);
    range_pos(n,1) = max(ne);
    range_neg(n,1) = min(ne);
end

noise_amp = mean(range_pos) - mean(range_neg);


if(~isempty(fig_handle) && fig_handle~=0 && ~isempty(cent_reg_m) && ~isempty(sorted_timestamps{1}) ) % Show results Graphically

	isFigureHandle = ishandle(fig_handle) && strcmp(get(fig_handle,'type'),'figure');
	if ~isFigureHandle
		figure(fig_handle);
	end
    clf(fig_handle);



    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %     lowisi = [];
    %     for c = 1:length(sorted_timestamps)
    %         ts = sorted_timestamps{c};
    %         if(length(ts)>2)
    %             isi = conv(ts, [1,-1]);
    %             isi = isi(2:length(isi)-1);
    %             % in NEV timestamps are in 1/30ms   (30,000 samples / sec)  (48 samples = 1.6ms)
    %             ts = (ts/30); % switch to msec
    %
    %             [row ix] = find(isi<2);
    %             lowisi= [ lowisi sorted_timestamps{c}(ix) sorted_timestamps{cr}(ix+1)  ];
    %             %length(lowisi)
    %         end
    %     end
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %out = 'Displaying results....'
    % Draw Principal Component Projections
    ax_h = subplot(5,length(sorted_timestamps),[1:length(sorted_timestamps)*2], 'parent', fig_handle);
    col2 = [0 0 0; 1 0 0; 0 0 1; 0 1 0; 1 1 0; 0 1 1]*.75;
    colfun=@(cl)col2(mod(cl, length(col2))+1,:);
    scatter( pcp(1,:), pcp(2,:),5, cell2mat(arrayfun(colfun,firstMatch,'UniformOutput', 0)'),'o','fill', 'parent', ax_h);
    title('Principal component projections and high density region outlines', 'parent', ax_h);
	hold(ax_h, 'on');

%    clids = unique(firstMatch);
%    for i_c = 1:length(clids)
%        scatter( pcp(1,firstMatch==clids(i_c)), pcp(2,firstMatch==clids(i_c)), cell2mat(arrayfun(colfun,firstMatch(firstMatch==clids(i_c)),'UniformOutput', 0)'), 'FaceAlpha', 0.2  );
%    end
    %hold on;
    plot( pcp(1,noise_waves), pcp(2,noise_waves), 'yx', 'parent', ax_h);
    col = ['c' 'r' 'b' 'g' 'm' ];

    for clust = 1:length(sorted_timestamps)

		hold(ax_h, 'on');
        %            plot( pcp(1,st_index{clust}), pcp(2,st_index{clust}), strcat( col( mod(clust+1,length(col))+1  ) ,'.')  );
        crh = plot(cent_reg_m{clust}(:,1),cent_reg_m{clust}(:,2),strcat( col( mod(clust,length(col))+1  ) ,'-') , 'parent', ax_h);
        set(crh, 'LineWidth', 4);
        %cr_list = mergelist{clust};
        %Plot all central regions associated with this cluster
        %         for cr = 1:length(cr_list)
        %             crh = plot(cent_reg{cr_list(cr)}(:,1),cent_reg{cr_list(cr)}(:,2),strcat( col( mod(clust+1,length(col))+1  ) ,'-') );
        %             set(crh, 'LineWidth', 2.5);
        %         end
    end



    % OUTLIER ELIMINATION
    ne1 = noextremes(pcp(1,:),99.5);
    ne2 = noextremes(pcp(2,:),99.5);
    mn1_rs = min( ne1 );
    mx1_rs = max( ne1 );
    mn2_rs = min( ne2 );
    mx2_rs = max( ne2 );
    clear ne1  ne2;

    % adjust display to exclude outliers
    axis(ax_h, [mn1_rs, mx1_rs, mn2_rs, mx2_rs] );


	hold(ax_h, 'off');


    mxy = max(max(mean_waves_m))+100;
    mny = min(min(mean_waves_m))-100;

    % Draw mean waves
    for cr = 1:length(sorted_timestamps)
        %             if(length(sorted_timestamps)==1)
        %                 subplot(4,3,8)
        %             elseif(length(sorted_timestamps)==2)
        %                 subplot(4,8,[16+(cr*3)+1-2:16+(cr*3)+1] )
        %             else
        sp_ax_h = subplot(4,length(sorted_timestamps)+1,((length(sorted_timestamps)+1)*2)+cr, 'parent', fig_handle);
        %            end
        axset = [0 1.6 mny mxy];

        %plot_aligned_waves(mean_waves_m(:,cr),waves(:,sorted_timestamps{cr}), axset, col( mod(cr,length(col))+1) );
        plot_aligned_waves(mean_waves_m(:,cr),rec_waves{cr}, noise_amp, axset, col( mod(cr,length(col))+1), sp_ax_h );

    end


    %plot noise waves
    sp_ax_h = subplot(4,length(sorted_timestamps)+1,((length(sorted_timestamps)+1)*3), 'parent', fig_handle);
    plot_aligned_waves(mean(waves(:,noise_waves)')',waves(:,noise_waves), noise_amp, axset, 'y', sp_ax_h );


    % Calculating isis
    for cr = 1:length(sorted_timestamps)
        if(length(sorted_timestamps)==1)
            ax_h = subplot(4,3,11, 'parent', fig_handle);
        elseif(length(sorted_timestamps)==2)
            ax_h = subplot(4,8,[24+(cr*3)+1-2:24+(cr*3)+1], 'parent', fig_handle);
        else
            ax_h = subplot(4,length(sorted_timestamps),(length(sorted_timestamps)*3)+cr, 'parent', fig_handle);
        end

        ts = sorted_timestamps{cr};
        if(length(ts)>2)
            isiloghist(ts, 1000, col( mod(cr,length(col))+1  ), ax_h); % for matlab 6.5 use --> isiloghist(ts, 1000, strcat( col( mod(cr,length(col))+1  ) ,'--'));
        end
    end

    %         %%%%  Plot points with LOW ISI
    %                 subplot(4,length(sorted_timestamps),[1:length(sorted_timestamps)*2])
    %                 hold on;
    %                 plot( pcp(1,lowisi), pcp(2,lowisi), 'y+' );
    %         %%%%


end


%end%% if mergelist is empty...







