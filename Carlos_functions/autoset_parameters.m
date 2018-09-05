function [ templates, cent_reg_m, outlines_m, cr_wnum_m, mw_sd_m, th, th_o, th_temp] = autoset_parameters(waves, cent_reg, outlines, cr_wnum, mean_waves,  mw_sd, threshold_coverage, overlap_threshold_coverage, template_threshold_coverage, threshold, overlap_threshold, template_threshold, amplitude_variation_threshold, temp_var_lim, trough_peak_width_lim)


[points, numwaves] = size(waves);

% Set thresholds automatically if no values have been specified
th = threshold;
if  length(threshold)>1 %(strcmp(threshold,'auto'))
    if numwaves>10000
        th = set_threshold(waves(:,1:10000),threshold_coverage);
    else
        th = set_threshold(waves,threshold_coverage);
    end
end

th_o = overlap_threshold;
if length(overlap_threshold)>1 %(strcmp(overlap_threshold,'auto'))
    if numwaves>10000
        th_o = set_threshold(waves(:,1:10000),overlap_threshold_coverage);
    else
        th_o = set_threshold(waves,overlap_threshold_coverage);
    end
end

th_temp = template_threshold;
if length(template_threshold)>1 %(strcmp(template_threshold,'auto'))
    if numwaves>10000
        th_temp = set_threshold(waves(:,1:10000),template_threshold_coverage);
    else
        th_temp = set_threshold(waves,template_threshold_coverage);
    end
end

th = min([max(threshold) th]);
th = max([min(threshold) th]);
th_o = min([max(overlap_threshold) th_o]);
th_o = max([min(overlap_threshold) th_o]);
th_temp = min([max(template_threshold) th_temp]);
th_temp = max([min(template_threshold) th_temp]);

display([ 'Threshold values (classification, overlap, template) --> ' num2str(th) ' ' num2str(th_o) ' '  num2str(th_temp) ]);


% remove low amplitude / too variable templates
dnr = []; %tag which templates will not be removed
for cr = 1:length(cent_reg)

    [mn,imn] = min(mean_waves(:,cr));
    [mx,imx] = max(mean_waves(:,cr));

    if ( (mx > th_temp )   |  ( mn < -th_temp) )

        if (  (abs(imx-imn)) < trough_peak_width_lim)
            %if(  (max( mean_waves(:,cr)) - min( mean_waves(:,cr)) ) > th_temp   )

            amp(cr) =  max( mean_waves(:,cr) ) - min( mean_waves(:,cr) );

            if( amp(cr) > mean(mw_sd(cr))*temp_var_lim )
                dnr = [dnr cr];
            else
                display( ['variability = ' num2str(mean(mw_sd(cr))) ' --> template removed!' ])
            end

        else
            display( ['trough-peak ='  num2str((abs(imx-imn))/30) 'ms --> template removed!' ])

        end


    else
        display( ['max = ' num2str(max( mean_waves(:,cr) )) '  min = ' num2str(min( mean_waves(:,cr) )) ' --> template removed!' ])
    end

end



mean_waves = mean_waves(:,dnr);
cent_reg = {cent_reg{dnr}};
outlines = {outlines{dnr}};
cr_wnum = cr_wnum(dnr);
%

clear amp;
% Check for template overlaps
[points nt] = size(mean_waves);
contains = zeros(length(cent_reg), length(cent_reg));
for ii = 1:nt

    [tm] = temp_match_X( mean_waves(:,ii), mean_waves);

     amp =  max( mean_waves(:,ii) ) - min( mean_waves(:,ii) );
    % take the minimum value for each template (form all shifts)

    for n = 1:nt
  %      if (min(tm(:,n))<th_temp+(amp*(amplitude_variation_threshold/100))) & (n~=ii)
        if (min(tm(:,n))<th_temp) & (n~=ii)

            % n and ii overlap
            contains(max([ii n]),min([ii n])) = 1;
        end
    end
end
% Get a list of which clusters to merge
mergelist = make_mergelist(contains);



if isempty(mergelist{1}) % no possible templates detected!
    display('No valid templates found for this channel!')

    templates = [];
    cent_reg_m = [];
    outlines_m = [];
    cr_wnum_m = [];
    mw_sd_m = [];
    th = -1;
    th_o = -1;
    th_temp = -1;


    return
else % Analyze templates....


    for m = 1:length(mergelist)
        %% Eliminate smaller cluster for template overlaps
        ml = mergelist{m};
        templates(:,m) = zeros(points,1);

        max_num = 0;

        [v mi] = max(cr_wnum(ml));

        templates(:,m) =  mean_waves(:,ml(mi));
        cent_reg_m{m} = cent_reg{ml(mi)};
        outlines_m{m} = outlines{ml(mi)};
        cr_wnum_m(m) = cr_wnum(ml(mi));
        mw_sd_m(m) = mw_sd(ml(mi));
    end


end







