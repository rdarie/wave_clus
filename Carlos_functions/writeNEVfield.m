function count = writeNEVfield(nevObject, indices, field, data);
%function count = writeNEVfield(nevObject, indices, field, data);
%
% Reads the entire NEV file and returns the selected field. This function
% uses the byte positions for the data and does not check to see if the packet
% is a spike or stimulus. To return the information specific to a packet type,
% it is necessary to filter the result.This function is not designed to be called alone.
% INPUTS:
%	fid - file pointer to the open NEV file
%	field - string containing the field to return
%	offsets - starting positions of the packets to be read. If a single value then all packets read
%		starting at that point.
%	N - number of packets to read (default = all)

fid = nevObject.FileInfo.fid;
offsets = ((indices-1) .* nevObject.HeaderBasic.packetLength) + nevObject.HeaderBasic.dataOffset;
switch field,
	case 'electrode',
		offsets = offsets + 4;
	case 'unit',
		offsets = offsets + 6;
	otherwise,
		error(['Field ''' field ''' not recognized.']);
end
if length(data) == 1, data = ones(size(indices)) .* data; end;

H = waitbar(0, 'Writing fields to NEV file...');
for i = 1 : length(offsets),
	if mod(i, 100) == 0, waitbar(i/length(offsets)); end;
	fseek(fid, offsets(i)-ftell(fid), 'cof');
	switch field,
		case 'electrode',
			fwrite(fid, data(i), 'uint16');
		case 'unit',
			fwrite(fid, data(i), 'uchar');
	end
end
close(H);