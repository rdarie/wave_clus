function DSXII_mergeNEVfiles(NEVFileNames, newNEVFileName)
% 	DSXII_MERGENEVFILES   merges the NEV files given in nevFileNames and saves it to nevFileNames.
% 		DSXII_MERGENEVFILES(NEVFileNames, newNEVFileName)
%
% 	NEVFileNames is a cell array of strings
%
% 	Created by Jonas B Zimmermann on 2013-10-31.
% 	Copyright (c) 2013 Donoghue Lab, Neuroscience Department, Brown University.
% 	All rights reserved.
% 	@author  $Author: Jonas B Zimmermann$

if isempty(NEVFileNames) || isempty(newNEVFileName) || ~iscellstr(NEVFileNames) || length(NEVFileNames) < 2
	error('File names required')
end

n_NEVs = length(NEVFileNames);

for i_nev = 1:n_NEVs
	if ~exist(NEVFileNames{i_nev}, 'file')
		error([NEVFileNames{i_nev} ' is not a file.']);
	end
end
timeoffsets = zeros(n_NEVs + 1, 1);
filenames = cell(n_NEVs, 1);

NEV = openNEV(['./' NEVFileNames{1}], 'read');
spikeStruct = NEV.Data.Spikes;
timeoffsets(2) = spikeStruct.TimeStamp(end) + 1;
filenames{1} = NEV.MetaTags.Filename;

for i_nev = 2:n_NEVs
	clear NEV
	NEV = openNEV(['./' NEVFileNames{i_nev}], 'read');
	spikeStruct2 = NEV.Data.Spikes;
	addOffset = timeoffsets(i_nev);
	spikeStruct.TimeStamp = [spikeStruct.TimeStamp, spikeStruct2.TimeStamp + addOffset];
	spikeStruct.Electrode = [spikeStruct.Electrode, spikeStruct2.Electrode];
	spikeStruct.Unit = [spikeStruct.Unit, spikeStruct2.Unit];
	spikeStruct.Waveform = [spikeStruct.Waveform, spikeStruct2.Waveform];
	timeoffsets(i_nev+1) = addOffset + spikeStruct2.TimeStamp(end) + 1;
	filenames{i_nev} = NEV.MetaTags.Filename;
end

saveNEVSpikesWithOldNEV(spikeStruct, NEVFileNames{1}, newNEVFileName);
tf=fopen([newNEVFileName, '.txt'], 'w');
fprintf(tf, 'Offset,FileName\n');
for i_nev = 1:n_NEVs
	fprintf(tf, '%i,%s\n', timeoffsets(i_nev), filenames{i_nev});
end
fclose(tf);
end %  function
