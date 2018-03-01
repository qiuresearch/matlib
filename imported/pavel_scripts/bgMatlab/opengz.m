function h = opengz(filename)
%OPENGZ      opens gzipped file
%  Helper function for OPEN.
%
%  See also OPEN.

%  $Id: opengz.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    [file, path] = uigetfile('*.gz', 'Open gzipped file');
    filename = lower([path , file]);
    if ~isstr(file)
       return;
    end;
end
[path,ifile,ext]=fileparts(filename);
if ~strcmp(ext,'.gz')
    error([filename ' has unknown extension']);
end
ofile=[tempname ifile];
cmd=['!gzip -cd ' filename ' > ' ofile];
eval(cmd);
open(ofile);
delete(ofile)
