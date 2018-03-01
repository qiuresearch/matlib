function ok = dls_plot(dlsdata, varargin)
% --- Usage:
%        ok = dls_plot(dlsdata, varargin)
% --- Purpose:
%        plot DLS data
% --- Parameter(s):
%        dlsdata - an array of DLS data structure
%        varargin - 'correlation': 
%                   'distribution': 
%                   'show_temp': 
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: dls_plot.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

% 1) Simple check on input parameters

if (nargin < 1)
   help dls_plot
   return
end

correlation = 1;
distribution = 1;
show_temp = 1;

if ~isfield(dlsdata(1), 'Temperature') || (dlsdata(1).Temperature == ...
                                           dlsdata(ceil(end/2)).Temperature)
   show_temp = 0;
end

parse_varargin(varargin);


clf;
set(gcf, 'PaperPosition',  [0.25,1,8,9]);
subplot(2,1,1); hold all; set(gca, 'XScale', 'Log');
   
if (correlation == 1)
   for i=1:length(dlsdata)
      plot(dlsdata(i).Correlation_Delay_Times, dlsdata(i).Correlation_Data);
      
      if (show_temp == 1)
         lege{i}= [dlsdata(i).Sample_Name '(' ...
                   num2str(dlsdata(i).Temperature) 'C)'];
      else
         lege{i}= dlsdata(i).Sample_Name;
      end
   end
   axis tight; zoomout(0.05);
   legend(lege); legend boxoff
   dlslabel
end

subplot(2,1,2); hold all; set(gca, 'XScale', 'Log');
title('Size Distribution');
if (distribution == 1)
   for i=1:length(dlsdata)
      plot(dlsdata(i).Sizes, dlsdata(i).Intensities);
      if (show_temp == 1)
         lege{i}= [dlsdata(i).Sample_Name '(' ...
                   num2str(dlsdata(i).Temperature) 'C)'];
      else
         lege{i}= dlsdata(i).Sample_Name;
      end
   end
   axis tight; zoomout(0.05);
   legend(lege); legend boxoff
   xlabel(['Sizes (nm)'], 'Interpreter', 'LaTex');
   ylabel(['Intensities (\%)'], 'Interpreter', 'LaTex');
end

