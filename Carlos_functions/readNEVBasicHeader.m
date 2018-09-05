function A = readNEVBasicHeader(fid);
%function A = readNEVBasicHeader(fid);
%
% This function is called by openNEV to read the basic header information from version 
% 2.0 NEV files. File must be open and have read access permission.
%
% SEE ALSO: openNEV.m
%
% Written by: E. Maynard   Date: 8/9/00  Version 1.0

fseek(fid, 0, 'bof');
A.fileTypeID = char(fread(fid, 8, 'char')');
A.fileSpec = fread(fid, 1, 'uchar') + fread(fid, 1, 'uchar')/10.0;
%if A.fileSpec < 2.0, error('Attempting to open a non-2.0 compliant NEV file.'); end;
A.formatAddtl = fread(fid, 1, 'uint16');
A.dataOffset = fread(fid, 1, 'uint32');
A.packetLength = fread(fid, 1, 'uint32');
A.timeResolution = fread(fid, 1, 'uint32');
A.sampleResolution = fread(fid, 1, 'uint32');
A.TimeOrigin = fread(fid, 8, 'uint16');
A.application = deblank(char(fread(fid, 32, 'uchar')'));
A.comment = deblank(char(fread(fid, 256, 'char')'));
A.headerCount = fread(fid, 1, 'uint32');