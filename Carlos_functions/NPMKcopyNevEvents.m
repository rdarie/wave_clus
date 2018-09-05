  
function [] = NPMKcopyNevEvents(original_filename, new_file);

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


NEV = openNEV(original_filename)

ets = NEV.Data.SerialDigitalIO.TimeStamp;
eid = NEV.Data.SerialDigitalIO.UnparsedData;
er = NEV.Data.SerialDigitalIO.InsertionReason;


%find events
H = waitbar(0, 'Copying Event Packets...');

%tic

%new_fid = fopen(new_file,'w','l');
new_fid = fopen(new_file,'a');
        

disp( ['::: Copying ' int2str(length(ets)) ' Event packets...'])
for p = 1:length(ets)
    % update UI
    if mod(p, 1000) == 0
        waitbar(p / length(ets));
    end;
    %

    
        %%%%%%%%%%%%%write packet
        fseek(new_fid, 0, 'eof');
        %timestamp
        fwrite(new_fid, ets(p), 'ulong');
        %identifier 0  = dio, 1-255 = spike ( electrode number )
        fwrite(new_fid,0,'uint16');
        %reason for packet insertion
        fwrite(new_fid,er(p),'uint8');
        %byte reserved as zero
        fwrite(new_fid,0,'uchar');
        %2byte word = dio
        fwrite(new_fid,eid(p),'uint16');
        %5 short ints for analog values
        fwrite(new_fid,0,'int16');
        fwrite(new_fid,0,'int16');
        fwrite(new_fid,0,'int16');
        fwrite(new_fid,0,'int16');
        fwrite(new_fid,0,'int16');
        %buffer to complete packet length
        fwrite(new_fid,zeros(1,NEV.MetaTags.PacketBytes-20),'int8');
                


end

%toc

close(H);
fclose(new_fid);

