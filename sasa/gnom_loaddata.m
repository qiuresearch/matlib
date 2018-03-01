function [data, title] = gnom_loaddata(datafile, varargin)
% --- Usage:
%        [data, title] = gnom_loaddata(datafile, varargin)
% --- Purpose:
%        
% --- Parameter(s):
%        
% --- Return(s):
%        
% --- Example(s):
%
% $Id: gnom_loaddata.m,v 1.2 2011-09-07 22:41:25 xqiu Exp $
%

% 1) check how is called
verbose = 1;

if nargin < 1
   help gnom_loaddata
   return
end

% 2) read the spec file, and remove useless lines

runit = fopen(datafile, 'r');
datalines = fread(runit);
fclose(runit);

datalines = strtrim(strsplit(char(datalines'), sprintf('\n'), 'preserve_null'));
if ischar(datalines)
   showinfo('no NEW LINE found, try CARRIAGE RETURN ...');
   datalines = strtrim(strsplit(char(datalines), sprintf('\r'), 'preserve_null'));
end
datalines = strrep(datalines, sprintf('\t'), ' '); % replace TAB

% 3) get the number of rows and columns of the data block

title = datalines{1};
if (verbose == 1)
   disp(['Title: ' title])
end
data = str2num(str2mat(datalines(2:end)));

return
