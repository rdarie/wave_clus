function [waves, timestamps, savefname] = rethresholdNS5(filename,refChs,RMS,timesRMS,lowcutoff,highcutoff,save_nev, out_dir)
% [waves timestamps ] = rethresholdNS5(filename,refChs,RMS,timesRMS,lowcutoff,highcutoff,save_nev)
% helper function for rethresholdNS5toNev
% Produces a new nev file from an NS5 using the supplied params

[in_dir, in_fn, ~] = fileparts(filename);
if nargin < 8
    out_dir = in_dir;
end
blocklength = 600;

in_nev_fn = fullfile(in_dir, [in_fn, '.nev']);

if save_nev
    %look for corresponding NEV (matching NS5 filename); copy nev header
    savefname = fullfile(out_dir, [in_fn, '_RETVR.nev']);
    copyNevHeader(in_nev_fn, savefname);
    % copy events ??
%    NPMKcopyNevEvents([filename(1:end-4) '.nev'], savefname);
end


sns = openNSx('noread',filename);
nCh = sns.MetaTags.ChannelCount;
totalDuration = sns.MetaTags.DataDurationSec;
nyqFreq = double(sns.MetaTags.SamplingFreq)/2;
        normW   = lowcutoff / nyqFreq;
        normWh  = highcutoff / nyqFreq;
        [b,a]   = butter(4,[normW normWh]);
    numblocks = ceil(totalDuration/blocklength);

    tix = 0;
    for k = 1:numblocks

        fprintf('Processing block.... %i/%i\n', k, numblocks);
        if k < numblocks
            sns = openNSx('read',filename, ['t:' num2str(tix) ':' num2str(tix+blocklength) ], 'sec');
        else
            sns = openNSx('read',filename, ['t:' num2str(tix) ':' num2str(totalDuration) ], 'sec');
        end

        if ~isempty(refChs)
            vRef = mean(double(sns.Data(refChs,:)));
        else
            vRef = 0;
        end
        for i = 1:nCh
            dat = filtfilt(b,a,double(sns.Data(i,:))-vRef);
            [spikes,~,sptStamps] = amp_detect_JP(dat,abs(RMS(i))*timesRMS);
            wavesk{i,k}  = int16(spikes);
            timestampsk{i,k}= uint32(sptStamps+(tix*sns.MetaTags.SamplingFreq));
        end
        tix = tix + blocklength;
    end
    
    waves = cell(nCh, 1);
    timestamps = cell(nCh, 1);
    for i = 1:nCh
        waves{i} = [wavesk{i,:}];
        timestamps{i} = [timestampsk{i,:}];

        if (save_nev) && (length(timestamps{i})>1)
            % save results to new nev file
			if isfield(sns, 'ElectrodesInfo')
	            ect = zeros(1,length(timestamps{i}), 'uint16') + (sns.ElectrodesInfo(i).ElectrodeID);
			else
				ect = zeros(1,length(timestamps{i}), 'uint16') + uint16(sns.MetaTags.ChannelID(i));
			end
            u = zeros(1,length(timestamps{i}));
            fprintf(':::::::: Ch %i/%i writing %i spike waves to nev...\n', i, nCh, length(waves{i}));
            %%%%%%%%%%%%%%%%
            insertSpike(savefname, timestamps{i}, ect, u, waves{i});
            %%%%%%%%%%%%%%%%
        end
    end

if save_nev
    NEV = openNEV(GetFullPath(in_nev_fn), 'nomat', 'nosave');
    saveNEVWithExtraData(savefname, savefname, 'comment_struct', NEV.Data.Comments, 'serdig_struct', NEV.Data.SerialDigitalIO);
end




