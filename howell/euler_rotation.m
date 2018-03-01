function coor = euler_rotation(coor, phi, theta, psi, varargin)
% --- Usage:
%        coor = euler_rotation(coor, phi, theta, psi, origin, varargin)
%        calculate the rotated coordinates using the three euler rotations
%        according to the "x-convention" (Goldstein 1980, pp. 145-148)
% --- Purpose:
%        transform coordinates using the Euler angles
%
%        
% --- Parameter(s):
%        coor:    3D coordinates to transform
%        phi:     1st rotation angle in radians, about z  (=z')
%        theta:   2nd rotation angle in radians, about x' (=x'')
%        psi:     3rd rotation angle in radians, about z' (=z'')
%        
% --- Optional Parameter(s):
%        origin:  coordinate to rotate about
%        z_vec:   dircetion to use as the original z direction
%        degrees: designate that the angles are in degrees
%
% --- Return(s): 
%        coor
%
% --- Example(s):
%
% $Id: euler_rotation.m,v 1.1 2014/03/19 17:00:08 schowell Exp $

if nargin < 4
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

debug = 0;
origin = [0,0,0];
% z_vec = [0,0,1];
parse_varargin(varargin);

if exist('degrees', 'var')
   display('converting angles to radians');
   phi = phi * pi/180;
   theta = theta * pi/180;
   psi = psi * pi/180;   
end

n = length(coor);

coor4 = ones(n,4);
coor4(:,1:3) = coor;
if debug
   display('original coor:')
   coor4
end

move2o = eye(4);        % matrix to move to designated origin
move2o(4,1:3) = -origin;
returnFo = eye(4);      % matrix to return from origin
returnFo(4,1:3) = origin;
align2z = eye(4);       % matrix to align z to a vector

coor4 = coor4 * move2o;
if debug
   display('moved 2 origin:')
   coor4
end

if exist('z_vec', 'var')
   u = z_vec(1);
   v = z_vec(2);
   w = z_vec(3);
   
   small = 1E-14; % small limit to make sure not dividing by zero
   
   d1 = sqrt(u^2+v^2);
   d2 = sqrt(u^2+v^2+w^2);
   
   if d1 > small
      align2z(1,1) = u/d1*w/d2;
      align2z(1,2) = -v/d1;
      align2z(1,3) = u/d2;
      align2z(2,1) = v/d1*w/d2;
      align2z(2,2) = u/d1;
      align2z(2,3) = v/d2;
      align2z(3,1) = -d1/d2;
      align2z(3,2) = 0;
      align2z(3,3) = w/d2;
      if debug
         display('alignment matrix:');
         align2z
      end
   end
   
   coor4 = coor4 * align2z;
   if debug
      display('aligned:')
      coor4
   end
end

R = eye(4);

% R(1,1) =  cos(psi) * cos(phi) - cos(theta) * sin(phi) * sin(psi);
% R(1,2) =  cos(psi) * sin(phi) + cos(theta) * cos(phi) * sin(psi);
% R(1,3) =  sin(psi) * sin(theta);
% R(2,1) = -sin(psi) * cos(phi) - cos(theta) * sin(phi) * cos(psi);
% R(2,2) = -sin(psi) * sin(phi) + cos(theta) * cos(phi) * cos(psi);
% R(2,3) =  cos(psi) * sin(theta);
% R(3,1) =  sin(theta) * sin(phi);
% R(3,2) = -sin(theta) * cos(phi);
% R(3,3) =  cos(theta);
c_psi = cos(psi);
c_phi = cos(phi);
c_theta = cos(theta);
s_psi = sin(psi);
s_phi = sin(phi);
s_theta = sin(theta);

R(1,1) =  c_psi * c_phi - c_theta * s_phi * s_psi;
R(1,2) =  c_psi * s_phi + c_theta * c_phi * s_psi;
R(1,3) =  s_psi * s_theta;
R(2,1) = -s_psi * c_phi - c_theta * s_phi * c_psi;
R(2,2) = -s_psi * s_phi + c_theta * c_phi * c_psi;
R(2,3) =  c_psi * s_theta;
R(3,1) =  s_theta * s_phi;
R(3,2) = -s_theta * c_phi;
R(3,3) =  c_theta;

coor4 = coor4 * R;
if debug
   display('original coor:')
   coor4
end
% un-align and return origin to original location

coor4 = coor4 * align2z';
if debug
   display('un-aligned:')
   coor4
end

coor4 = coor4 * returnFo;
if debug
   display('returned from origin:')
   coor4
end

coor = coor4(:,1:3);
