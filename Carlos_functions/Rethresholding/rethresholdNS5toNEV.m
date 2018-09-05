
function [filelistNEV] = rethresholdNS5toNEV(varargin)
%
% rethresholdNS5toNEV
%
% + Produces new nev files starting from NS5 files using specified filtering and RMS
% + Uses virtual referencing (subtracting mean of the 80 channels with lowest RMS)
% + Can concatenate multiple files into a single merged nev
% + Requires orignal nev files (copies their headers onto the new ones)
% + saves mat file with parameters used
%
% OPTIONAL PARAMETERS:
% specify using strings followed by values, as in:
%    rethresholdNS5toNEV('lowcutoff',500,'filelist',myfiles)
%
% lowcutoff: low cutoff (Hz) for 4th order acausal butterworth filter (default = 250)
% highcutoff: high cuttoff for filter (default = 7500)
% RMSmult: RMS multiplier used to threshold data and detect spikes (default = 4)
% filelist: cell array of strings denoting filenames (default = all NS5 files in current directory)
% mergedfilename: combines list of files if there is more than one (default = 'MERGED.nev')
%
%  Carlos Vargas-Irwin with code from Janos Perge & Quian Quiroga
%  Donoghue Lab
%  Brown University Neurosicence Department
%  Dec 17, 2013


p = inputParser;
defaultlowcutoff = 250;
defaulthighcutoff = 7500;
defaultRMSmult = 4;
defaultReRefMethod = '80%';
addOptional(p,'lowcutoff',defaultlowcutoff,@isnumeric);
addOptional(p,'highcutoff',defaulthighcutoff,@isnumeric);
addOptional(p,'RMSmult',defaultRMSmult,@isnumeric);
addOptional(p,'ReReferencing',defaultReRefMethod,@ischar);
addOptional(p,'filelist',[]);
addOptional(p,'mergedfilename','MERGED.nev',@ischar);
addOptional(p,'out_dir', '', @ischar);

parse(p,varargin{:});

filelist = p.Results.filelist;

% if no file list is specified, get all ns5 and ns6 files in the current directory
if isempty(filelist)
    full_list = dir('*.ns*');
	res = regexp({full_list.name}, '.*\.ns[56]$');
	
    filelist = sort({full_list(cellfun(@(i)~isempty(i), res)).name});
end


mergedfilename = p.Results.mergedfilename;
lowcutoff = p.Results.lowcutoff;
highcutoff = p.Results.highcutoff;
RMSmult = p.Results.RMSmult;
ReRefMethod = p.Results.ReReferencing;
out_dir = p.Results.out_dir;
[f_dir, f_name, ~] = fileparts(filelist{1});
if isempty(out_dir)
    out_dir = f_dir;
end


%add nev extension if needed
if (length(filelist) > 1) && ~strcmp(mergedfilename(end-3:end),'.nev')
    mergedfilename = [mergedfilename '.nev'];
end
mergedfilename = fullfile(out_dir, mergedfilename);


%show params
file_l_str = strjoin(filelist, ', ');

fprintf('Files to process:\t%s.\nOutput file:\t\t%s.\nLow frequency cut-off: %0.1f. High frequency cut-off: %0.1f. RMS multiplier: %0.2f.\n', file_l_str, mergedfilename, lowcutoff, highcutoff, RMSmult);

% get re-thresholding params using all the NS5 files
data = cell(1, numel(filelist));
for f = 1:length(filelist)
display(['Opening file ' filelist{f}])
NS5 = openNSxSync('read',filelist{f}, 't:0:20', 'sec', 'p:double'); %% skipfactor is not working...
data{f} = NS5.Data;
end

datasample = [data{:}];

% if iscell(datasample)
% datasample = [datasample{:}];
% end 
[nCh, ~] = size(datasample);


nyqFreq = NS5.MetaTags.SamplingFreq/2;
normW   = lowcutoff / nyqFreq;
normWh  = highcutoff / nyqFreq;
[b,a]   = butter(4,[normW normWh]);


% determine reference channels and RMS threshold values for spikes
fprintf('Calculating RMS ...')

rms = zeros(nCh,1);
for i = 1:nCh
    dat = filtfilt(b,a,datasample(i,:));
    rms(i,1) = sqrt(mean(dat.^2));
end
fprintf(' DONE\n');

if strcmpi(ReRefMethod, '80%')
    %%channel selection criterion: use the first 80 % channels with lowest RMS noise
    n80perc = min(nCh, ceil(nCh * 0.8));
    chSpecs = [(1:nCh)' rms ];
    chSpecs = sortrows(chSpecs,2);
    chSpecs = chSpecs(1:n80perc,:);
    refChs  = sort(chSpecs(:,1));
    allBLK.refChannels = refChs;
    allBLK.oldrms         = rms;
    vRef = mean(datasample(refChs,:));
    % re-calculate RMS after virtual referencing
    for i = 1:nCh
        rmsDat = filtfilt(b,a,datasample(i,:)-vRef); % use Virtual Referencing
        rms(i,1) = sqrt(mean(rmsDat.^2));
        fprintf('Channel %i rms obtained... \n',i);
    end
else
    fprintf('No re-referencing will be performed.\n');
    refChs = [];
end


% save params
if length(filelist)>1
save([mergedfilename(1:end-4) '_NS5_EXTRACTION_PARAMS'],'filelist','mergedfilename', 'lowcutoff', 'highcutoff', 'RMSmult','rms','refChs')
else
    mergedfilename = [];
save(fullfile(out_dir, [f_name '_NS5_EXTRACTION_PARAMS']),'filelist','mergedfilename', 'lowcutoff', 'highcutoff', 'RMSmult','rms','refChs')
end


% rethreshold using extracted params & save as new nev
filelistNEV = cell(size(filelist));
for f = 1:length(filelist)
    [~, ~, filelistNEV{f}] = rethresholdNS5(filelist{f},refChs,rms,RMSmult,lowcutoff,highcutoff,1, out_dir);
end


%combine all re-thresholded nevs (keeping time offset between files!)
if length(filelistNEV)>1
 mergeNEVFiles(filelistNEV,mergedfilename, 'time_concat', 'real')
 filelistNEV{end + 1} = mergedfilename;
end




