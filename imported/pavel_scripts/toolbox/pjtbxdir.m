function o=pjtbxdir(arg)
%PJTBXDIR ARG returns PJ directories
%ARG can be 'm'
%           'tbx', 'toolbox', 
%           'data', 
%           'pj', 'pavol'
%           'pdf', 'aids'
%           'db325', 'dell325b'

if nargin==0
    arg='pj';
end
txdir=fileparts(which(mfilename));
txdir=strrep(txdir, '\', '/');
pjdir=txdir; pjdir(end-9:end)='';
arg=lower(arg);
o='';
switch(arg)
case {'pj', 'pavol'},
    o=pjdir;
case {'tbx', 'toolbox'},
    o=txdir;
case 'data',
    o=[pjdir '/data'];
    if ~exist(o, 'dir')
	o=[pjdir '/UPENN/data'];
    end
case 'm',
    o=[pjdir '/m'];
case {'pdf', 'aids'},
    o=[pjtbxdir('data') '/pdfcards'];
case {'db325', 'dell325b'},
    o=pjdir; o(end-11:end)='';
end
