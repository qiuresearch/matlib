function lege = legend_add(hco, lege, varargin)
% --- Usage:
%        lege = legend_add(hco, lege)
% --- Description:
%        add a legend to current legends
%        hco - the handle to the plot object
%       lege - the legend for hco
%
% $Id: legend_add.m,v 1.3 2012/06/16 16:43:25 xqiu Exp $
%

if (nargin < 1)
   help legend_add
   return
end

if (nargin < 2)
   lege = hco;
   hco = gco;
end

if ~iscell(lege)
   lege = {lege};
end

[hlege, olege, plege, tlege] = legend;
if ~isempty(plege)
   legend([plege',hco], {tlege{:},lege{:}}, varargin{:});
else
   legend(hco, lege, varargin{:});
end
