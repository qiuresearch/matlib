function peakdata = cnt_uvpeaks(data, varargin)
% --- Usage:
%        peakdata = cnt_uvpeaks(data, varvargin)
%
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%        var   - 
%
% --- Example(s):
%
% $Id: cnt_uvpeaks.m,v 1.1 2012/06/30 22:08:37 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

type = [6,5];
format = '[%0.0f,%0.3f]';
nofig = 0;
parse_varargin(varargin);

peakrange = [900, 1100; ...
             550, 600; ...
             640, 680; ...
             230, 300; ...
             750, 800];
peaksign = [1; ...
            1; ...
            1; ...
            1; ...
           -1];

for i=1:length(peaksign)
   imin = locate(data(:,1), peakrange(i,1));
   imax = locate(data(:,1), peakrange(i,2));
   tmpdata = data(min([imin,imax]):max([imin,imax]),:);
   if (peaksign(i) == 1)
      [y, imax] = max(tmpdata(:,2));
   else
      [y, imax] = min(tmpdata(:,2));
   end
   peakdata(i,:) = [tmpdata(imax,1), y];
   if (nofig ~= 1)
      showcoord(peakdata(i,:), format);
   end
end
