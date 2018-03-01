function [iq, pr] = gnom_saveiqpr(sgnom, filedir)
% --- Usage:
%        [avgdata, imgdata] = template(var)
%
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%        var   - 
%
% --- Example(s):
%
% $Id: gnom_saveiqpr.m,v 1.4 2015/07/30 20:43:19 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

% estimate error bars for the lines with NaN as error bars

inans = find(isnan(sgnom.iq(:,3)));

if ~isempty(inans)
    sgnom.iq(inans,3) = sgnom.iq(inans,5)/mean(sgnom.iq(inans+ inans(end),4))* ...
        mean(sgnom.iq(inans+inans(end),3));
end

gnom_savedata(sgnom.iq(:,[1,5,3]), fullfile(filedir, [sgnom.filename ...
                    '.giq']), 'header', sgnom.title);

saveascii(sgnom.pr, fullfile(filedir, [sgnom.filename '.gpr']));

%gnom_savedata(sgnom.pr, fullfile(filedir, [sgnom.filename '.gpr']), ...
%              'header', sgnom.title);

