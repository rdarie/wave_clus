
function [tmatch, resmatch, residue, shift]= temp_match_X(wav, temp)
% template matching function

shift_range = 1; %%% !! set to 2 for slower but more accurate template matching
[points, nt] = size(temp);

tmatch = zeros((shift_range*2)+1,nt) + inf;
resmatch = zeros((shift_range*2)+1,nt) + inf;
residue = zeros(points,(shift_range*2)+1,nt);
shift = zeros((shift_range*2)+1,nt);

%check for phase shifted wf's
for t = 1:nt

    % align either on global min or global max,
    %whichever is greater in magnitude
    if max( temp(:,t)) > (-1*min( temp(:,t)))
        %find global max
        [~, mt] = max( temp(:,t) );
        [~, mw] = max(wav);
    else
        %find global min
        [~, mt] = min( temp(:,t) );
        [~, mw] = min(wav);
    end
    wdiff = mw-mt;

    sc = 0;
    for sh = -1*shift_range:1:shift_range

        sc = sc+1;

        %correct indeces (may crop wf)
        if(wdiff>0) % shift template forward
            iw = (wdiff)-sh+1:points;
            it = 1:points-wdiff+sh;
        elseif wdiff<0 % shift template backwards
           % wdiff
           % mt
            iw = 1:points+wdiff+sh;
            it = (-1*wdiff)-sh+1:points;
        else % do not shift template
            sh = sc-1;
            iw = 1:points;
            it = 1:points;
        end

        %        check that indeces are within range
        if( (max(it)<=points) && (min(it)>=0) && (max(iw)<=points) && (min(iw)>=0) )


            residue(:,sc,t) = wav;
            residue(iw,sc,t) = ( wav(iw) - temp(it,t));

            if wdiff>0
                shift(sc,t) = min(iw);
            elseif wdiff<0
                shift(sc,t) = (-1*(it(1)));
            else
                shift(sc,t) = sh;
            end




            %shift(sc,t) = wdiff+sh;


            % the error is set to the maximum deviation from zero in the part
            % of the waveform where the template was subtracted
            maxerr_plw_t = max(sqrt(power(  residue(iw,sc,t), 2)));
            % the error for the entire residue is also recorded
            maxerr_plw_r = max(sqrt(power(  residue(:,sc,t), 2)));


            % NEW Noise test = check how much the amplitude decreased after subtracting the template
            mn_wav = min(wav);
            mx_wav = max(wav);
            mn_res =  min(residue(:,sc,t));
            mx_res = max(residue(:,sc,t));

            mn_wav_t = min(wav(iw));
            mx_wav_t = max(wav(iw));
            mn_res_t = min(residue(iw,sc,t));
            mx_res_t = max(residue(iw,sc,t));

              if (mn_res_t<mn_wav_t)  || (mx_res_t>mx_wav_t)
                maxerr_plw_t = inf;
                %residue(:,sc,t) = zeros(1,points);
              end

              if (mn_res<mn_wav)  || (mx_res>mx_wav)
                maxerr_plw_r = inf;
                %residue(:,sc,t) = zeros(1,points);
              end




            tmatch(sc,t) = maxerr_plw_t;
            resmatch(sc,t) = maxerr_plw_r;




        end

    end

end


%tmatch
%resmatch





