function uvspec = uvspec_subbaseline(uvspec, base_range)
% --- Usage:
%        uvspec = uvspec_subbaseline(uvspec, base_range)
% --- Purpose:
%        use the average in "base_range" as the baseline to be
%        subtracted from the whole curve
% --- Parameter(s):
%        
% --- Return(s):
%        
% --- Example(s):
%
% $Id: uvspec_subbaseline.m,v 1.4 2012/12/28 18:12:55 xqiu Exp $
%

% 1) check how is called
verbose = 1;

if nargin < 1
   help uvspec_subbaseline
   return
end
if ~exist('base_range')
   base_range = [310,500];
end

% 2)
if isfield(uvspec, 'samnames');
   samnames = {uvspec.samnames{:} 'data'};
else
   samnames = {'data'};
end
for i = 1:length(samnames)
   if ~isfield(uvspec, samnames{i}); continue; end
   data = uvspec.(samnames{i});
   i_min = locate(data(:,1), base_range(1));
   i_max = locate(data(:,1), base_range(2));
   uvspec.baseline = mean(data(i_min:i_max,2));
   data(:,2) = data(:,2) - mean(data(i_min:i_max,2));
   uvspec.(samnames{i}) = data;
end

return
