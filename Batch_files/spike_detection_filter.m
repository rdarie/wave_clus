function xf_detect = spike_detection_filter(x, par)
%this function filter the signal, using the detection filter. Is used in the
%readInData class. 

sr = par.sr;
fmin_detect = par.detect_fmin;
fmax_detect = par.detect_fmax;
f_notch = par.notch_f;
wid_notch = par.notch_wid;


% HIGH-PASS FILTER OF THE DATA
if exist('ellip','file')                         %Checks for the signal processing toolbox
    [b,a] = ellip(par.detect_order,0.1,40,[fmin_detect fmax_detect]*2/sr);
    [b_notch,a_notch] = butter(par.notch_order,[f_notch-wid_notch f_notch+wid_notch]*2/sr, 'stop');
    [b_pass,a_pass] = butter(par.notch_order,[f_notch-wid_notch f_notch+wid_notch]*2/sr, 'bandpass');
%     [b_notch2,a_notch2] = butter(par.notch_order,[2*(f_notch-wid_notch) 2*(f_notch+wid_notch)]*2/sr, 'stop');
%     [b_notch3,a_notch3] = butter(par.notch_order,[3*(f_notch-wid_notch) 3*(f_notch+wid_notch)]*2/sr, 'stop');
%     [b_notch4,a_notch4] = butter(par.notch_order,[4*(f_notch-wid_notch) 4*(f_notch+wid_notch)]*2/sr, 'stop');
%     [b_notch5,a_notch5] = butter(par.notch_order,[5*(f_notch-wid_notch) 5*(f_notch+wid_notch)]*2/sr, 'stop');
    if exist('FiltFiltM','file')
        xf_detect = FiltFiltM(b_notch, a_notch, x);
%         xf_detect = FiltFiltM(b_notch2, a_notch2, xf_detect);
%         xf_detect = FiltFiltM(b_notch3, a_notch3, xf_detect);
%         xf_detect = FiltFiltM(b_notch4, a_notch4, xf_detect);
%         xf_detect = FiltFiltM(b_notch5, a_notch5, xf_detect);
        xf_detect = FiltFiltM(b, a, xf_detect);
    else
        xf_detect = filtfilt(b_notch, a_notch, x);
%         xf_detect = filtfilt(b_notch2, a_notch2, xf_detect);
%         xf_detect = filtfilt(b_notch3, a_notch3, xf_detect);
%         xf_detect = filtfilt(b_notch4, a_notch4, xf_detect);
%         xf_detect = filtfilt(b_notch5, a_notch5, xf_detect);
        xf_detect = filtfilt(b, a, xf_detect);
    end
else
    xf_detect = fix_filter(x);                   %Does a bandpass filtering between [300 3000] without the toolbox.
end
