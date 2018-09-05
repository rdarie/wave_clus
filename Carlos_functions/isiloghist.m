function  [counts] = isiloghist(tstamps, nbins, colstr, ax_h)
if (~exist('ax_h', 'var') || ~ishandle(ax_h) || ~strcmp(get(ax_h,'type'),'axes'))
	ax_h = gca;
end
% function  [counts] = loghist(tstamps, nbins, colstr)
%
% This function will take a series of timestamps,
% calculate the intervals between them and
% draw a histogram with a logarithmic scale
% such that the bars to the left are wider.
%
%     INPUT:
%     tstamps = the timestamps (in ms)
%     nbins = number of bins
%     colstr = color string (simiar to plot function)
%
%      OUTPUT:
%      counts = the number of counts in each bin
%

% in PLX, files timestamps are in seconds
%tstamps = tstamps / 1000;
% in NEV timestamps are in 1/30ms   (30,000 samples / sec)  (48 samples = 1.6ms)
tstamps = (tstamps/30); % switch to msec

isi = diff(tstamps);

%min(isi)

counts = histc(isi, 0:1:nbins);
counts = 100* (counts / length(tstamps));
%semilogx([nbins 0], 'w.')
bar( 1:nbins+1, counts, 1, colstr, 'EdgeColor','none', 'parent', ax_h);
set(ax_h, 'XScale', 'log');
axis(ax_h, [1 nbins 0 max(counts)+1] );
tks=[2:2:9 logspace(1,ceil(log10(nbins)),ceil(log10(nbins)))];
set(ax_h,'xtick',tks);
title(['ISI distribution (' int2str(length(tstamps)) ' waves)'], 'parent', ax_h);
xlabel('ms', 'parent', ax_h);
ylabel(['%' ], 'parent', ax_h);






