function [th]= set_threshold(waves, threshold)
%function [th]= set_threshold(waves, threshold)

[points nw] = size(waves);

wvec = zeros(1,nw*5);

c = 1;
for w = 1:nw
wvec(c:c+4) = waves(1:5,w)';
c = c+5;
end


wvec = sqrt(power(wvec,2));

swvec = sort(wvec);

thn = round( (threshold*nw*5) / 100);

th = swvec(thn);


% disp( ['Threshold set to ' num2str(nsdev)  ' SDEVs --->   ' num2str(th)] )
% disp( ['Threshold set to include ' num2str(threshold)  '% of noise sample --->   ' num2str(th)] )

