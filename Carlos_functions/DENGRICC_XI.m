function [ cent_reg, outline, mean_waves, mw_sd, cr_wnum,  pc_means, sortmat_us, sortmat] = DENGRICC_XI(vecmat,waves,grid,lmaxrange,minden,show)
%[ cent_reg, outline, mean_waves, cr_wnum, pc_means, sortmat_us, sortmat] = DGCTemp_5(vecmat,waves,grid,lmaxrange,minden,show)
%
%
%  Carlos Vargas-Irwin, Donoghue Lab   Last updated 9/30/05

%lmaxrange

[dim numvec] = size(vecmat);


% OUTLIER ELIMINATION

% adjust the minimum allowed value for PC1 such that 99.95% of the data
% is included (by starting at mean and continuously substracting (1/2 sdev))

ne1 = noextremes(vecmat(1,:),99.5);
ne2 = noextremes(vecmat(2,:),99.5);
mn1_rs = min( ne1 );
mx1_rs = max( ne1 );
mn2_rs = min( ne2 );
mx2_rs = max( ne2 );
clear ne1, ne2;


% Increment 1 and 2 will be set the dimensions of grid squares for the
% first and second PC's
inc1_rs = (mx1_rs-mn1_rs) / grid;
inc2_rs = (mx2_rs-mn2_rs) / grid;


sortmat_us = zeros(grid+1,grid+1);
% Create the density matrix on the given scale grid
for v = 1:numvec
    
    y = round( abs(vecmat(1,v)-(mn1_rs) ) / inc1_rs) +1;
    x = round( abs(vecmat(2,v)-(mn2_rs) ) / inc2_rs) +1;

    if( (x>0) && (x<=grid+1) && (y>0) && (y<=grid+1))
        sortmat_us(x,y) =     sortmat_us(x,y) +1;
    end
    %end
end

if ~(mod(lmaxrange,2)) % if lmaxrange is even
lmaxrange = lmaxrange+1;
end
%smooth sortmat
sortmat = smoothn(sortmat_us, [lmaxrange lmaxrange], 'gaussian', min(inc1_rs,inc2_rs)*lmaxrange );


minlevel = 80;

% extract the density countours for the surface matrix
% the isodensity contours are calculated starting at 
% 'minlevel' percent of the maximum density and at 5%
% intervals until the max is reached
mval = max(max(sortmat));

[lmaxpos, lmaxval] = localmaxseek(sortmat,lmaxrange);

disp(['Analyzing ' int2str(length(lmaxval)) ' local maxima in the density matrix...']); 


mean_waves = [];
mw_sd = [];
cr_wnum = [];
pc_means = [];


cent_reg = {};
outline = {};
cr_maxval = [];

md = max( 2, (max(lmaxval)/100)*minden );

for i = 1:length(lmaxval)  
    % the minden parameter is used to determine the smallest peak size to
    % be analizyed. It is specified as a percentage of the maximum peak.
    if(lmaxval(i) > md )
           
%         lmaxval(i)
%         lmaxpos(i,:)
        
        % clines holds the values the isodensity lines will be draw at 
        clines =  (lmaxval(i)/100)*minlevel:(lmaxval(i)/100)*2:lmaxval(i)-((lmaxval(i)/100)*2);
        pos = lmaxpos(i,:);
        pos(1,1) = ( (pos(1,1)-1) * inc2_rs ) + mn2_rs;
        pos(1,2) = ( (pos(1,2)-1) * inc1_rs ) + mn1_rs;
        
        
        c = contourc(sortmat,clines);
        % get the countour polygon vertices from contour matrix
		vexg = cM2V(c);
		vex = cell(size(vexg));
        for nh = 1:length(vexg)
            %adjust coords to PC space
            vex{nh}(:,1) = ( (vexg{nh}(:,1)-1) *inc1_rs ) + mn1_rs;
            vex{nh}(:,2) = ( (vexg{nh}(:,2)-1) *inc2_rs ) + mn2_rs;
		end
        
        % sort the polygons by size
        clear areas;
        for p = 1:length(vex)
            areas(p)=  polyarea(vex{p}(:,1), vex{p}(:,2));  
        end          
        [a sareas] = sort(areas);      
        clear svex;
        for p = 1:length(vex)
            svex{p} =  vex{sareas(p)};
        end
        clear vex;
        
        % get rid of very small polygons (remeber they are ordered by size!)
        % (those that have an area smaller than 9 grid squares
        smallest = (inc1_rs*inc2_rs)*9;
        remove = 0;
        for p = 1:length(svex)           
            if(a(p)<smallest)
                remove = p;
            end            
        end
        svex = { svex{remove+1:length(svex)} };

        % Check if polys contain any previously identified central regions
        contains_cr = zeros(length(svex),length(cent_reg));
        if(~isempty(cent_reg))
            for r = 1:length(svex)
                for c = 1:length(cent_reg)
                    in = inpolygon(  cent_reg{c}(:,1), cent_reg{c}(:,2), svex{r}(:,1), svex{r}(:,2)  );     
                    if (min(in)>0) %svex r contains cen_reg c
                        contains_cr(r,c) = 1; 
                    end
                end
            end
        end

        
        % Check if polys contain each other
        contains = zeros(length(svex),length(svex));
        for r = 1:length(svex)
            for c = 1:length(svex)
                in = inpolygon(  svex{c}(:,1), svex{c}(:,2), svex{r}(:,1), svex{r}(:,2)  );     
                if (min(in)>0 & r~=c)
                    contains(r,c) = 1; 
                end
            end
        end
        
        % find polys that do not contain any other polys and do contain the
        % local max being examined (Central Regions)
        cr = [];
        for r = 1:length(svex)
            if (sum(contains(r,:)) == 0) & (sum(contains_cr(r,:)) == 0) & (inpolygon(pos(1,2),pos(1,1),svex{r}(:,1),svex{r}(:,2)))
                cr = [cr r];
            end    
        end
        
       cent_reg = [cent_reg svex(cr)];
        
       
     % Find outlines for each central region
       
        if~(isempty(cr))

            cr_maxval = [cr_maxval lmaxval(i)];
               

            for c = 1:length(cr)
                new_outline{c} = [];
            end
            
            done = 0;
            while done == 0;
                %for iter = 1:20
                done = 1;
                for r = 1:length(svex)
                    if( sum(contains(r,:)) == 1 )
                        c = find(contains(r,:));     
                        if ~isempty(find(cr == c)) & (inpolygon(pos(1,2),pos(1,1),svex{r}(:,1),svex{r}(:,2)))
                            new_outline{find(cr == c)} = [svex{r}];
                            done = 0; 
                        end
                        %erase the outline from the contains matrix
                        contains(:,r) = zeros(length(svex),1);
                        contains(r,c) = 0;    
                    end
                end
            end    

            outline = [ outline new_outline ]     ;  
            
        end
    
        
%         %%%%%% debugging plots
%         if (length(cr>1))
%             figure(i+50)
%             plot(vecmat(1,:),vecmat(2,:),'k.')
%             for crp = 1:length(cent_reg)
%                 hold on; 
%                 h = plot(cent_reg{crp}(:,1),cent_reg{crp}(:,2),'r');
%                 set(h, 'LineWidth', 2);
%             end
%             axis([mn1_rs, mx1_rs, mn2_rs, mx2_rs] )
%         end
%         %%%%%%
        
        
    end
end


% If no outline was found, use Central Region
for c = 1:length(outline)
    if isempty(outline{c})
        outline{c} = cent_reg{c};
    end
end




%%%%%%%%% Calculate mean waves and PC centroids of central regions
[points, numwaves] = size(waves);
mean_waves = zeros(points,length(cent_reg));
pc_means = zeros(2,length(cent_reg));
cr_wnum = zeros(1,length(cent_reg));
for cr = 1:length(cent_reg)
    
    in_mat = inpolygon( vecmat(1,:)',vecmat(2,:)', cent_reg{cr}(:,1), cent_reg{cr}(:,2)  );
    in = find(in_mat>0);
    cr_wnum(cr) = length(in);
    
    pc_means(:,cr) = mean(vecmat(:,in)')';
    mw = mean(waves(:,in)')';
    %%%%%%%%%%%%%%%%%%%%%%%% !!!!!!!!!!!!!
    amp = max(mw) - min(mw);
    mw_sd(1:points,cr) = (std(waves(:,in)')');
    %%%%%%%%%%%%%%%%%%%% !!!!!!!!!!!!!
    mean_waves(:,cr) = mw;   
   
end



if(~isempty(cent_reg))
    %sort by waveform amplitude
    for t = 1:length(cent_reg)
        amp_temp(t) =  max( mean_waves(:,t) ) - min( mean_waves(:,t) );      
    end
    [y sindex] = sort(amp_temp);
    cent_reg2 = cent_reg;
    mean_waves2 = mean_waves;
    pc_means2 = pc_means;
    mw_sd2 = mw_sd;
    cr_wnum2 = cr_wnum;
    outline2 = outline;
    for t = 1:length(cent_reg)
        cent_reg{t} = cent_reg2{sindex(end-t+1)};
        outline{t} = outline2{sindex(end-t+1)}; 
        mean_waves(:,t) =  mean_waves2(:,sindex(end-t+1));
        pc_means(:,t) = pc_means2(:,sindex(end-t+1));
        cr_wnum(t) = cr_wnum2(sindex(end-t+1));
        mw_sd(t) = mw_sd(sindex(end-t+1));
    end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if(show)  % display Results
    
    figure(20)
    plot(vecmat(1,:),vecmat(2,:),'k.')
    for crp = 1:length(cent_reg)
        hold on; 
        h = plot(cent_reg{crp}(:,1),cent_reg{crp}(:,2),'r');
        set(h, 'LineWidth', 2);
    end
    
    
    h = plot([mn1_rs mn1_rs mx1_rs mx1_rs mn1_rs],[mn2_rs mx2_rs mx2_rs mn2_rs mn2_rs],'g*-');
    set(h, 'LineWidth', 2);
    
    figure(21)
    plot(vecmat(1,:),vecmat(2,:),'k.')
%     for ol = 1:length(outline)
%         hold on; 
%         if ~isempty(outline{ol})
%             h = plot(outline{ol}(:,1),outline{ol}(:,2),'b');
%             set(h, 'LineWidth', 2);
%         end
%     end  
    for crp = 1:length(cent_reg)
        hold on; 
        h = plot(cent_reg{crp}(:,1),cent_reg{crp}(:,2),'w');
        set(h, 'LineWidth', 2);
    end 
    axis([mn1_rs, mx1_rs, mn2_rs, mx2_rs] )
    
%     figure(30)
%     surf(sortmat_us)
%     axis([0 grid 0 grid 0 max(max(sortmat_us))+10 ] )
%     view(2)
    
    figure(40)
    surf(sortmat)
    axis([0 grid 0 grid 0 max(max(sortmat))+10 ] )
    view(2)
    

end

% 
% ax = [1 48 -60 60]
% for w = 1:length(cent_reg)
% figure
% h = plot(mean_waves(:,w),'k');
% set(h, 'linewidth', 2);
% hold on;
% h = plot(mean_waves(:,w)+(4*mw_sd(:,w)),'k:');
% set(h, 'linewidth', 2);
% h = plot(mean_waves(:,w)-(4*mw_sd(:,w)),'k:');
% set(h, 'linewidth', 2);
% axis(ax)
% end

end

function [vx] = cM2V(C)
	n_c = 1;
	k_c(1) = 1;

	while k_c(n_c) < size(C, 2)
		n_c = n_c + 1;
		k_c(n_c) = k_c(n_c - 1) + C(2, k_c(n_c - 1)) + 1;
	end
	vx = cell(n_c - 1, 1);
	for i_c = 1:(n_c - 1)
		vx{i_c} = [C(1, (k_c(i_c) + 1) : (k_c(i_c + 1) - 1) )',...
			C(2, (k_c(i_c) + 1) : (k_c(i_c + 1) - 1) )'];
	end
end





