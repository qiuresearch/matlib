function specdata = jasco_average(jascodata)
% --- Usage:
%        specdata = fluor_readascii(datafile)
% --- Purpose:
%        read a SPEC format file to an array of structures
%
% --- Parameter(s):
%     
% --- Return(s):
%        results - 
%
% --- Example(s):
%
% $Id: jasco_average.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%
verbose = 1;
% 1) check the specfile
if nargin < 1
   error('at least one parameter is required, please see the usage! ')
   help  jasco_average
   return
end

specdata = jascodata(1);
for i=2:length(jascodata)
   specdata.title = [specdata.title jascodata(i).title];
   specdata.data(:,[2,3]) = specdata.data(:,[2,3]) + ...
       jascodata(i).data(:,[2,3]);
end
specdata.title = ['average of ' specdata.title];
specdata.data(:,[2,3]) = specdata.data(:,[2,3])/length(jascodata);

