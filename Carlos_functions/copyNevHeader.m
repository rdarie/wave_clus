     
function [] = copyNevHeader(original_filename, new_filename)
%
% function [] = copyNevHeader(original_filename, new_filename);

% OLD FORM OF FUNCTION - function [] = copyNevHeader(original_fid, filename);
% %%%%%%%%%%%%%%%%%%%%% OLD Version
% 
% nev = openNEV(original_filename); 
% fid = nev.FileInfo.fid;
% getNEVStimulus(nev);
% 
% nh = readNEVBasicHeader(fid);
% doff = nh.dataOffset; % = number of bytes in the basic + extended header packsize = nh.packetLength;

% %%%%%%%%%%%%%%%%%%%%% New Version.... not done yet

fid = fopen(original_filename);
fseek(fid, 0, 'bof');
fileTypeID = char(fread(fid, 8, '*uint8')');
fileSpec = fread(fid, 1, 'uint8') + fread(fid, 1, 'uint8')/10.0;
%if A.fileSpec < 2.0, error('Attempting to open a non-2.0 compliant NEV file.'); end;
formatAddtl = fread(fid, 1, '*uint16');
dataOffset = fread(fid, 1, '*uint32');
packetLength = fread(fid, 1, '*uint32');
timeResolution = fread(fid, 1, '*uint32');
sampleResolution = fread(fid, 1, '*uint32');
% TimeOrigin = fread(fid, 8, 'uint16')
% application = deblank(char(fread(fid, 32, 'uchar')'))
% comment = deblank(char(fread(fid, 256, 'char')'))
% headerCount = fread(fid, 1, 'uint32')

doff = dataOffset;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




fseek(fid, 0, 'bof');
headers = fread(fid,doff,'*uint8');


new_fid = fopen(new_filename,'w','l');
fwrite(new_fid, headers, 'uint8');

%doff = doff+1; %index of first data packet

fclose(new_fid);
fclose(fid);

%closeNEV(nev);



%fseek(fid, 0, 'bof');

% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BASIC HEADER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fileTypeID = 'NEURALEV';
% %fileTypeID = 'AUTOSNEV'
% fwrite(fid,fileTypeID,'char');
% 
% %%file spec
% fwrite(fid,0,'uchar');
% fwrite(fid,0210,'uchar');
% 
% %additional flags, not used
% fwrite(fid,[0001],'uint16');
% 
% %data offset = number of bytes in basic + extended header
% fwrite(fid,4944,'uint32'); %for 144 extended header packets
% 
% %PacketLength = bytes per data packet
% fwrite(fid,104,'uint32');
% 
% %Time resolution
% fwrite(fid,30000,'uint32');
% 
% %Sample resolution
% fwrite(fid,30000,'uint32');
% 
% %Time Origin
% ct = clock;
% fwrite(fid,[clock 0 0],'uint16');
% 
% %%Application used to create file
% %fwrite(fid,'Cerebus File Dialog v2.7.0.0 1', 'uchar');
% fwrite(fid,['__DGCC_SWD_automated_sorter_____'], 'uchar');
% %fwrite(fid, 0, 'ubit8');%null character???
% 
% 
% %%%% comment --> 256 chars or null terminated string
% %no_com = zeros(1,256)+1;
% %fwrite(fid, int2str(no_com), 'char'); 
% 
% %fwrite(fid, 'test_version', 'char'); 
% %fwrite(fid, 0, 'ubit8'); %null character???
% 
% fwrite(fid, 'test_version____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________', 'char'); %256 chars or null terminated string
% 
% 
% %header count
% %fwrite(fid,144,'uint32');
% fwrite(fid,0,'uint32'); % no extended header
% 
% fclose(fid);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%           fileTypeID: 'NEURALEV'
%             fileSpec: 2.1000
%          formatAddtl: 1
%           dataOffset: 4944
%         packetLength: 104
%       timeResolution: 30000
%     sampleResolution: 30000
%           TimeOrigin: [8x1 double]
%          application: 'Cerebus File Dialog v2.7.0.0 1\L'
%              comment: ''
%          headerCount: 144


% A.fileTypeID = char(fread(fid, 8, 'char')');
% A.fileSpec = fread(fid, 1, 'uchar') + fread(fid, 1, 'uchar')/10.0;
% A.formatAddtl = fread(fid, 1, 'uint16');
% A.dataOffset = fread(fid, 1, 'uint32');
% A.packetLength = fread(fid, 1, 'uint32');
% A.timeResolution = fread(fid, 1, 'uint32');
% A.sampleResolution = fread(fid, 1, 'uint32');
% A.TimeOrigin = fread(fid, 8, 'uint16');
% A.application = deblank(char(fread(fid, 32, 'uchar')'));
% A.comment = deblank(char(fread(fid, 256, 'char')'));
% A.headerCount = fread(fid, 1, 'uint32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    END       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BASIC HEADER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%











