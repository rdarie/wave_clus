function [pc, cellnames,fname,pathname] = getWavePC(varargin)
% [pc, cellnames]  = getWavePC
if(nargin==1)
    plx_filename = varargin{1};
else
    
    % prompt for plx_filename if not given 
    [fname, pathname] = uigetfile('*.nex', '--> Select NEX file...');
    filename = strcat(pathname, fname);
    
end


[nvar, names, types] = nex_info(filename);

nunits = 0;
for i = 1:nvar
    
    varname = deblank(names(i,:));
    
    vnl = length(varname);
    
    
    if ( strcmp(varname(vnl-2:vnl), '_wf') ) 
        
        
  %      disp(':::::::::EXTRACTING WAVEFORMS...........')        
        [n, ts, waves] = nex_wf(filename, varname);
        
        
   %     disp(':::::::::DECIMATING WAVEFORMS...........')
        decimation = 1;
        [points numwaves] = size(waves);
        
        if(numwaves>1000)
            
            
        nunits = nunits+1;
        
        cellnames{nunits} = varname;
        
            
            % waveforms must be saved in chunks that preserve isi's
            
            if(numwaves>5000)
                decimation = 2;
            end
            
            if(numwaves>10000)
                decimation = 3;
            end
            
            if(numwaves>15000)
                decimation = 5;
            end
            
            if(numwaves>25000)
                decimation = 6;
            end
            
            if(numwaves>30000)
                decimation = 10;
            end 
            
            if(numwaves>50000)
                decimation = 20;
            end 
            
            if(numwaves>5000)
                
                w = waves(:,1:1000) ;
                t = ts(:,1:1000);
                d = decimation;
                while ((1000*d)+1000<numwaves)
                    w  = [ w  waves(:,1000*d+1:(1000*d)+1000 ) ];  
                    t  = [ t ts(:,1000*d+1:(1000*d)+1000 ) ];
                    d = d+decimation;
                end
                waves = w ;
                ts = t;
                [points numwaves] = size(waves);
            end
            
            
            if(numwaves>5000)
                waves = waves(1:points,1:5000);
            end
            
            
      %      disp(':::::::: Calculating Principal Components..... ');
            
            
            
            
            pc{nunits} = getPC(waves);
            %eval([ ' [pc.' varname(1:6) '] = getPC(waves); '])
            
            % Save the results
            % save([fname(1:length(fname)-4) '_PC'], 'pc')
            
        end
        
        disp([':::::::: Pre-processing Channel--->  ' varname]);
        
       % numwaves          
        clear waves ts
        pack
        
        
        
    end 
end






