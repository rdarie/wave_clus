

function [ waves ] = reconstruct_waves(wav, temp, temp_shift, temp_match, threshold, av_th)


[points nt] = size(temp);

al_temp = zeros(points,nt);

for t = 1:nt

amp(t) =  max( temp(:,t) ) - min( temp(:,t) );
    
    at = zeros(points,1);
    twav = temp(:,t);
    if temp_shift(t)>0
        at(temp_shift(t):points) = twav(1:points-temp_shift(t)+1  );
        al_temp(:,t) = at;
    elseif temp_shift(t)<0
        at(1:points+temp_shift(t)+1) = twav(-1*temp_shift(t):points  );   
        al_temp(:,t) = at;
    elseif temp_shift(t)==0
        al_temp(:,t) = twav;
    end
    
    
    
end


% figure
% plot(wav, 'bo-')
% hold on
% plot(al_temp, 'r')


%nw = length(find(temp_match<threshold))
waves = zeros(points,nt);

%count = 1;
for t = 1:nt

    
    if  length( find(temp_match == min(temp_match)) )>1
        class_th = (threshold+(max(amp)* (av_th/100) ));
    else
        class_th = (threshold+(amp(t)* (av_th/100) ));
    end
    
    
    if(temp_match(t)<class_th) % & (temp_match(t)==min(temp_match(t)))
        waves(:,t) = wav;
        for s = 1:nt
            if(temp_match(s)<class_th) & s~=t
                waves(:,t) = waves(:,t)  - al_temp(:,s);
                %display(['template ' int2str(s) ' subtracted!!'])
              
            end
        end
        %count = count+1;
    end
    
end

% figure
% plot(waves)

%waves(:,2) = wav - al_temp(:,1) - al_temp(:,3);
%waves(:,3) = wav - al_temp(:,1) - al_temp(:,2);


% figure
% subplot(nw+1,1,1)
% plot(wav, 'ko-')
% ax = axis;
% for w = 1:nw
% subplot(nw+1,1,w+1)
% plot(waves(:,w))
% axis(ax)
% end









