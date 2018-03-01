function [data, scale, offset] = match(data, refdata, x_range, varargin)
% --- Usage:
%        [data, scale, offset] = match(data, refdata, x_range, varargin)
%
% --- Purpose:
%        match the "data" to "refdata" within the range
%        "x_range". A constant multiplicant will be applied.
%
% --- Parameter(s):
%        data  - nxm (m>=2) data to be scaled
%        refdata - nxl (l>=2) reference data
%        varargin - 'scale', 'offset', or 'all'
% --- Return(s): 
%        results - 
%
% --- Example(s):
%
% $Id: match.m,v 1.3 2015/09/25 19:04:04 schowell Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

scale = 0;
offset = 0;
all = 0;
dy = []; % now it assumes dy has the same x axis as the data
parse_varargin(varargin);
if (scale ==0) && (offset == 0) && (all == 0)
   scale = 1;
end

[num_rows, ~] = size(data);

if (nargin < 3) % default range is all points included
  x_range = [data(1,1), data(num_rows,1)];
end

% 2) get the common range or use the X-ray

[~, imin] = min(abs(data(:,1)- x_range(1)));
[~, imax] = min(abs(data(:,1)- x_range(2)));

if (numel(refdata) == 1) % only a number is given
   refdata = repmat(refdata, imax-imin+1, 1);
else
   [~, imin_ref] = min(abs(refdata(:,1)- x_range(1)));
   [~, imax_ref] = min(abs(refdata(:,1)- x_range(2)));
   
   if (imax_ref == imin_ref) % only one point in the range in the reference data
      refdata = repmat(refdata(imax_ref,2), imax-imin+1,1);
   else % interpolate the refdata to have the same x axis 
      [dummy, idummy] = unique(refdata(:,1));
      refdata = interp1(dummy, refdata(idummy,2), data(imin:imax, 1));
   end
end

if (numel(dy) == 0)
   if (length(data(1,:)) == 2)
      dy = ones(imax-imin+1,1);
   else
      dy = data(imin:imax,min(4,end));
   end
else
   dy = dy(imin:imax);
end

% 3) set them to have the same mean

if (all == 1) || ((scale ==1) && (offset == 1))
   ab = linfit_reg(data(imin:imax,2), refdata, dy);
   scale = ab(1); offset = ab(2);
elseif (scale == 1)
   scale = total(refdata.*data(imin:imax,2)./dy.^2)/ ...
           total((data(imin:imax,2)./dy).^2);
   offset = 0;
else 
   scale = 1;
   offset = total((refdata - data(imin:imax,2))./dy.^2)/total(1./dy.^2);
end

if (verbose == 1)
   fprintf('range: [%0g,%0g]; scale: %g; offset: %g', x_range, scale, offset);
end

if ~isnan(scale)
  data(:,2:end) = data(:,2:end)*scale;
end
if ~isnan(offset)
  data(:,2) = data(:,2) + offset;
end
