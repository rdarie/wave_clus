

%function [ctalklist, synchcount, ctalk, timestamps, waves] = Check_Crosstalk(e_list, threshold, nw)
%%% EXAMPLE
% e_list = [1:96]
% threshold = 20
% numwaves = 500 
% [ctalklist, synchcount, ctalkmat, timestamps, waves] = Check_Crosstalk(e_list,threshold, numwaves);
%
%%% This code will analyze the first 500 timestamps for channels 1-->96.
%%% The nev file to be analyzed is selected by the user while the function runs.
%%% Channels where more than the specified % of spikes are synchronous with another channel
%%% will be grouped together  in Ctalklist. The synchcount matrix shows the percentage of 
%%% synchronous spikes between all pairs of channels. The ctalkmat matrix is set up like synchcount, 
%%% but shows only the channels above threshold. Each row represents a channeln in the same order
%%% listed in e_list, and each column the number of synchronous spikes with another channel.



%% Let the user select a NEV file
[fname, pathname] = uigetfile('*sorted_data.mat', ':::: Select a DSXI file to analyze...');
filename = strcat(pathname, fname);

load(filename);

numts = 500
synch_window = 1 %ms
win = synch_window / 2000; %center window, convert to ms

synchcount = zeros(length(unit_index),length(unit_index));

for c = 1:length(unit_index)
   
%hb = waitbar(0,[ ' processing unit ' int2str(unit_index(1,c)) '-' int2str(unit_index(2,c)) '...']);

    for t = 1:numts
       
       % waitbar(t/numts);
        
        ts = sorted_timestamps {c}(t);
        
        for c2 = 1:length(unit_index)

            f = find( (sorted_timestamps{c2} <= ts+win) & (sorted_timestamps{c2} >= ts-win) );
            if(~isempty(f)) & (c~=c2) & min(f)<numts                 % normalize to % timestamps
                synchcount(c,c2) = synchcount(c,c2) + 1; %((1/length(sorted_timestamps {c}))*100);
%                disp(['match found!  delta_t = ' num2str((sorted_timestamps{c2}(f)-ts)) ])

            end        
        end
     
    end
%close(hb)
    %    h = plot( timestamps{c}(1:nspikes), zeros(nspikes)+c, 'k+'   );
    %    set(h,'linewidth',2)
    %    hold on
    %     ax = axis    
    %     h = plot( [ax(1) ax(2)],  [t,t], 'k-'   );
    %     set(h,'linewidth',2)   
end


%surf(synchcount)

synchcount = 100*(synchcount/numts)

% %hold off
% 
% numel = length(synchcount)*length(synchcount);
% synchvec = reshape(synchcount,numel,1);
% 
% mean(synchvec)
% std(synchvec)
% 
% nbins = 80;
% counts = histc(synchvec, 0:1:nbins);
% counts = 100* (counts / numel);
% bar( 1:nbins+1, counts,1)
% 
% 
% 
% ctalk = zeros(length(e_list),length(e_list));
% for r = 1:length(e_list)
%     for c = 1:length(e_list)
%         if(synchcount(r,c) >threshold) && (r~=c)
%             ctalk(r,c) = synchcount(r,c);
%         end
%     end
% end
% 
% 
% 
% for r = 1:length(timestamps)
%     cross{r} = find(synchcount(r,:)>threshold) ;
% end
% 
% 
% dna = [];
% dnr = [];
% for x = 1:length(timestamps)    
%     group = cross{x};
%     if(length(group) == 1 )
%         %dnr = [dnr x] ;
%     else % some crosstalk detected
%         overlap = 0;
%         for g = 1:length(group)
%             if ~isempty(find(dna == group(g)) )    
%                 %this channel is already listed
%                 overlap  = overlap+1;  
%             end      
%         end
%         if overlap < length(group)
%             dna = [dna group];
%             dnr = [dnr x];
%         end    
%     end 
%     
% end
% 
% 
% 
% 
% count = 1;
% ctalklist{1} = [];
% for d = 1:length(dnr)
%     channels{d} = cross{dnr(d)};
%     if(length(channels{d})>1)
%         ctalklist{count} = channels{d};    
%         count = count +1;
%     end
% end
% 
% 
% 
% 
% % disp('=-> processing complete <-=')
% % disp(['::::::: Groups of channels displaying more than ' num2str(threshold) '% synchronous timestamps:'])
% % for c = 1:length(cross)
% %     if(length(cross{c})>1)
% %         disp(int2str(c))
% %         disp(int2str(cross{c}));
% %     end
% % end
% 
% closeNev(nev)
% disp(['=> ' fname ' processing complete <='])
% disp(['=> Groups of channels displaying more than ' num2str(threshold) '% synchronous timestamps:'])
% disp(':::::::')
% for c = 1:length(ctalklist)
%     disp(int2str(ctalklist{c}));
% end
% disp(':::::::')





