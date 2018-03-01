function result = ratio_flux2width(ratio, opts)
% --- Usage:
%        result = ratio_flux2width(ratio, opts)
% --- Purpose:
%        conversion between ratio of flux to width of our current
%        mixer in 2D
% --- Parameter(s):
%        ratio  - either the flux or width ratio
%        opts   - specify the direction of conversion. '
%                 'forward': flux --> width (default)
%                 'inverse': width --> flux
% --- Return(s):
%        results - ...
%
% --- Example(s):
%
% $Id: ratio_flux2width.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help ratio_flux2width
   return
end

% set the default behavior
if (nargin < 2)
   opts = 'forward';
end

% flux --> width
if strcmp(opts, 'forward')
   result = roots([0.5, 0, -1.5, 0.5*ratio/(1+ 0.5*ratio)]);
   result = min(result((imag(result) == 0) & (real(result) > 0)));
end

% width --> flux
if strcmp(opts, 'inverse')
   result = (ratio - ratio^3/3)*3/2;
   result = (1/(1-result)-1)*2;
end
