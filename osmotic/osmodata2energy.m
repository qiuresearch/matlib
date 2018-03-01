function [energy, osmodata] = osmodata2energy(osmodata, varargin);
% --- Usage:
%        [energy, osmodata] = osmodata2energy(osmodata, varargin);
% --- Purpose:
%        intergrate the osmotic force data to get the free energy
%        (work) per A. Hexagonal packaging is assumed.
%
% --- Parameter(s):
%        osmodata - col#1: distance (A); col#2: log10(pressure) (dyne/cm^2)
%
% --- Return(s): 
%        energy - in kT/A (T=25C)
%
% --- Example(s):
%
% $Id: osmodata2energy.m,v 1.4 2013/02/28 16:52:10 schowell Exp $
%
if (nargin < 1)
   help osmodata2energy
   return
end
temperature = 25; % 25 Celsius
parse_varargin(varargin);

% convert spacing to volume per A
osmodata(:,1) = osmodata(:,1).^2*sqrt(3)/2;
% convert pressure to linear unit in dyne/cm^2
osmodata(:,2) = 10.^osmodata(:,2);

% this is the energy, in the unit of dyne/cm^2*A^3
energy = integrate_numarr(osmodata);
% convert into KT at T=25C
kT = 4.11e-21/(273.15+25)*(temperature+273.15); % in Joule
energy = energy*1e-31/kT;
