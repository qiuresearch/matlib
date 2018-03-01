function [rg, fitres] = rgfit_auto(iq, varargin)
% --- Usage:
%        [rg, fitres] = gyration_autorg(iq, varargin)
%
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%        varargin   - 'qmin' 'imin' 'plotfit'
%
% --- Example(s):
%
% $Id: rgfit_auto.m,v 1.2 2014/06/26 01:47:16 xqiu Exp $
%


verbose = 1;
plotfit = 1;
parse_varargin(varargin);

% get the starting point
if exist('imin', 'var')
   qmin = iq(imin,1);
elseif exist('qmin', 'var');
   imin = locate(iq(:,1), qmin);
else
   imin = 1;
   qmin = iq(1,1);
end

% fit Rg from imin for every point
go_fit = 1;
imax = imin + 1;
showinfo(num2str([qmin, imin], 'Qmin=%0.5g; imin=%i'));
fitres = [];
while go_fit
   imax = imax+1;
   fitres = [fitres, rgfit(iq, iq([imin,imax],1))];
   
   if fitres(end).rg(1)*iq(imax,1)>2.3
      go_fit = 0;
   end
end
rg = reshape([fitres.rg], 2, length(fitres))';

if (plotfit == 1)
   figure_format('normal'); 
   figure; clf; hold all;
   qmax2 = iq(imin+2:imax,1).^2;
   
   subplot(2,2,1);
   errorbar(qmax2, rg(:,1), rg(:,2));
   ylabel('Rg');
      
   subplot(2,2,2);
   plot(qmax2, [fitres.chi2]);
   set(gca, 'yscale', 'log');
   ylabel('chi^2');
   
   subplot(2,2,3); hold all;
   xyplot(guinier(iq), 'o');
   xylabel('guinier');
   
   for i=1:length(fitres);
      xyplot(fitres(i).fit);
   end
   
   for i=1:4;
      subplot(2,2,i);
      xlim([0, qmax2(end)*1.2]);
      xlabel('Qmax^2', 'Interpreter', 'Tex');
   end
end
