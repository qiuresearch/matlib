function result = secondvirial_B22A2(B2, molweight, varargin);
% --- Usage:
%        result = secondvirial_B22A2(B2, molweight, varargin);
% --- Purpose:
%        converts second virial coeff in B2 (A^3) to A2 (ml*mol/g^2).
%
% --- Parameter(s):
%        B2        - second virial coefficient in A^3
%        molweight - molecular weight (g/mol)
%        varargin - 'reverse'; 
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: secondvirial_B22A2.m,v 1.1 2013/01/02 04:06:22 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
reverse = 0;
parse_varargin(varargin);

% calc the factor from B2 to A2
NA = 6.0221415e23;
factor = 1e-24*NA/molweight^2;

% return
if reverse == 0
   result = B2*factor;
else
   result = B2/factor;
end
