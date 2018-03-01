function [ab, covar, chi2] = linfit_alg(x,y,dy,mode)
% --- Usage:
%        [ab, covar, chi2] = linfit(x,y,dy,varargin)
%
% --- Purpose:
%        fit y=ax+b analytically (no matrix inversion)
%
% --- Parameter(s):
%        var   - 
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: linfit_alg.m,v 1.3 2013/09/21 03:32:47 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

if ~exist('dy', 'var') || isempty(dy)
   dy = ones(length(x),1);
end
if ~exist('mode', 'var') || isempty(mode)
   mode = 'ab';
end

% remove NaN in x, y, dy
inan = find(isnan(x) | isnan(y) | isnan(dy));
if ~isempty(inan)
   showinfo(num2str(length(inan), 'Data to fit contain %i NaN, removing...'), 'warning');
   x(inan) = [];
   y(inan) = [];
   dy(inan) = [];
end

% do the analytical calculation
inv_dy2=1./dy.^2;
if strcmpi(mode, 'b') % only the offset
   ab(1,:)=[1,0];
   ab(2)=[total((y-x).*inv_dy2)/total(inv_dy2),0];
   covar=[1,0;0,1];
end

if strcmpi(mode, 'a') % only the scale
   ab(1,:)=[total(y.*x.*inv_dy2)/total(x.^2.*inv_dy2),0];
   ab(2,:)=[0,0];
   covar=[1,0;0,1];
end

if strcmpi(mode, 'ab') % scale and offset
   ab(1,:)=[(total(x.*y.*inv_dy2)*total(inv_dy2)-total(y.*inv_dy2)*total(x.*inv_dy2))/ ...
            (total(x.^2.*inv_dy2)*total(inv_dy2)-total(x.*inv_dy2)^2), 0];
   ab(2,:)=[(total(x.*y.*inv_dy2)-total(x.^2.*inv_dy2)*ab(1))/ total(x.*inv_dy2),0];

   % note that the error bar calculation has been done in the
   % xypro_sasff.m.
   
   covar=[1,0;0,1];
end

chi2 = total(((y-ab(1)*x-ab(2)).^2).*inv_dy2)/(length(x)-1);
