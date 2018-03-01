function hf = itc_plot(itc)
% --- Usage:
%        [adsorpdata, refdata] = uvspec_cuvette(cscfile)
% --- Purpose:
%        read the data output from UV photospectrometer
% --- Parameter(s):
%        cscfile - data file name as a string
% --- Return(s):
%        specdata    - a structure with all data in the fields
% --- Example(s):
%
% $Id: itc_plot.m,v 1.1 2013/08/18 04:10:55 xqiu Exp $
%

% 1) check how is called
verbose = 1;

if nargin < 1
   help itc_plot
   return
end

% 2) 

hf = clf;
subplot(2,2,1); hold all; title('Raw ITC Data');
xlabel(itc(1).column_names{1});
ylabel(itc(1).column_names{2});

for i=1:length(itc)
   xyplot(itc(i).data(:,[1,2]));
end
axis tight; xlim([0,itc(1).data(end,1)]);
                  
subplot(2,2,2); hold all; title('Baseline');
xlabel(itc(1).column_names{1});
ylabel(itc(1).column_names{2});

for i=1:length(itc)
   xyplot(itc(i).data(:,[1,3]));
end
legend(itc.title); legend boxoff
axis tight; xlim([0,itc(1).data(end,1)]);

subplot(2,2,3); hold all; title('ITC Data Baseline Subtracted');
xlabel(itc(1).column_names{1});
ylabel(itc(1).column_names{2});

for i=1:length(itc)
   xyplot(itc(i).data(:,[1,4]));
end
axis tight; xlim([0,itc(1).data(end,1)]);

subplot(2,2,4); hold all; title('ITC Integrated Area');
xlabel(itc(1).column_names{1});
ylabel(itc(1).column_names{2});

for i=1:length(itc)
   plot(itc(i).area(:,1), itc(i).area(:,2), 's-');
end
axis tight; xlim([0,itc(1).data(end,1)]);

return
