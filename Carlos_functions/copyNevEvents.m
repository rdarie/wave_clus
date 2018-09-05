  
function [pindex] = copyNevEvents(original_filename, new_file);

% nev = openNEV(original_file)
% original_fid = nev.FileInfo.fid;
% getNEVStimulus(nev);
% 
% nh = readNEVBasicHeader(original_fid);
% doff = nh.dataOffset; % = number of bytes in the basic + extended header
% packsize = nh.packetLength;
% 
% pindex = nev.StimulusData.index;
% nump = length(pindex);



fid = fopen(original_filename);
fseek(fid, 0, 'bof');
fileTypeID = char(fread(fid, 8, 'uint8')')
fileSpec = fread(fid, 1, 'uint8') + fread(fid, 1, 'uint8')/10.0
%if A.fileSpec < 2.0, error('Attempting to open a non-2.0 compliant NEV file.'); end;
formatAddtl = fread(fid, 1, 'uint16')
doff = fread(fid, 1, 'uint32')


%new_fid = fopen(new_file,'w','l');
new_fid = fopen(new_file,'a');
        
%find events
H = waitbar(0, 'Copying Event Packets...');

%tic

disp( ['::: Copying ' int2str(nump) ' Event packets...'])
for packet = 1:nump
    %% update UI
    if mod(packet, 1000) == 0
        waitbar(p / nump);
    end;
    %%

    p = pindex(packet);
    
%     packet = getPackets(nev, p);
%     e = packet.electrode % set to zero for digital events
%     timest = packet.timeStamp
    
    fseek(original_fid, doff+(packsize*(p-1)), 'bof');
    ts = fread(original_fid, 1, 'ulong'); %32bit
    id = fread(original_fid, 1, 'uint16'); % set to zero for digital events
    r = fread(original_fid, 1, 'uint8'); % 8 bits
    z = fread(original_fid, 1, 'uint8');
    dio = fread(original_fid, 1, 'uint16');
    a1 = fread(original_fid, 1, 'int16') ; 
    a2 = fread(original_fid, 1, 'int16');
    a3 = fread(original_fid, 1, 'int16');
    a4 = fread(original_fid, 1, 'int16');
    a5 = fread(original_fid, 1, 'int16');
    % Usually packets are 104bytes long and need a 84 byte padding  
    % In case there is some other packet size, padding is calculated as:
    padding =  fread(original_fid, (packsize-20)/2, 'int16');
    
    
        %%%%%%%%%%%%%write packet
        fseek(new_fid, 0, 'eof');
        %timestamp
        fwrite(new_fid, ts, 'ulong');
        %identifier 0  = dio, 1-255 = spike ( electrode number )
        fwrite(new_fid,0,'uint16');
        %reason for packet insertion
        fwrite(new_fid,r,'uchar');
        %byte reserved as zero
        fwrite(new_fid,z,'uchar');
        %2byte word = dio
        fwrite(new_fid,dio,'uint16');
        %5 short ints for analog values
        fwrite(new_fid,a1,'int16');
        fwrite(new_fid,a2,'int16');
        fwrite(new_fid,a3,'int16');
        fwrite(new_fid,a4,'int16');
        fwrite(new_fid,a5,'int16');
        fwrite(new_fid,padding,'int16');
        %%%%%%%%%%%%%
        
%         %write packet
%         fseek(new_fid, 0, 'eof');
%         %timestamp
%         fwrite(new_fid, packet.timeStamp, 'ulong');
%         %identifier 0  = dio, 1-255 = spike ( electrode number )
%         fwrite(new_fid,0,'uint16');
%         %reason for packet insertion
%         fwrite(fid,'2','uchar');
%         %byte reserved as zero
%         %2byte word = dio
%         %5 short ints for analog values

%         %read packet
%         fseek(original_fid, 1+doff+(packsize*(p-1)), 'bof');
%         evbin = fread(original_fid,packsize,'char');
%         %write packet
%         fseek(new_fid, 0, 'eof');
%         fwrite(new_fid, evbin, 'char');
        


end

%toc

close(H);
closeNEV(nev);
fclose(new_fid);

