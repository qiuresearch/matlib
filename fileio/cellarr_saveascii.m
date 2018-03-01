function asciidata = cellarr_saveascii(cellarr, asciifile, varargin)
% --- Usage:
%        asciidata = cellarr_readascii(asciifile)
% --- Purpose:
%        read one ASCII file into a cell array. each cell is one
%        line. 
%
% --- Parameter(s):
%        asciifile - name of the file to rad
%
% --- Return(s): 
%        asciidata - the cell array
%
% --- Example(s):
%
% $Id: cellarr_saveascii.m,v 1.1 2013/01/15 02:03:31 xqiu Exp $

% 1) Simple check on input parameters
verbose = 1;
replace_tab = 1;
parse_varargin(varargin);

if nargin < 1
   error('Ascii file name should be provided!')
   return
end
if exist(asciifile, 'file')
   showinfo(['Ascill file: ' asciifile ' will be overwritten!']);
end

% 2) open and read the file

runit = fopen(asciifile, 'w');
for i=1:length(cellarr)
   fprintf(runit, '%s\n', cellarr{i});
end
fclose(runit);
