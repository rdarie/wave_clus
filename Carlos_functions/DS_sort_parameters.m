%%%%%   - Automatic Sorting using DENsity GRId Contour Clustering with Subtractive WAveform DEcomposition %%%%%
%
%
%  Carlos Vargas-Irwin   (Carlos_Vargas@brown.edu)
%  Donoghue Lab
%  Brown University, Providence, RI
%  2012
%
% ::: What it does :::
% * In a nutshell *
% Sort_nev will read data from a nev file. It will project waveforms
% into 2D principal component space. High density areas in this space will
% be used to extract templates representing the shape of spikes from
% different neurons. These templates are then used to classify the
% waveforms using template matching. Template shifting and overlaps are
% resolved.
%
% ::::: Running the Program
%
% For ease of handling, the algorithm runs as a script. To edit the
% parameters used, open the file named 'DS_sort_parameters.m' and look for the
% label that says 'Change Parameters Here'. Specific parameters are
% described in detail in this section. Once you have set the parameters in
% the file, simply type 'sort_nev' to run the program. You will be
% prompted for the nev file to sort.
% If you want to sort several files in a row (and don't want to stay around to prompt each)
% you can use the 'sort_batch' script. Here you can type in a series of
% filenames and pathnames for the program to go through (see sort_batch.m for
% examples).
%
%
% * The outputs *
%
% - nev file output -
% The original nev file you select will remain unchanged. The headers and
% event codes will be copied to a new nev file with the same name plus '_DSXI'.
% Waves were spike overlapping is detected will be separated and inserted
% into the new nev file with different timestamps. 'Noise' waveforms will
% also be included in the new nev file in order to check the sorting results.
% The sorted timestamps are also stored in the sorted_ts cell array in MatLab.
% The matrix 'unit_index' indicates the unit and channel for each entry.
%
% - Automatic jpeg generation -
% The program will graphically display the sorting process by
% generating jpeg files in the same directory where the nev file is located.
% You can examine these while the program runs. They show the principal
% component projection of the waves, the centers of each cluster, the
% templates (and outlines showing where 95% of the waveforms fall), noise waveforms
% (yellow), and interspike interval for each sorted unit.If you don't want them,
% set the show_progress variable in the m file to  0.
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Change parameters Here %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%these you will probably not want to change....
grid = 100  % determines how pc space is partitioned
lmaxrange = 5 % determines the range of local max in the density matrix
minden = 2  % minimum required density for template extraction regions (% of global max)
%%%%%%%%%%

% The following thresholds are used for template extraction and matching. Each has two
% numbers that are used as upper and lower limits. The algorithm will try
% to optimize a value within these limits according to an estimate of noise
% amplitude (based on the first five samples of each wave). If you want to
% fix a threshold to a specific value, just use one number.
% Estimates of fit are evaluated as the maximum deivation from zero of the
% residual waveform left after subtracting a template (or templates).


% There are three main threshold parameters:

% threshold --> Determines the maximum fit allowed to assign a waveform to a template


% overlap_threshold --> Determines when a fit estimate is 'good enough' to skip checking for spike overlaps


% template_thereshold --> Determines the minimum amplitude for templates
% ( max deviation from zero must be > this value)
%                         This value is also used to determine if two
%                         templates are similar enough to be treated as
%                         single template

% They are controlled in two ways.

% #1 They can be set automatically based on estimates of noise amplitude.
% This is done by looking at the first five
% sample points in each waveform. The coverage values below are used to set
% the each threshold so that it covers the given percentage of the these
% sample noise values.

threshold_coverage            =  99.99
overlap_threshold_coverage    =  98
template_threshold_coverage   =  80



% #2 The threshold values can also be bounded to be between the minimum and
% maximum values entered below.  If there is only one value,
% thresholds will be fixed at that value. If set to [+inf -inf], then the
% automated estimate is always left unaltered.

%%%monkey!
threshold_bounds = [30 100]
overlap_threshold_bounds = [30  100]
template_threshold_bounds =  [30 100]


% %human!
% threshold_bounds = [30 100]
% overlap_threshold_bounds = [30  100]
% template_threshold_bounds =  [15 50]


% Additionally, the amplitude variation threshold
% can be used to increase the normal threshold for each unit
% based on a percent value of its amplitude. This will make the algorithm
% tolerate greater changes in spike shape for units with large amplitude
% signals.
amplitude_variation_threshold = 15%

temp_var_lim = 4.5 % If this number times the mean standard deviation
% for the waveforms used to calculate a template
% (those within the center of a cluster) is smaller than the
% amplitude of the template, it is NOT used for clasification.

trough_peak_width_lim = 0.8 % this sets the maximum acceptable distance between
% trough and peak of valid templates (in milliseconds).
% If set to inf, anything goes.
trough_peak_width_lim = trough_peak_width_lim *30; %adjust to 30KHz sampling


% output control parameters

show_progress = 2 % this turns the automatic generation of jpegs on and off 1 --> mean waves+isis, 2 --> add amp vs. time

save_mat = 1 % Save results as a matlab mat file

save_nev = 1 % save results as a new nev file

save_events = 1 % save non-neural events in nev file

save_noise = 1 % save waveforms classified as noise in nev file

% The e_list parameter sets the list of electrodes the program will sort
% (to save time, you can include only 'good' channels, if you have this information beforehand)
% To sort all the channels, simply set it to: e_list = [1:128] or e_list = [1:96]

e_list =  [1:128] ;



%%%%%%%%

