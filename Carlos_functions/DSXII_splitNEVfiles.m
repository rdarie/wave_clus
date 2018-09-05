function DSXII_splitNEVfiles(NEVFileName, varargin)
% 	DSXII_MERGENEVFILES   merges the NEV files given in nevFileNames and saves it to nevFileNames.
% 		DSXII_MERGENEVFILES(NEVFileNames, newNEVFileName)
%
% 	NEVFileNames is a cell array of strings
%
% 	Created by Jonas B Zimmermann on 2013-10-31.
% 	Copyright (c) 2013 Donoghue Lab, Neuroscience Department, Brown University.
% 	All rights reserved.
% 	@author  $Author: Jonas B Zimmermann$

if nargin == 1
	newSuffix = '_DSXII_sorted';
else
	newSuffix = varargin{1};
end

if ~ischar(NEVFileName)
	error('File name required')
end


if ~exist([NEVFileName '.nev'], 'file')
	error(['We cannot find the file ''', NEVFileName '.nev''.' ])
end

if ~exist([NEVFileName '.txt'], 'file')
	error(['We cannot find the file ''', NEVFileName '.txt'', which is needed to tell us offsets.' ])
end

fid = fopen([NEVFileName '.txt']);
myd = textscan(fid,'%s%s',1,'delimiter',',');
myd = textscan(fid,'%u32%s','delimiter',',');

NEV = openNEV(['./' NEVFileName '.nev'], 'read');
spikeStruct = NEV.Data.Spikes;

n_NEVs = length(myd{1});
timeoffsets = myd{1};
filenames = myd{2};

for i_nev = 1:n_NEVs
	if ~exist([filenames{i_nev} '.nev'], 'file')
		error([filenames{i_nev} '.nev is not a file.']);
	end
end

for i_nev = 1:n_NEVs
	spikeStruct2 = spikeStruct;
	if i_nev == n_NEVs
		spike_ind = (spikeStruct.TimeStamp >= timeoffsets(n_NEVs));
	else
		spike_ind = (spikeStruct.TimeStamp >= timeoffsets(i_nev)) & (spikeStruct.TimeStamp < timeoffsets(i_nev+1));
	end
	spikeStruct2.TimeStamp = spikeStruct.TimeStamp(spike_ind)-timeoffsets(i_nev);
	spikeStruct2.Electrode = spikeStruct.Electrode(spike_ind);
	spikeStruct2.Unit = spikeStruct.Unit(spike_ind);
	spikeStruct2.Waveform = spikeStruct.Waveform(:, spike_ind);
    fprintf('Saving file %i of %i, %s ... \n', i_nev, n_NEVs, [filenames{i_nev} newSuffix]);
	saveNEVSpikesAuto(spikeStruct2, [filenames{i_nev} '.nev'], [filenames{i_nev} newSuffix]);
	NPMKcopyNevEvents(['./' filenames{i_nev} '.nev'], [filenames{i_nev} newSuffix '.nev']);
end

end %  function
