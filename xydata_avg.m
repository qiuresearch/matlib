function [data1, data2] = xydata_avg(data1, data2, varargin)
% --- Usage:
%        [data1, data2] = xydata_avg(data1, data2, varargin)
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
% $Id: xydata_avg.m,v 1.2 2013/01/02 04:06:22 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

if (length(data1(:,1)) ~= length(data2(:,1))) || ...
       (max(abs(data1(:,1)-data2(:,1))) > 0)
   data2i(:,1) = data1(:,1);
   for i=2:length(data1(1,:))
      data2i(:,i) = interp1(data2(:,1), data2(:,i), data1(:,1), 'pchip');
   end
   data2 = data2i;
end

data1(:,2) = (data1(:,2)+data2(:,2))/2;
