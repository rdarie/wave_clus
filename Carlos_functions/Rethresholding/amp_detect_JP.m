function [spikes,thr,index] = amp_detect_JP(x,myThreshold,thresholdDirection)
% function [spikes,thr,index] = amp_detect(x,handles);
% Detect spikes with amplitude thresholding. Uses median estimation.
% Detection is done with filters set by fmin_detect and fmax_detect. Spikes
% are stored for sorting using fmin_sort and fmax_sort. This trick can
% eliminate noise in the detection but keeps the spikes shapes for sorting.
% ref makes sure not to count samples within a predefined period.


%Written by Quian Quiroga, modified by Janos Perge 2010.June

x2  = x;

par.w_pre=14;                        % number of pre-event data points stored
par.w_post=35;                       % number of post-event data points stored
par.sr=30000;                           % sampling rate
ref = 1.5;                           % detector dead time (in ms) which is 45 samples at 30KHz sampling rate
par.ref = floor(ref *par.sr/1000);   % conversion to datapoints
par.stdmin = 4;                      % minimum threshold for detection
par.stdmax = 500;                     % maximum threshold for detection

if nargin==2
par.detection = 'neg';
elseif nargin == 3
    par.detection = thresholdDirection;
end
%par.detection = 'both';
%par.detection = 'pos';               % type of threshold

sr=par.sr;
w_pre=par.w_pre;
w_post=par.w_post;
ref=par.ref;
detect = par.detection;
stdmin = par.stdmin;
stdmax = par.stdmax;

if nargin==1
    noise_std_detect = median(abs(x))/0.6745;
    thr = stdmin * noise_std_detect;        %threshold for detection
    thrmax = stdmax * noise_std_detect;     %thrmax for artifact removal
else
    thr = myThreshold;
    thrmax = 10000;  %%arbitrary large number to avoid artifact removal
end

index = zeros(1, 1e5);
%%LOCATE SPIKE TIMES
nspk = 0;
extreme_fun = @(x)max(abs(x));
switch detect
    case 'pos'
        xaux = find(x(w_pre+2:end-w_post-2) > thr) +w_pre+1;
        extreme_fun = @(x)max(x);
    case 'neg'
        xaux = find(x(w_pre+2:end-w_post-2) < -thr) + w_pre+1;
        extreme_fun = @(x)min(x);
    case 'both'
        xaux = find(abs(x(w_pre+2:end-w_post-2)) > thr) +w_pre+1;
end
xaux0 = 0;
for i=1:length(xaux)
    if xaux(i) >= xaux0 + ref
        %introduces alignment, depending on what kind of extremum we look for
        [~, iaux] = extreme_fun((x(xaux(i):xaux(i)+floor(ref/2)-1)));
        nspk = nspk + 1;
        index(nspk) = iaux + xaux(i) -1;
        xaux0 = index(nspk);
    end
end
index = index(1:nspk);

% % SPIKE STORING (with or without interpolation)
ls=w_pre+w_post;
spikes=zeros(nspk,ls+4);
x=[x zeros(1,w_post)];
for i=1:nspk                          %Eliminates artifacts
    if max(abs( x(index(i)-w_pre:index(i)+w_post) )) < thrmax
        spikes(i,:)=x(index(i)-w_pre-1:index(i)+w_post+2);
    end
end
aux = find(spikes(:,w_pre)==0);       %erases indexes that were artifacts
spikes(aux,:)=[];
try
index(aux)=[];
catch ME
    disp(ME)
end
spikes(:,[49:end]) = [];
spikes = spikes';

% Plot_continuous_data(x(1:floor(60*sr)),handles,thr,thrmax)
