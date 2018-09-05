function [n, ts, waves] = nex_wf(filename, varname)
% nex_wf(filename, varname): Read timestamps and waveforms from a .nex file
%
%   This function retrieves waveforms and timestamps from a single unit stored in a NEX file.
%   The nex file must  contain the specified waveform variable (something of the form sig001_wf ). 
%   The easiest way to accomplish this is to:
%   
%   (1) Sort the PLX file and SAVE it (OfflineSorter will only allow you to do this if you save the file with a new name).
%   (2) Open the SORTED PLX file with NEX. 
%   (3) SAVE the file you just opened as a NEX file. Now this function will be able to access all the data.
%   
%   NOTE: Do NOT use the 'save as nex' option in offline sorter. This will only save timestamps and events, but no waveforms!
%
% INPUT:
%   filename - if empty string, will use File Open dialog
%   varname - variable name
% OUTPUT:
%   n - number of timestamps
%   ts - array of timestamps (in seconds)
%waves - waveforms corresponding to the ts
%
%   SEE ALSO: get_nex_waves, nex_ts, nex_info
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   Last revision: Carlos Vargas, Feb 5 2004  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = 0;
ts = 0;

if(nargin ~= 2)
   disp('2 input arguments are required')
   return
end

if(ischar(filename) == 0)
   disp('input arguments should be character arrays')
   return
end

if(ischar(varname) == 0)
   disp('input arguments should be character arrays')
   return
end

if(length(filename) == 0)
   [fname, pathname] = uigetfile('*.nex', 'Select a Nex file');
	filename = strcat(pathname, fname);
end

fid = fopen(filename, 'r');
if(fid == -1)
	disp('cannot open file');
   return
end

%disp(strcat('file = ', filename));
magic = fread(fid, 1, 'int32');
version = fread(fid, 1, 'int32');
comment = fread(fid, 256, 'char');
freq = fread(fid, 1, 'double');
tbeg = fread(fid, 1, 'int32');
tend = fread(fid, 1, 'int32');
nvar = fread(fid, 1, 'int32');
fseek(fid, 260, 'cof');
name = zeros(1, 64);
found = 0;


last = 0;

for i=1:nvar
	type = fread(fid, 1, 'int32');
	var_version = fread(fid, 1, 'int32');
	name = fread(fid, [1 64], 'char');
    offset = fread(fid, 1, 'int32');
    n = fread(fid, 1, 'int32');
    
    wirenum = fread(fid, 1, 'int32');
    unitnum = fread(fid, 1, 'int32');
    gain = fread(fid, 1, 'int32');
    filter = fread(fid, 1, 'int32');
    
    xpos = fread(fid, 1, 'double');
    ypos = fread(fid, 1, 'double');
    frequency = fread(fid, 1, 'double');
    ADtoMV = fread(fid, 1, 'double');
    
    points = fread(fid, 1, 'int32');
    
    nmarkers = fread(fid, 1, 'int32');
    markLength = fread(fid, 1, 'int32');
    
    
	name = setstr(name);
	name = deblank(name);
	k = strcmp(name, deblank(varname));
	if(k == 1)
		found = 1;
		fseek(fid, offset, 'bof');
		ts = fread(fid, [1 n], 'int32');
        waves = fread(fid, [points n], 'int16');
        waves = waves*ADtoMV;
		break
	end
	%dummy = fread(fid, 128, 'char');
 	dummy = fread(fid, 68, 'char');
    
    
    position = ftell(fid) - last;
    last = ftell(fid);
    
end

fclose(fid);

if found == 0
	disp('did not find variable in the file');
else
	ts = ts/freq;
	%disp(strcat('number of timestamps = ', num2str(n)));
end
