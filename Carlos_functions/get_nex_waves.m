function [waves, wavenames, mean_waves, mn_waves, mx_waves, filename] = get_nex_waves(display)
%
% ----  function [mean_waves, mn_waves, mx_waves, waves ] = get_nex_waves(display) ------
% 
%   This function retrieves waveform data from NEX files, and automatically generates 
%   graphics to display it. The nex file must  contain the waves (in variables like sig001_wf ). 
%   The easiest way to accomplish this is to:
%   
%   (1) Sort the PLX file and SAVE it (OfflineSorter will only allow you to do this if you save the file with a new name).
%   (2) Open the SORTED PLX file with NEX. 
%   (3) SAVE the file you just opened as a NEX file. Now this function will be able to access all the data.
%   
%   NOTE: Do NOT use the 'save as nex' option in offline sorter. This will only save timestamps and events, but no waveforms!
%   
%   
%   INPUTS:
%               display --> Set to ONE to generate graphs automatically.
%                           Use ZERO to skip.
%   
%   OUTPUTS:
%   
%               waves: the waves extracted from the nex file (one per column)
%               
%               wavenames: a list of strings containing the channel and unit for each signal
%    
%               mean_waves: the mean wave for each unit (one per column)
%  
%               mn_waves: the upper range of the wf's for each unit (one per column)
%               
%               mx_waves: the lower range of the wf's for each unit  (one per column)
%   
%               filename: The full name of the nex file (including the path)
% 
%   SEE ALSO: nex_wf, nex_ts, nex_info
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   Last revision: Carlos Vargas, June 12 2003  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              

[fname, pathname] = uigetfile('*.nex', 'Select a Nex file');
filename = strcat(pathname, fname);

fid = fopen(filename, 'r');
if(fid == -1)
    disp('cannot open file');
    return
end


disp(strcat('file = ', filename));
magic = fread(fid, 1, 'int32');
version = fread(fid, 1, 'int32');
comment = fread(fid, 256, 'char');
freq = fread(fid, 1, 'double');
tbeg = fread(fid, 1, 'int32');
tend = fread(fid, 1, 'int32');
nvar = fread(fid, 1, 'int32');
fseek(fid, 260, 'cof');
name = zeros(1, 64);

position = ftell(fid);
numcells = 0;
for i=1:nvar
    
    fseek(fid,position,'bof');
    
    type = fread(fid, 1, 'int32');
    var_version = fread(fid, 1, 'int32');
    varname = fread(fid, [1 64], 'char');
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
    
    dummy = fread(fid, 68, 'char');
    position = ftell(fid);
    
    varname = setstr(varname);
    varname = deblank(varname);
    
    if(varname(1:3)=='sig') & (length(varname)==10)
        
        
        numcells = numcells+1;
        fseek(fid, offset, 'bof');
        ts = fread(fid, [1 n], 'int32');
        waves{numcells} = fread(fid, [points n], 'int16');
        waves{numcells} = waves{numcells}*ADtoMV;
        
        mean_waves(:,numcells) = mean(waves{numcells}')';
        mx_waves(:,numcells) = min(waves{numcells}')';
        mn_waves(:,numcells) = max(waves{numcells}')';
        
        wavenames{numcells} = varname;
        
    end
    
    

    
end


fclose(fid);


if(display)
    
    start = 0;
    nc = 0;
    for n = 1:ceil(length(waves)/12);
        
        figure(n)  
        for w = 1:12
            
            
            
            
            if(nc<length(waves))
                subplot(4,3,w)
                hold on;
                [pt nw] = size(waves{start+w});
                for i = 1:round(nw/20):nw
                    plot([0:(1.5/(pt-1)):1.5], waves{start+w}(:,i));    
                end
                h = plot([0:(1.5/(pt-1)):1.5], mean_waves(:,start+w),'r'); set(h, 'LineWidth', 2);
                h = plot([0:(1.5/(pt-1)):1.5], mx_waves(:,start+w),'g--'); set(h, 'LineWidth', 2);
                h = plot([0:(1.5/(pt-1)):1.5], mn_waves(:,start+w),'g--'); set(h, 'LineWidth', 2);
                
                title(wavenames{start+w});
                
                
                if( (w == 1) | (w == 4) | (w == 7) | (w == 10) )
                    ylabel('mv')
                end
                if(w >9) 
                    xlabel('ms') 
                end
                w = w+1;
                
                
                nc = nc+1;
            end
        end  
        orient tall;
        start = start+12;   
        
    end
    
    
end % display







