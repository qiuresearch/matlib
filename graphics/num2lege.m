function lege = num2lege(numarr, prefix, suffix, format)
% --- Usage:
%        lege = num2lege(numarr, prefix, suffix, format)
% --- Purpose:
%        convert a numeric array to a cell array with customized
%        prefix and/or suffix
% --- Parameter(s):
%
% --- Return(s):
%        lege -
%
% --- Example(s):
%
% $Id: num2lege.m,v 1.3 2014/10/29 18:03:21 xqiu Exp $


if (nargin < 1)
   help num2lege
   return
end

if ~exist('prefix', 'var')
   prefix = '';
end

if ~exist('suffix', 'var')
   suffix = '';
end

if ~exist('format', 'var')
   format = '%g';
end

%
for i=1:length(numarr)
   lege{i} = [prefix num2str(numarr(i), format) suffix];
end
