function iq = iq_subtract(iq1, iq2, varargin)
% --- Usage:
%        iq = iq_subtract(iq1, iq2, varargin)
%
% --- Purpose:
%
% --- Parameter(s):
%        varargin   - 'match_range'
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: xydata_sub.m,v 1.1 2013/04/03 16:04:53 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

match_range = [];
scale = 1;
parse_varargin(varargin);

iq = iq1;

% interpolate data
iq(:,2) = interp1(iq2(:,1), iq2(:,2), iq1(:,1));

% match if needed
if ~isempty(match_range)
   iq = match(iq, iq1, match_range, varargin{:});
end
if (scale ~= 1)
   iq(:,2) = iq(:,2)*scale;
end

iq(:,2) = iq1(:,2) - iq(:,2);

% do proper error progation later
% [num_rows, num_cols] = size(iq1);
