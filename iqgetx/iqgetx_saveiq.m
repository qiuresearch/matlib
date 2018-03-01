function hf = iqgetx_saveiq(sIqgetx, iqfile, varargin)
% --- Usage:
%        hf = iqgetx_plotV(sIqgetx, varargin)
% --- Purpose:
%        do a general plot of the signal and buffer I(Q) data
%
% --- Parameter(s):
%        sIqgetx - an array of IqGetX structure
%
% --- Return(s): 
%        result - 
%
% --- Example(s):
%
% $Id: iqgetx_saveiq.m,v 1.6 2014/03/19 05:07:04 xqiu Exp $
%

if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   error('at least one parameter is required, please see the usage! ')
end

for i=1:length(sIqgetx)
   specdata = sIqgetx(i);
   specdata = rmfield(specdata, {'iq'});
   if isfield(sIqgetx(i), 'x')
      specdata.scannum = sIqgetx(i).x;
   elseif isfield(sIqgetx(i), 'id')
      specdata.scannum = sIqgetx(i).id;
   else
      specdata.scannum = i;
   end
   
   specdata.data = sIqgetx(i).iq;
   specdata.columnnames = {'Q(/A)', 'I(Q)', 'NumPixels', 'dI(Q)'};
   if isfield(sIqgetx(i), 'sam') && isfield(sIqgetx(i).sam, 'iq') && ...
          ~isempty(sIqgetx(i).sam.iq)
      
      specdata.data = [specdata.data, sIqgetx(i).sam.iq(:,[2,4])];
      specdata.columnnames = {specdata.columnnames{:}, 'I(Q)bkg', 'dI(Q)bkg'};
   end

   if exist('iqfile', 'var')
      if iscellstr(iqfile)
         specdata_savefile(specdata, iqfile{min(i,end)});
      else
         specdata_savefile(specdata, iqfile);
      end
   else
      specdata_savefile(specdata, [sIqgetx(i).label '.iq']);
   end
end
