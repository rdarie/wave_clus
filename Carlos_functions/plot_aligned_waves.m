

function [ al_wmat ] = plot_aligned_waves(wr, wmat, noise_amp, axset, colorstr, ax_h)
if (~exist('ax_h', 'var')  || ~ishandle(ax_h) || ~strcmp(get(ax_h,'type'),'axes'))
	ax_h = gca;
end
%function [ al_wmat ] = plot_aligned_waves(ref_wave, wmat, axset, colorstr)
%
% if max(wr) > (-1*min(wr))
%     %find global max
%     [vr mir] = max(wr)
% else
%     %find global min
%     [vr mir] = min(wr)
% end
 [~, mir] = min(wr);

[r, c] = size(wmat);

al_wmat = zeros(r,c);

%hold(ax_h, 'on')


for n = 1:c

    [v, mi] = min(wmat(:,n));
    wav = wmat(:,n);

    if(mi>mir)
        al_wmat(:,n) = [ wav( 1+(mi-mir):r) ; wr(r-(mi-mir)+1:r)];
        %         h = plot(wav(mi-mir:r), 'b');
        %             set(h, 'LineWidth', 3);
        %         h = plot(wmat(:,n),'g');
        %             set(h, 'LineWidth', 4);

    end

    if(mi<mir)
        al_wmat(:,n) = [wr(1:(mir-mi)); wav(1:r-(mir-mi)) ];
        %       h = plot( [zeros((mir-mi),1); wav(1:r-(mir-mi)) ]   );
        %         x = [mir-mi+1:r]';
        %         y = wav(1:r-(mir-mi));
        %         h = plot(x,y, 'b');
        %         set(h, 'LineWidth', 3);
        %         h = plot(wmat(:,n),'m');
        %         set(h, 'LineWidth', 4);

    end

    if(mi==mir)
        %             h = plot(wmat(:,n),'b');
        %             set(h, 'LineWidth', 4);
        al_wmat(:,n) = wmat(:,n);
    end

end

%hold off;



%     h = plot(max(al_wmat'),[colorstr ':']);
%     set(h, 'LineWidth', 1.5);
%     hold on;
%     h = plot(min(al_wmat'),[colorstr ':']);
%     set(h, 'LineWidth', 1.5);


wr = mean(al_wmat, 2);


%sdeval = std(al_wmat')';

%find envelope that includes 95 % of waveform values
range_pos = zeros(r,1);
range_neg = zeros(r,1);
for n = 1:r
    ne = noextremes( al_wmat(n,:),95);
    range_pos(n,1) = max(ne);
    range_neg(n,1) = min(ne);
end

xax = (1/30):(1/30):1.6;

h = plot(xax, (range_pos),[colorstr '--'], 'parent', ax_h);
set(h, 'LineWidth', 1);
hold(ax_h, 'on');
h = plot(xax, (range_neg),[colorstr '--'], 'parent', ax_h);
set(h, 'LineWidth', 1);

h = plot(xax, wr,colorstr, 'parent', ax_h);
set(h, 'LineWidth', 2);

% display signal to noise ratio
% noise_amp = mean(range_pos(1:5)) - mean(range_neg(1:5));
sig_amp = max(wr) - min(wr);
snr = sig_amp / noise_amp;

title(['snr = ' num2str(round(sig_amp)) ' / ' num2str(round(noise_amp)) ' = ' num2str(snr) ], 'parent', ax_h) ;
%xlabel('1.6ms at 30KHz')
ylabel('µV', 'parent', ax_h);
xlabel('ms', 'parent', ax_h);

axis(ax_h, axset);

hold(ax_h, 'off');





%%%%  EXAMPLE
%     s = sin(0:.1:(2*pi))'+0.5
%     s2 = sin([0:.1:(2*pi)]+10)'
%     s3 = sin([0:.1:(2*pi)]-10)'-0.5
%     sm = [s s2 s3]
%     plot_aligned_waves(s2,sm,'r')



