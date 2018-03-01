function result = secondvirial_Sq02B2(sq0, rho, varargin);
% --- Usage:
%        result = secondvirial_Sq02B2(sq0, rho, varargin);
% --- Purpose:
%        calc second virial coeff in B2 (A^3) from S(q=0)
%
% --- Parameter(s):
%        sq0       - I(q=0)/I(q=0; if without interparticle interfernce)
%        rho       - number density in #/A^3
%        varargin  - 'reverse'
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: secondvirial_Sq02B2.m,v 1.1 2013/01/02 04:06:23 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
reverse = 0;
parse_varargin(varargin);

% give sq0 an arbitrary error bar
len_in = length(sq0);
if len_in == 1
 sq0(2) = 0.01*sq0(1);
end

% calculate B2 or sq0 as requested
if reverse == 0
   result = [(1/sq0(1)-1)/2/rho, sq0(2)/sq0(1)^2/2/rho];
else
   B2 = sq0;
   result = [1/(1+2*rho*B2(1)), 2*rho*B2(2)/(1+2*rho*B2(1))^2];
end

% only return the same number of elements as the input
if len_in == 1
   result = result(1);
end
