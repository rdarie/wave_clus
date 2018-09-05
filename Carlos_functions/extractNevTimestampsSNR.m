% Convenient interface for AutoSorter to getNevTimestampsSNR
% @version $Id$
% @author Jonas Zimmermann
function save_file_names = extractNevTimestampsSNR(varargin)

[~, ~, ~, ~, ~, ~, save_file_name]	= getNevTimestampsSNR(varargin{:});
save_file_names = {save_file_name};
end
