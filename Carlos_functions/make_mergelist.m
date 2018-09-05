function [ml]= make_mergelist(contains)
%% subfunction of threshClust

%contains

[row col] = size(contains);  
ml{1} = [];

if (sum(sum(contains)) == 0)

    for n = 1:row
    ml{n} = [n]; 
    end
    
else
    
    count = 0;
    for c = 1:col
        
        sr = sum(contains(:,c));    
        if(sr == 0)
            
            overlap = 0;
            %% check all previously merged clusters
            for iml = 1:count
                %% get the components of each
                prevmerge = ml{iml};
                for ipm = 1:length(prevmerge)
                    %for each component, check if it overlaps with the new mergelist    
                    if(prevmerge(ipm)==c)
                        overlap = iml;    
                    end
                end
            end
            
            if(~overlap)
                count = count+1;
                ml{count} = c;
            end
        else
            
            %% indeces to merge
            mergeix = [find(contains(:,c)>0); c];
            
            overlap = [];
            %% check all previously merged clusters
            for iml = 1:count
                %% get the components of each
                prevmerge = ml{iml};
                for ipm = 1:length(prevmerge)
                    %for each component, check if it overlaps with the new mergelist    
                    for nmix = 1:length(mergeix)
                        if(prevmerge(ipm)==mergeix(nmix)) & isempty(find(overlap==iml))
                            overlap = [overlap iml];    
                        end
                    end
                end
            end
            
           %overlap
            
            if isempty(overlap)
                count = count+1;
                ml{count} = mergeix;
            else 
                if length(overlap)==1
                  ml{overlap} = [ml{overlap}; mergeix];
                end
                %%%%%%%%%%%%
                if length(overlap)>1
                  count = count+1;
                  ml{count} = [mergeix];
                  for o = 1:length(overlap) 
                    ml{count} = [ ml{count}; ml{overlap(o)}];
                  end
                  
                  newlist = [];
                  for nls = 1:length(ml)
                    if isempty(find(overlap == nls))
                       newlist = [newlist nls] ;
                    end
                  end
                  ml = ml(newlist);
                  count = length(newlist);
                end    
                %%%%%%%%%%%
            end
            
            
        end
        
    end
    
    
    %% remove duplicates
    for iml = 1:count
        merged = ml{iml};
        merged = sort(merged);
        rmd = merged(1);
        for i = 2:length(merged)
            if(merged(i)>rmd(length(rmd)))
                rmd = [rmd merged(i)];
            end
        end
        ml{iml} = rmd;
    end
    
    
    
end