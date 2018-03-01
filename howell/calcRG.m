function rg = calcRG(coor, mass, varargin)
% --- Usage:
%        rg = calcrg(coor, vargin)
%
% --- Purpose:
%        this function calculates the radius of gyration of an
%        object from real space coordinates
%        
% --- Parameter(s):
%        coor
%        mass
%        
% --- Return(s): 
%        rg
%
% --- Example(s):
%
% $Id: calcRG.m,v 1.3 2014/02/20 16:19:56 schowell Exp $

if nargin < 2
	if nargin < 1
		funcname = mfilename; % or use dbstack to get its caller if needed
		eval(['help ' funcname]);
		return
	end
	mass = ones(size(coor,1),1); % default to all atoms having the same mass
end

parse_varargin(varargin);

N = length(coor);
com = calcCOM(coor,mass);
comN = repmat(com,N,1);
dxyz = (coor-comN).^2;
rg = sqrt(sum(sum(dxyz))/N);

