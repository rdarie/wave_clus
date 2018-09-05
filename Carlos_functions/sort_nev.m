

% Want to know how this works? Check out DS_sort_parameters.m

%%%%%%%%%% code follows, no need to read further! Unless you love code.

close all
%clear all
pack

%load sort parameters
DS_sort_parameters


%% Let the user select a NEV file
[fname, pathname] = uigetfile('*.nev', ':::: Select a NEV file to sort...');
filename = strcat(pathname, fname);
% Change to the selected directory
cd(pathname);

% Call main sorting script
DS_sort;



