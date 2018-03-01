function itc = itc_readcsc(cscfile)
% --- Usage:
%        [adsorpdata, refdata] = uvspec_cuvette(cscfile)
% --- Purpose:
%        read the data output from UV photospectrometer
% --- Parameter(s):
%        cscfile - data file name as a string
% --- Return(s):
%        specdata    - a structure with all data in the fields
% --- Example(s):
%
% $Id: itc_readcsc.m,v 1.1 2013/08/18 04:10:55 xqiu Exp $
%

% 1) check how is called
verbose = 1;

if nargin < 1
   help itc_readcsc
   return
end

% 2) read the spec file, and remove useless lines

runit = fopen(cscfile, 'r');
itclines = fread(runit);
fclose(runit);

itclines = strtrim(strsplit(char(itclines'), sprintf('\n'), 'preserve_null'));
if ischar(itclines)
   showinfo('no NEW LINE found, try CARRIAGE RETURN ...');
   itclines = strtrim(strsplit(char(itclines), sprintf('\r'), 'preserve_null'));
end
itclines = strrep(itclines, sprintf('\t'), ' '); % replace TAB

% 3) get the number of rows and columns of the data block

itc.format = 'CSC';
itc.title = cscfile;
itc.column_names = strsplit(itclines{1}, ' ');

num_cols = length(itc.column_names);
num_rows = length(itclines)-1;

itc.data = str2num(str2mat(itclines(2:end)));

return
