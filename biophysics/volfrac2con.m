function result = volfrac2con(data_in, radius, opts)
% --- Usage:
%        result = volfrac2con(data_in, radius, opts)
% --- Purpose:
%        conversion between volume fraction and concentration of a
%        spherical molecule
% --- Parameter(s):
%        data_in - either the volume fraction or concentration
%        radius - the radius of the molecule
%        opts   - specify the direction of conversion. '
%                 'forward': volfra --> concentration (default)
%                 'inverse': concentration --> volfra
% --- Return(s):
%        results - ...
%
% --- Example(s):
%
% $Id: volfrac2con.m,v 1.1 2013/08/18 04:12:49 xqiu Exp $
%

if (nargin < 2)
   help volfrac2con
   return
end

% set the default behavior
if nargin < 3
   opts = 'forward';
end

% volfrac --> concentration
if strcmp(opts, 'forward')
   volfrac = data_in;
   result = volfrac/(4.0*pi/3.0*radius^3)/(6.023e-7);
end

% concentration --> volfrac
if strcmp(opts, 'inverse')
   con = data_in;
   result = con*(6.023e-7)*radius^3*4.0*pi/3.0;
end
