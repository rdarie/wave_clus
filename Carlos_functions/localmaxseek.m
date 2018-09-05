
function [lmaxpos, lmaxval] = localmaxseek(sortmat,range)
% [lmaxmat, lmaxval] = localmaxseek(sortmat,range)
% Given a 3d surface grid, this function returns the local maxima & their values. 
% A spot on the grid is considered a loc. max. if the places within distance range
% are all smaller

[row col] = size(sortmat);
lmaxmat = zeros(row,col);

lmaxval = [];
lmaxpos = [];

index = 1;

for r = 1:row
    for c = 1:col
        
        
        if(sortmat(r,c)> 1)
            
            
            lmax = 1;
            
            
            
            for p = -range:1:range
                for q = -range:1:range
                    if(r+p>0 & r+p<=row & r~=0 & c+q>0 & c+q<=row & c~=0)
                        if sortmat(r,c) < sortmat(r+p,c+q)
                            lmax = 0;    
                        end
                    end
                end
            end
            
            
            
            if(lmax)
                lmaxmat(r,c) = 1;
                lmaxpos(index,1:2) = [r c];
                lmaxval(index) = sortmat(r,c);
                index = index+1;
            end
            
            
            
        end
    end
    
end

% sort results
[v ix] = sort(lmaxval);

lmaxval_s = lmaxval;
for i = 1:length(lmaxval)
lmaxval_s(i) = lmaxval(ix( length(lmaxval)-i+1 ));
end

lmaxpos_s = lmaxpos;
for i = 1:length(lmaxval)
lmaxpos_s(i,:) = lmaxpos(ix( length(lmaxval)-i+1 ),:);
end

lmaxval = lmaxval_s;
lmaxpos = lmaxpos_s;