function [dlen, l_bjerrum] = debye_length(I, varargin)
% --- Usage:
%        [dlen, l_bjerrum] = debye_length(I, varargin)
% --- Purpose:
%        calculate the Debye-Huckel screening length given the
%        ionic strength
% --- Parameter(s):
%        I - ionic strength in mM
%        T - temperature in K (default: 298K)
% --- Return(s): 
%        dlen - Debye-Huckel screening length
%        l_bjerrum - the Bjerrum length 
% --- Example(s):
%
% $Id: debye_length.m,v 1.3 2015/02/23 03:31:20 xqiu Exp $
%

T = 298.0;
epsilon = 78.3;

parse_varargin(varargin);

epsilon_0 = 8.8542e-12; % (F/m in MKS unit) permittivity of the free space
k_B = 1.3806503e-23; % the Boltzman constants

beta = 1.0/T/k_B; % 1/(K_BT) 

% in (A)
l_bjerrum = 1.0e10*(1.6022e-19)^2 *beta/(4.0*pi*epsilon_0 * epsilon);

% the 6.02e-7 is used to adjust the units (last checked on 11/29/2004)
% the Debye-Huckel screening length
kappa = sqrt(6.02e-7*8.0*pi*I*l_bjerrum);
dlen = 1./kappa;
