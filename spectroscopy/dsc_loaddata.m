function dscdata = dsc_loaddata(dscfile)
% --- Usage:
%        dscdata = dsc_loaddata(dscfile)
%
% --- Purpose:
%
% --- Parameter(s):
%        var   - 
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: dsc_loaddata.m,v 1.1 2010-02-08 17:02:01 xqiu Exp $
%

verbose =1;
dscdata = [];

ascdata = cellarr_readascii(dscfile);

iscan = strmatch('Scan #', ascdata);

if isempty(iscan)
   showinfo(['Error: No Scan # found in DSC data file: ' dscfile]);
   return
end

dscdata.numscans = length(iscan);
dscdata.colnames = strsplit(ascdata{iscan(1)}, ',');

iscan = [iscan', length(ascdata)+1];

for ii=1:(length(iscan)-1)
   scanname = ['scan' num2str(ii)];
   scandata = cell2mat(ascdata(iscan(ii)+1:iscan(ii+1)-1));
   dscdata.(scanname) = str2num(scandata);
end
