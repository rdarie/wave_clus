function [m, ix] = noextremes(x,percent)
% NOEXTREMES	Remove the extremes in x, keeping 'percent' of the original data points.
%	
%	Inputs:
%			x			data vector (row or column)
%			percent		percent of datapoints to be returned from 0 to 100
%
%	Outputs:
%			m			data vector x shortened to include only
%							the least extreme points. length
%							is round(percent*length(x))
%
%           ix         index of points returned (in original vector)
%  
%
%   J.D. Simeral
%   Modified by cvi ---> excludes points near min AND max

% ----------------------------------------------------------
% Check inputs
% ----------------------------------------------------------
if percent >= 100 || percent < 0
    error('Percent must take values between 0 and 100.');
end

[r, c] = size(x);
if r > 1 && c > 1
    error('Input must be a row or column vector, not matrix.');
end;

% ----------------------------------------------------------
% Remove extremes from the input vector
% ----------------------------------------------------------
NumOriginalPoints = length(x);
NumPointsToEliminate = round(length(x)*(100-percent)./100);

%[Y,I] = sort(abs(x));	% sorts smallest to largest
% I_index_to_eliminate = NumOriginalPoints-NumPointsToEliminate+1 : NumOriginalPoints;
% I_to_eliminate = I(I_index_to_eliminate);
% m = x;
% m(I_to_eliminate) = [];

%%cvi
[Y,I] = sort(x);
npe2 = round(NumPointsToEliminate/2);
m = Y(max(1,npe2):NumOriginalPoints-npe2);
ix = (I(max(1,npe2):NumOriginalPoints-npe2));
%%cvi

% END



