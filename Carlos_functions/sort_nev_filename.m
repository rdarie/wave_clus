
% Want to know how this works? Check out DS_sort_parameters.m

%%%%%%%%%% code follows, no need to read further! Unless you love code.


%load sort parameters
DS_sort_parameters

filename = strcat(pathname, fname);
% Change to the selected directory
cd(pathname);

% Call main sorting script
DS_sort;

