function fitres = fit_onepeak(data, xmin, xmax, varargin);
%        fitres = fit_onepeak(data, xmin, xmax, varargin);
% --- Purpose:
%    A general fitting program uses "lsqcurvefit" to fit a single peak
%    and get the uncertainties of the fitted parameters
%
%
% --- Parameter(s):
%    data -- 
%    func_type -- a string specifying which function to fit:
%     'linear':       y=par(1)*x+par(2);
%     'exponential':  y = par(1)*exp(par(2)*x) [+par(3)];
%     'gauss':        y =par(3)/par(2)/sqrt(2*pi)*exp(-0.5/par(2)/par(2)*(x-par(1)).^2)+ par(4);
%
% --- Return(s):
%    
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: xyfit.m,v 1.1.1.1 2007-09-19 04:45

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

noslope = 0; % whether to fit a slope in the background
lorentz = 1;
gauss = 0;
dnapeak = 0;
display = 1;
parse_varargin(varargin);

if ~exist('xmin', 'var') || isempty(xmin);
   xmin= data(1,1);
end
if~exist('xmax', 'var') || isempty(xmax);
   xmax= data(end,1);
end

rawdata = data;
imin = locate(data(:,1), xmin);
imax = locate(data(:,1), xmax);

% find the linear background
slope = (data(imax,2)-data(imin,2))/(data(imax,1)-data(imin,1));
if (noslope == 1); slope = 0; end
offset = data(imax,2) - slope*data(imax,1);
data(:,2) = data(:,2) - (slope*data(:,1)+offset);

% estimate the center, width, and area
data = data(imin:imax, :);
[ymax, imax] = max(data(:,2),[],1);
center = data(imax,1);
width = total(data(:,2).*abs(data(:,1)-center).^2)/total(data(:,2).*abs(data(:,1)-center));
area = total(data(:,2))*width*2/(numel(data(:,1))-1);

% rescale the data
scalefactor = abs(area/width);
rawdata(:,2:2:end) = rawdata(:,2:2:end)/scalefactor;
slope = slope/scalefactor;
offset = offset/scalefactor;
area = area/scalefactor;

% fit the one peak data
funcname = 'lorentz';
if (gauss == 1)
   funcname = 'gauss';
end
if (dnapeak == 1)
   funcname = 'dnapeak';
end
sopt.xmin = xmin;
sopt.xmax = xmax;
sopt.upper = [xmax, Inf, Inf, Inf, Inf];
sopt.lower = [xmin, -Inf, -Inf, -Inf, -Inf];
sopt.MaxIter = 50;
sopt.Display = 'off';
if (display == 1)
   sopt.Display = 'iter';
   disp(['Function type: ' funcname ', Guessing values -->'])
   disp(['   center: ' num2str(center)]);
   disp(['   width: ' num2str(width)]);
   disp(['   area: ' num2str(area)]);
   disp(['   offset: ' num2str(offset)]);
   disp(['   slope: ' num2str(slope)]);
end

if (noslope == 0)
   fitres = xyfit(rawdata, funcname, [center, width, area, offset, slope], sopt);
else
   fitres = xyfit(rawdata, funcname, [center, width, area, offset], sopt);
   fitres.par_init = [fitres.par_init, 0]; % this is just a
                                           % temporary fix
   fitres.par_fit = [fitres.par_fit, 0];
end
fitres.scalefactor = scalefactor;
