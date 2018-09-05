  
function [  ] = insertSpike(filename, ts, electrode, unit, wave)


fid = fopen(filename,'a');


%disp('fseek...')
%fseek(fid, off, 'bof')
fseek(fid, 0, 'eof');

for t = 1:length(ts)

    %timestamp
    fwrite(fid, ts(t), 'uint32');
    %fwrite(fid, ts(t), 'ulong');
    
    %identifier
    % 0  = dio
    % 1-255 = spike ( electrode number )
    fwrite(fid,electrode(t),'uint16');

    %unit classification
    fwrite(fid,unit(t),'uint8');

    %future space for extra unit info
    fwrite(fid,0,'uint8');

    %waveform
    fwrite(fid,round(wave(:,t)),'int16'); % documentation says this should be schar... but int16 seems to do the trick

end


fclose(fid);




