function [B2, virial] = secondvirial_Iq02B2(rho, iq0, varargin);
% --- Usage:
%        result = secondvirial_Iq02B2(iq0, rho, varargin);
% --- Purpose:
%        fit I(q=0) vs rho to obtain second virial coeff B2 (A^3)
%
% --- Parameter(s):
%        iq0       - I(q=0) (not scaled/normalized by concentration)
%        rho       - number density in #/A^3
%        varargin  - 
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: secondvirial_Iq02B2.m,v 1.1 2013/01/02 04:06:22 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
parse_varargin(varargin);

% check the length of input
[num_rows, num_cols] = size(iq0);
if num_rows == 1
   showinfo('AT LEAST two data points are needed!', 'error');
   result = 0;
end

x = reshape(rho, length(rho), 1);
y = x./iq0(:,1); % assume data were not scaled by denisty yet
dy = x.*iq0(:,2)./iq0(:,1).^2;
[ab, covar, chi2] = linfit_reg(x,y,dy);

virial.B2=[ab(1,1)/ab(2,1)/2, 0.5*sqrt((ab(1,2)/ab(2,1))^2 ...
                                      +(ab(1,1)/ab(2,1)/ab(2,1)*ab(2,2))^2)];
virial.B2_unit = 'A^3/#';
virial.i0_B2 = [ab(2,1), ab(2,2)];

virial.data = [x,y,dy];
virial.fit = [x, ab(1,1)*x+ab(2,1)];
virial.chi2 = chi2;
B2 = virial.B2;
