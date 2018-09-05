function [sortmat_us] = densityMatrix(X,Y,grid,mnx,mxx,mny,mxy)





% Increment 1 and 2 will be set the dimensions of grid squares for the
% first and second PC's
inc1_rs = (mxx-mnx) / grid;
inc2_rs = (mxy-mny) / grid;


sortmat_us = zeros(grid+1,grid+1);
% Create the density matrix on the given scale grid
for v = 1:length(X)
    
    y = round( abs(X(v)-(mnx) ) / inc1_rs) +1;
    x = round( abs(Y(v)-(mny) ) / inc2_rs) +1;

    if( (x>0) && (x<=grid+1) && (y>0) && (y<=grid+1))
        sortmat_us(x,y) =     sortmat_us(x,y) +1;
    end
    %end
end


