function com = calcCOM(coor, mass, varargin)
% --- Usage:
%        com = calcCOM(coor, mass, varargin)
%
% --- Purpose:
%        this function calculates the center of mass of an object
%        in real space from the coordinates and mass of it's parts
%        
% --- Parameter(s):
%        coor
%        mass
%        
% --- Return(s): 
%        com
%
% --- Example(s):
%
% $Id: calcCOM.m,v 1.2 2014/02/20 15:36:58 schowell Exp $

if nargin < 2
  if nargin < 1
    funcname = mfilename; % or use dbstack to get its caller if needed
    eval(['help ' funcname]);
    return
  end
  mass = ones(size(coor,1),1);% default to all atoms having the same mass
end

parse_varargin(varargin);
if ~length(mass) == length(coor)
    fprintf('Different number of coordinates and masses')
end

totalMass = sum(mass);
mass3 = repmat(mass,1,3);
com = sum(mass3.*coor)/totalMass;