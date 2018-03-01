function asciidata = cellarr_readascii(asciifile, varargin)
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
% $Id: cellarr_readascii.m,v 1.1 2011-10-08 14:55:34 xqiu Exp $
%

% 1) Simple check on input parameters

verbose = 1;
replace_tab = 1;
parse_varargin(varargin);

if nargin < 1
   error('Ascii file name should be provided!')
   return
end

if ~ exist(asciifile, 'file')
   error(['Ascill file: ' asciifile ' can not be found!'])
   return
end

% 2) open and read the file

runit = fopen(asciifile, 'r');
asciidata = fread(runit);
fclose(runit);

asciidata = strsplit(char(asciidata'), sprintf('\n'), 'preserve_null');
if ischar(asciidata)
   showinfo('no NEW LINE found, try CARRIAGE RETURN ...');
   asciidata = strsplit(asciidata, sprintf('\r'), 'preserve_null');
end

if (replace_tab == 1)
   asciidata = strrep(asciidata, sprintf('\t'), ' ');
end

% asciidata = strtrim(asciidata);
