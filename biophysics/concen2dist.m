function result = concen2dist(data_in, opts)
% --- Usage:
%        result = concen2con(data_in, opts)
% --- Purpose:
%        convert the mM concentration to the inter-molecule
%        distance in the solution
% --- Parameter(s):
%        data_in - either concentration (mM) or distance (A)
%        opts   - specify the direction of conversion. '
%                 'forward': concentration --> distance (default)
%                 'inverse': distance --> concentration
% --- Return(s):
%        results - ...
%
% --- Example(s):
%
% $Id: concen2dist.m,v 1.1 2013/08/18 04:10:54 xqiu Exp $
%

if (nargin < 1)
   help concen2dist
   return
end

% set the default behavior
if nargin < 2
   opts = 'forward';
end

% concentration (mM) to distance (A)
if strcmp(opts, 'forward')
   con = data_in;
   result = (1e9^3./(con*1e-3*6.023e23)).^(1/3);
end

% distance (A) to concentation (mM)
if strcmp(opts, 'inverse')
   dist = data_in;
   result = (1e9)^3./dist.^3/(1e-3*6.023e23);
end
