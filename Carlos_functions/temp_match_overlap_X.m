function [final_match, final_shift]= temp_match_overlap_X(wav,temp,th_o)

%tic


[points, nt] = size(temp);
%amp_wav = max(wav) - min(wav);

[t_match, r_match, residue, t_shift]= temp_match_X(wav, temp);


 %t_match
 %t_shift

 % End sorting for very good ( better than th_o) or very bad ( inf) single
 % template matches
if ((min(min(t_match))<th_o || min(min(r_match))<th_o)) ||  ((min(min(t_match))==inf || min(min(r_match))==inf))
    [final_match, ix]= min((t_match));
    c = 0;
    for i = 1:length(ix)
        c = c+1;
        final_shift(i) = t_shift(ix(i),c);
    end
    for t = 1:nt
        if final_match(t) ~= min(final_match)
            final_match(t) = inf;
        end
    end
    return
end

 %min_fit = min(min(t_match));
 [ns, nt] = size(t_match);


final_match = zeros(1,nt)+inf;
final_shift = zeros(1,nt);

for c = 1:nt
    for r = 1:ns
        if(t_match(r,c)) < final_match(c);
            final_match(c) = t_match(r,c);
        end
%        if(t_match(r,c)) == min_fit ;
%            min_temp=r;
%            min_shift=c;
%        end
    end
end

%final_match
% [tv ti] = min(t_match);
% [min_tm shi] = min(tv);
% ti = ti(shi);
%min_amp_res =  max( residue(:,ti,shi) ) - min( residue(:,ti,shi) );


%min_amp_res =  max( residue(:,min_temp,min_shift) ) - min( residue(:,min_temp,min_shift) );

%for t = 1:nt
%    amp_temp(t) =  max( temp(:,t) ) - min( temp(:,t) );
%end


% Conditions for overlap checking:
%
%   the amplitude of the residue from the best fitting template is greater
%   than or equal to the amplitude of the smallest template (adjusted by the threshold)
%
%

check_overlaps2 = 1; %(min_fit > th) & ( min_amp_res >= (min(amp_temp)- (2*th*(min(amp_temp)/100)) ) )  & (nt>2) ;  %   & (max(amp_res)<=amp_wav);

%  if check_overlaps2
% % display('SKippping ovelap check!')
%  display('ovelap of 2 check!')
% end


residue2 = zeros(points,ns,nt,ns,nt);
%tshift2 = zeros(ns,nt,ns,nt);
min_amp_res2 = inf;

if (check_overlaps2)
    for t = 1:nt
        for t2 = 1:nt

            if (t ~= t2)

                for s = 1:ns

                    [tm2, rm2, res, sh]= temp_match_X(residue(:,s,t), temp(:,t2) );

                    %keep track of smallest amp for residues (to determine if we will check for overlaps of three)
                    for a = 1:ns
                        r2amp(a) = max(res(:,a))-min(res(:,a));
                    end
                    if(min(r2amp)<min_amp_res2)
                        min_amp_res2 = min(r2amp);
                    end


                    % keep track of residues and shifts (reduced number of possible paths)
                    residue2(1:points,1:ns,t2,s,t) = res;
                    t_shift2(1:ns,t2,s,t) = sh;

                    %Each column in the reported shifts represents a template
                    %Each row represents a shift (around the minimum being aligned)
                    %Calculates the minimum shift and template index
                    %[tv2 ti2] = min(tm2);
                    [min_tm2, shi2] = min(tm2);


%                      if t == 1 &  t2 == 3  & t_shift(s,t) ==  12
%
%                                 shi2
%                                  t2
%                                  s
%                                  t
%                                 %t_shift(s,t)
%                                 %t_shift2(s2,t2,s,t)
%                                 %min_tm3
%                                 %sh
%                                 figure
%                                 plot(wav,'ro-')
%                                 hold on
%                                 plot(residue(:,s,t),'ko-')
%                                 %residue(:,s,t)
%                                 plot(res(:,:,shi2),'b');
%
%                       end

                    %                     if t==1 & t2==2
                    %                         min_res2 = residue2(:,shi,ti,s,t);
                    %                         figure
                    %                         plot(min_res2)
                    %                         t
                    %                         t2
                    %                         min_tm2
                    %                         t_shift(s,t)
                    %                         tshift2(shi,ti,s,t)
                    %                     end

                    min_tm2 = max([min_tm2 rm2(shi2)]);

                    if (min_tm2<final_match(t)) && (min_tm2<final_match(t2)) &&  ( rm2(shi2)<final_match(t) ) &&  ( rm2(shi2)<final_match(t2) )

                        final_match(t)  = min_tm2;
                        final_match(t2) = min_tm2;
                        final_shift(t) = t_shift(s,t);
                        final_shift(t2) =  t_shift2(shi2,t2,s,t); %sh(shi2);


%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% START - Graphical Debugging
%
%                         %if(t==1 & t2==2)
%                         close all
%
%                         disp(['found overlap of 2 match --> ' num2str(final_match(t))])
%
%                         tm2
%                         rm2
%                         figure; plot(wav,'r'); hold on; plot(res,'b')
%                         sh
%
%
%                         ax = [1 points min(wav)*1.50 max(wav)*1.50  ];
%
%
%                         al_temp1 = zeros(48,1);
%                         t1wav = temp(:,t);
%                         final_shift(t)
%                         if final_shift(t)>0
%                             al_temp1(final_shift(t):points) = t1wav(1:points-final_shift(t)+1  );
%                         elseif final_shift(t)==0
%                             al_temp1 = t1wav;
%                         elseif final_shift(t)<0
%                             al_temp1(1:points+final_shift(t)+1) = t1wav(-1*final_shift(t):points  );
%                         end
%
%
%                         al_temp2 = zeros(48,1);
%                         t2wav = temp(:,t2);
%                         if final_shift(t2)>0
%                             al_temp2(final_shift(t2):points) = t2wav(1:points-final_shift(t2)+1  );
%                         elseif final_shift(t2)==0
%                             al_temp2 = t2wav;
%                         elseif final_shift(t2)<0
%                             al_temp2(1:points+final_shift(t2)+1) = t2wav(-1*final_shift(t2):points  );
%                         end
%
%                         figure
%                         subplot(311)
%                         hold on
%                         plot(wav,'ko-')
%                         %plot(temp(:,t),'r')
%                         plot(al_temp1,'r')
%                         axis(ax)
%
%                         subplot(312)
%                         hold on
%                         plot(residue(:,s,t),'ko-')
%                         %plot(temp(:,t),'r')
%                         plot(al_temp2,'r')
%                         axis(ax)
%
%                         min_res2 = res(:,shi2);
%                         subplot(313)
%                         hold on
%                         plot(min_res2,'ko-')
%                         axis(ax)
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Graphical Debugging - END
                        if(min_tm2<th_o)
                          for t = 1:nt
                             if final_match(t) ~= min(final_match)
                                final_match(t) = inf;
                             end
                           end
                            return
                        end


                   end

                end

            end

        end
    end
end



check_overlaps3 = 1; %(min(final_match)>th) & ( min_amp_res2 > (min(amp_temp)- (2*th*(min(amp_temp)/100)) ) )  &  (min_amp_res2<=amp_wav);



if (check_overlaps2 && check_overlaps3)
    for t = 1:nt
        for t2 = 1:nt
            for t3 = 1:nt

                if  (t~=t2) && (t~=t3) && (t2~=t3)

                    for s = 1:ns
                        for s2 = 1:ns

                            [tm3, rm3, ~, t_shift3]= temp_match_X(residue2(1:points,s2,t2,s,t), temp(:,t3) );

                            %                         for a = 2:ns
                            %                             r3amp(a) = max(res(:,a))-min(res(:,a));
                            %                         end

                            %                         residue3(1:points,1:ns,s2,t2,s,t) = res;
                            %                         tshift3(1:ns,t,s,t2) = sh;

                            [min_tm3, shi3] = min(tm3);


%                             if     s2==1 & t2==3 & s==3 & t==1      %t == 1 & t_shift(s,t) ==  12
%
%                                 t_shift(s,t)
%                                 t_shift2(s2,t2,s,t)
%                                 t_shift3(shi3)
%                                 min_tm3
%
%                             end

%                      if t == 1 &  t2 == 3 & t_shift(s,t) ==  12
%
%
%
%                                 figure
%                                 plot(wav,'ro-')
%                                 hold on
%                                 plot(residue2(:,s2,t2,s,t),'ko-')
%                                 %residue(:,s,t)
%                                 plot(res3(:,:,1),'b');
%
%                                 disp('shifts...')
%                                 t_shift(s,t)
%                                 t_shift2(s2,t2,s,t)
%                                 t_shift3(shi3)
%
%
%                       end

                            min_tm3 = max([min_tm3 rm3(shi3)]);

                            if (min_tm3<final_match(t)) && (min_tm3<final_match(t2)) && (min_tm3<final_match(t3))  &&  ( rm3(shi3)<final_match(t) ) &&  ( rm3(shi3)<final_match(t2) )  &&  ( rm3(shi3)<final_match(t3) )

                                final_match(t)  = min_tm3;
                                final_match(t2) = min_tm3;
                                final_match(t3) = min_tm3;

                                final_shift(t) = t_shift(s,t);
                                final_shift(t2) = t_shift2(s2,t2,s,t);
                                final_shift(t3) = t_shift3(shi3);

%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% START - Graphical Debugging
%                         close all
%                         ax = [1 points min(wav)*1.50 max(wav)*1.50  ];
%
% %                         t
% %                         t2
% %                         t3
%
%                         al_temp1 = zeros(48,1);
%                         t1wav = temp(:,t);
%                         if final_shift(t)>0
%                             al_temp1(final_shift(t):points) = t1wav(1:points-final_shift(t)+1  );
%                         elseif final_shift(t)==0
%                             al_temp1 = t1wav;
%                         elseif final_shift(t)<0
%                             al_temp1(1:points+final_shift(t)+1) = t1wav(-1*final_shift(t):points  );
%                         end
%
%
%                         al_temp2 = zeros(48,1);
%                         t2wav = temp(:,t2);
%                         if final_shift(t2)>0
%                             al_temp2(final_shift(t2):points) = t2wav(1:points-final_shift(t2)+1  );
%                         elseif final_shift(t2)==0
%                             al_temp2 = t2wav;
%                         elseif final_shift(t2)<0
%                             al_temp2(1:points+final_shift(t2)+1) = t2wav(-1*final_shift(t2):points  );
%                         end
%
%                         al_temp3 = zeros(48,1);
%                         t3wav = temp(:,t3);
%                         if final_shift(t3)>0
%                             al_temp3(final_shift(t3):points) = t3wav(1:points-final_shift(t3)+1  );
%                         elseif final_shift(t3)==0
%                             al_temp3 = t3wav;
%                         elseif final_shift(t3)<0
%                             al_temp3(1:points+final_shift(t3)+1) = t3wav(-1*final_shift(t3):points  );
%                         end
%
%                         figure
%                         subplot(411)
%                         hold on
%                         plot(wav,'ko-')
%                         %plot(temp(:,t),'r')
%                         plot(al_temp1,'r')
%                         axis(ax)
%
%                         subplot(412)
%                         hold on
%                         plot(residue(:,s,t),'ko-')
%                         %plot(temp(:,t),'r')
%                         plot(al_temp2,'r')
%                         axis(ax)
%
%                         subplot(413)
%                         hold on
%                         plot( residue2(:,s2,t2,s,t),'ko-')
%                         %plot(temp(:,t),'r')
%                         plot(al_temp3,'r')
%                         axis(ax)
%
%                         subplot(414)
%                         min_res3 = res3(:,shi3);
%                         plot(min_res3,'ko-')
%                         axis(ax)
%
%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Graphical Debugging - END

                                if(tm3<th_o)
                                    for t = 1:nt
                                         if final_match(t) ~= min(final_match)
                                            final_match(t) = inf;
                                          end
                                    end
                                    return
                                end


                            end

                        end

                    end
                end
            end
        end
    end
end



for t = 1:nt
    if final_match(t) ~= min(final_match)
        final_match(t) = inf;
    end
end

