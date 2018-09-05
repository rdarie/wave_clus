% Extract neural timestamps (including sorted unit info) from a nev file
% using the NPMK toolbox
% @version $Id$
% @author Carlos Vargas-Irwin, Jonas Zimmermann
function [sorted_timestamps, snr, unit_index, noise_amp, spike_amp, spike_waveforms, save_file_name] = getNevTimestampsSNR(varargin)
% 		[...] = GETNEVTIMESTAMPSSNR()
% 				prompts to open NEV file
% 		[...] = GETNEVTIMESTAMPSSNR(NEVFilename)
% 				opens NEV file given by NEVFilename
% 		[...] = GETNEVTIMESTAMPSSNR(NEV)
% 				assumes NEV to be a structure returned by openNEV
options.OutPath = '';

for i=1:length(varargin)
	if isstruct(varargin{i}) && isfield( varargin{i}, 'Data') ...
			&& isfield( varargin{i}.Data, 'Spikes') ...
			&& isfield( varargin{i}.Data.Spikes, 'TimeStamp') ...
			&& isfield( varargin{i}.Data.Spikes, 'Electrode')
		NEV =  varargin{i};
	elseif ~ischar(varargin{i}) && isstruct(varargin{i})
		options = nest_struct_merge(varargin{i}, options);
	elseif ischar(varargin{i}) && ~exist('fileFullPath', 'var')
		fileFullPath = varargin{i};
		[p,f,e] = fileparts(fileFullPath);
		if isempty(p)
			p = pwd;
		end
		fileFullPath = fullfile(p,[f, e]);
		if exist(fileFullPath, 'file') ~= 2
			error('The file does not exist.');
		end
	end
end

if ~exist('NEV', 'var')
	if ~exist('fileFullPath', 'var')
		if exist('getFile.m', 'file') == 2
			[fileName, pathName] = getFile('*.nev', 'Choose a NEV file...');
		else
			[fileName, pathName] = uigetfile('*.nev');
		end
		fileFullPath = [pathName, fileName];
		if fileFullPath==0;
			odat = [];
			error('No file was selected.');
		end
	end
	NEV = openNEV(fileFullPath, 'read', 'report',  'nowarning', 'nosave', 'nomat');
end

if ~exist('NEV', 'var')  || ~isfield( NEV, 'Data') ...
		||  ~isfield( NEV.Data, 'Spikes')
	error('Failed to generate a valid NEV file structure :(');
end
if ~exist('fileName', 'var')
    fileName = [NEV.MetaTags.Filename '.nev'];
end
if ~exist('pathName', 'var')
    pathName = NEV.MetaTags.FilePath;
end
if ~exist('fileFullPath', 'var')
	fileFullPath = fullfile(pathName, fileName);
end
if isempty(options.OutPath)
	options.OutPath = pathName;
end
nunits = 0;
electrode_names = cell(1000, 1);
spike_waveforms = struct([]);
ueids = unique(NEV.Data.Spikes.Electrode);

for i_id = 1:numel(ueids)
    eid = ueids(i_id);

    ets = double(NEV.Data.Spikes.TimeStamp( NEV.Data.Spikes.Electrode == eid )) / double(NEV.MetaTags.TimeRes); % timestamps in sec


    eunit = NEV.Data.Spikes.Unit( NEV.Data.Spikes.Electrode == eid );
    if (str2double(NEV.MetaTags.FileSpec) >=2.3)
        ewav = double(NEV.Data.Spikes.Waveform(:,NEV.Data.Spikes.Electrode == eid)) / 4;   % divide amplitudes by four for filespec 2.3
    else
        ewav = double(NEV.Data.Spikes.Waveform(:,NEV.Data.Spikes.Electrode == eid));
    end


    %estimate noise amplitude for this channel using first 5 samples
    range_pos = zeros(5,1);
    range_neg = zeros(5,1);
    for n = 1:5
        ne = noextremes( ewav(n,:),95);
        range_pos(n,1) = max(ne);
        range_neg(n,1) = min(ne);
    end
    n_amp = mean(range_pos) - mean(range_neg);



    for eu = unique(eunit)


        if (eu ~= 255) % disregard units marked as noise (invalidated)


        nunits = nunits +1;
        sorted_timestamps{nunits} = ets(eunit == eu);
        waves = ewav(:,eunit == eu);

		if isfield(NEV.ElectrodesInfo(eid), 'ElectrodeLabel')
	        electrode_names{nunits} = deblank( NEV.ElectrodesInfo(eid).ElectrodeLabel');
		else
			electrode_names{nunits} = sprintf('chan%i', NEV.ElectrodesInfo(eid).ElectrodeID);
		end
        %%%%%% SNR
        %get spike amplitude
%         mwave = mean(waves');
%         s_amp = max(mwave) - min(mwave);
        s_amp =  mean(max(waves) - min(waves));
        noise_amp(1,nunits) =   n_amp;
        spike_amp(1,nunits) =  s_amp ;

        snr(1,nunits) =  s_amp / n_amp;
        %%%%%%%%%%%   SNR

        unit_index(1,nunits) = eid;
        unit_index(2,nunits) = eu;

		spike_waveforms(nunits).Mean = mean(waves, 2);
		spike_waveforms(nunits).StdDev = std(waves, [], 2);
		spike_waveforms(nunits).SR = double(NEV.MetaTags.TimeRes);
        end
    end
end

if nunits > 0

units = find(unit_index(2,:)>0);
good_units_1p2 = intersect(units,find(snr>1.2));
good_units_1p5 = intersect(units,find(snr>1.5));


unit_index(:, good_units_1p2);
unit_index(:, good_units_1p5);

electrode_names = electrode_names(1:nunits);
else
    sorted_timestamps = {[]};
    snr = [];
    unit_index = zeros(2,0);
    noise_amp = [];
    spike_amp = [];
    electrode_names = {};
    spike_waveforms = struct();
    spike_waveforms.Mean = [];
    spike_waveforms.StdDev = [];
    spike_waveforms.SR = [];
end

%spike_waveforms = spike_waveforms(1:nunits);

[~, fn, ext] = fileparts(fileName);
save_file_name = fullfile(options.OutPath, [fn, '_gNTSNR.mat']);
save(save_file_name, 'sorted_timestamps', 'snr', 'unit_index', 'noise_amp', 'spike_amp', 'electrode_names', 'spike_waveforms', '-v7' );

