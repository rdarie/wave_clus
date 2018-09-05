


function [ optim count] = amp_variability(waves,temp)


[p nw] = size(waves);

[p nt] = size(temp);

n  = 1;
for w = 1:5:nw
    amp(n) = max(waves(:,w)) - min(waves(:,w));
    n = n+1;
end

ma = mean(amp);
sda = std(amp);

%eliminate outliers
fa = find(amp < ma + (5*sda));
amp = amp(fa);

%count = hist(amp,100);
%hist(amp,100)

edges = [1:max(amp)];
[count bin] = histc(amp,edges);
%bar(edges,count,'histc')


for w = 1:nt
    tamp(w) = max(temp(:,w)) - min(temp(:,w));
end

% params = mean, sigma, norm
ix = 1;
for t = 1:nt

    params(ix) = tamp(t); %aprox mean
    ix = ix +1;
    params(ix) = 10; %sd????
    ix = ix +1;
    params(ix) =  sum(count) / nt;
    ix = ix +1;
    
end

global Gdist
Gdist = count; 
optim = lsqnonlin(@gmm_fit_1D, params, 0, 1000);


%gmm1 = normpdf([1:350], optim(1),   optim(2) ) * optim(3);
%gmm2 = normpdf([1:350], optim(4),   optim(5) ) * optim(6);

% hold on;
% h = plot(gmm1+gmm2,'r')
% set(h,'linewidth',3)




% g = zeros(length(count),p);
% for t = 1:nt
% 
%     half = length(find(amp>tamp(t)));
% 
%     coverage = 100;
%     th = 0;
%     while coverage > 0.05
%         th = th+5;
%         coverage = sum(count( round(tamp(t)+th):end)) / half;
%     end
% 
%     sd(t) = th / 2;
% 
%     g(:,t) = normpdf([1:length(count)], tamp(t), th/2);
%     scale = mean(count(round(tamp(t))-2:round(tamp(t))+2   )) / max(g(:,t))  ;
%     g(:,t) = g(:,t)*scale;
% 
%     count = count - g(:,t)';
%     for i= 1:length(count)
%         if(count(i)<0)
%             count(i) = 0;
%         end
%     end
% 
% 
% end
% 
% hold on
% plot( g(:,1)+g(:,2), 'r')















