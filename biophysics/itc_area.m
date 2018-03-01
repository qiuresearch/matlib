function itc = itc_area(itc, varargin)
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
% $Id: itc_area.m,v 1.1 2013/08/18 04:10:55 xqiu Exp $
%

% 1) check how is called
verbose = 1;

if nargin < 1
   help itc_area
   return
end

% 2) 

if ~isfield(itc, 'inject_start')
   itc.inject_start = 300;
   itc.inject_interval = 300;
end

itc.inject_time = [itc.inject_start:itc.inject_interval: ...
                   itc.data(end,itc.itime)];

itc.area_raw(:,1) = itc.inject_time(1:end-1);
imin = locate(itc.data(:,itc.itime), itc.inject_start);
for i=1:length(itc.area_raw(:,1))
   imax = locate(itc.data(:,itc.itime), itc.inject_time(i+1));
   itc.area_raw(i,2) = total(itc.data(imin:imax,itc.idifpower))* ...
       (itc.data(imax,itc.itime)-itc.data(imin,itc.itime))/(imax-imin);
   imin = imax;
end

% try to normalize the calculated area to 
itc.temperature = 25 + 273.15; % K
KT = 1.3806503e-23 * itc.temperature; % thermal energy

itc.area = itc.area_raw;
%itc.area(:,1) = 
itc.area(:,2) = itc.area(:,2)*1e-6/(itc.inject_volume* ...
                                    itc.inject_concen*1e-9)/KT/6.023e23;


itc.area_unit = 'KT per molecule injection';
return
