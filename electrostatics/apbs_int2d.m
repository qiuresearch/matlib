function [fr, sPar] = apbs_int2d(sAPBS, varargin)
% --- Usage:
%        [fr, sPar] = apbs_int2d(sAPBS, varargin)
% --- Purpose:
%        integrate the sAPBS.data in the XY plane. Along the Z,
%        only a layer with certain width (default 50% of the total Z
%        height) is averaged to avoid "end effect".
% --- Parameter(s):
%        sAPBS - the structure from routine "abps_readdx"
%
%        grid - grid size in A (real distance) (default: 1A)
%        zwidth - width of the layer as a fraction of the total
%        (default 0.3)
% --- Return(s): 
%        fr - the integrated data (Nx3 matrix). Third column is the
%        number of bins for the point. Note that the X is the real
%        physical distance .
%        sPar - the integration settings
% --- Example(s):
%
% $Id: apbs_int2d.m,v 1.2 2012/06/16 16:43:24 xqiu Exp $
%

% 1) default settings
grid = 1.0; zwidth = 0.33;
parse_varargin(varargin)

% 2) data to integrate: center cut along z
iz_min = floor(sAPBS.dime(3)*(1-zwidth)/2);
iz_max = ceil(sAPBS.dime(3)*(1+zwidth)/2);
data = mean(sAPBS.data(:,:,iz_min:iz_max), 3);

% 3) set up integration parameters
sPar.iz_min = iz_min;
sPar.iz_max = iz_max;
sPar.z_height = (iz_max-iz_min+1)*sAPBS.delta(3,3);
sPar.MaskI = ones(sAPBS.dime(1:2));
sPar.X_cen = ceil(sAPBS.dime(1)/2);
sPar.Y_cen = ceil(sAPBS.dime(2)/2);
sPar.Y_scale = sAPBS.delta(2,2)/sAPBS.delta(1,1);

% only the inner circle of the box is integrated
sPar.num_points = round((sAPBS.dime(1)+sAPBS.dime(2)*sPar.Y_scale)/ ...
                        sqrt(8)*sAPBS.delta(1,1)/grid) +1; 
% used normalized rmin, rmax (in the unit of number of grids, not
% real distance). Later will be converted back to real distance
sPar.rmin = 0;
sPar.rmax = sPar.rmin + (sPar.num_points -1)/sAPBS.delta(1,1);

sPar.mode=1;
sPar.method=1;
[fr, fr_bins]=integrate_2d(data, sPar);
fr(:,3) = fr_bins'; % third column will be the number of bins in
                    % each point

% 4) convert to physical distance
fr(:,1) = fr(:,1) * sAPBS.delta(1,1);
