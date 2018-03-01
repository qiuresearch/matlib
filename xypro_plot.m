function handle = xypro_plot(xydata, varargin)
%        handle = xypro_plot(xydata, varargin)
% --- Purpose:
%        plot the xydata structure.
%
% --- Parameter(s):
%            xydata - an arryy of the xypro data structure
%          varargin - currently takes the following
%               dataselect - a cell array, e.g., {'rawdata', 'data'}
%               plotopt    - a structure, e.g., ('legend', 1, 'errorbar', 1);
%
% --- Return(s): 
%        results - 
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: xypro_plot.m,v 1.9 2015/10/08 16:21:06 schowell Exp $
%
verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
parse_varargin(varargin);

if ~exist('dataselect', 'var') || isempty(dataselect)
   dataselect = 'data';
end
plotopt_default = struct('axisfontsize', 10, 'grid',1, 'legend', 1, 'legendfontsize', ...
                         10, 'errorbar', 0, 'marker', 1, 'markersize', ...
                         3, 'line', 0, 'linewidth', 2, 'logx', 1, ...
                         'logy', 1, 'istep', 1);
if ~exist('plotopt', 'var') || isempty(plotopt)
   plotopt = plotopt_default;
else
   plotopt = struct_assign(plotopt, plotopt_default, 'append');
end

% 2) plot the data
iplot = 0; plotdata = {}; plotlege = {};
num_data = length(xydata);
index = 1:num_data;
for iselect = 1:length(index)
   i = index(iselect);
   
   [pathstr, short_title, ext] = fileparts(xydata(i).title);
   
   if ~isempty(strmatch('rawdata', dataselect, 'exact'))
      iplot = iplot + 1;
      plotdata{iplot} = xydata(i).rawdata(:,[xydata(i).xcol,xydata(i).ycol,xydata(i).ecol]);
      plotlege{iplot} = ['rawdata - '  short_title];
   end
   
   if ~isempty(strmatch('data', dataselect, 'exact'))
      iplot = iplot + 1;
      plotdata{iplot} = xydata(i).data(:,[1,2,4]);
      plotlege{iplot} = ['data - '  short_title];
   end
   
   if ~isempty(strmatch('calcdata', dataselect, 'exact'))
      iplot = iplot + 1;
      plotdata{iplot} = xydata(i).calcdata;
      plotlege{iplot} = ['calcdata - '  short_title];
   end
   
   if ~isempty(strmatch('fitdata', dataselect, 'exact'))
      iplot = iplot + 1;
      plotdata{iplot} = xydata(i).fitdata;
      plotlege{iplot} = ['fitdata - '  short_title];
%      iplot = iplot + 1;
%      plotdata{2*iplot-1} = xydata(i).iq_dif(:,1);
%      plotdata{2*iplot} = xydata(i).iq_dif(:,2);
%      plotlege{iplot} = ['dif I(Q) - '  xydata(i).title];
%      iplot = iplot + 1;
%      plotdata{2*iplot-1} = [xydata(i).iq(:,1); nan; xydata(i).iq(:,1)] ;
%      plotdata{2*iplot} = [xydata(i).iq(:,4); nan; xydata(i).iq(:,4)];
%      plotlege{iplot} = ['err I(Q) - '  xydata(i).title];
   end
end
  
% plot now
style_setting = {'LineWidth', plotopt.linewidth};
if (plotopt.line == 0); style_setting = {style_setting{:}, 'LineStyle', ...
        'None'}; end
markerorder = {'s', 'o', '^', 'd', 'x', 'V', 'p', '<', '*', 'h', '+'};
markerorder = repmat(markerorder, 1, ceil(length(plotdata)/ ...
    length(markerorder)));
if strfind(pwd,'schowell')               
    colororder = [ ...
        0.21960784,  0.38039216,  0.54117647; ...  % blue
        0.85098039,  0.23921569,  0.24313725; ...  % red
        0.29411765,  0.42352941,  0.1372549 ; ...  % green
        0.39215686,  0.26666667,  0.45882353; ...  % violet
        0.89411765,  0.71372549,  0.18823529; ...  % yellow
        0.71764706,  0.36078431,  0.21960784; ...  % brown
        0.41960784,  0.67058824,  0.84313725; ...  % light blue
        0.81960784,  0.32941176,  0.68627451; ...  % light red
        0.69411765,  0.74901961,  0.22352941; ...  % light green
        0.49411765,  0.45490196,  0.81960784; ...  % light purple
        ];
else
    colororder = [ ...
        0         0    1.0; ...
        0    0.50         0; ...
        1.0         0         0; ...
        0.750         0    0.750; ...
        0    0.750    0.750; ...
        0.750    0.750         0; ...
        0         1         0; ...
        0.250    0       0.250; ...
        1.0       1.0     0.; ...
        ];
    colororder = repmat(colororder, ceil(length(plotdata)/length(colororder(:,1))),1);
end
for i=1:length(plotdata)
   
   if (plotopt.marker == 1)
      this_style = {style_setting{:}, 'Color', colororder(i,:), ...
                    'Marker', markerorder{i}, 'MarkerSize', ...
                    plotopt.markersize}; 
   else
      this_style = {style_setting{:}, 'Color', colororder(i,:)}; 
   end
   
   plotdata{i} = plotdata{i}(1:plotopt.istep:end,:);
   if (plotopt.errorbar == 1) && (length(plotdata{i}(1,:)) >= 3)
      errorbar(plotdata{i}(:,1), plotdata{i}(:,2), plotdata{i}(:,3), ...
               this_style{:});
   else
      plot(plotdata{i}(:,1), plotdata{i}(:,2), this_style{:});
   end
end
warning off;
if (plotopt.grid == 1)
   grid on;
else
   grid off;
end
if  ~isempty(plotlege)
   if (plotopt.legend == 1)
      legend(strrep(plotlege, '_', '\_'), 'FontSize', plotopt.legendfontsize);
      legend boxoff
   else
      legend off
   end
else
   showinfo('No data to plot!');
   return
end
if (isfield(xydata(1), 'guinier') && (xydata(1).guinier==1)) || ...
       (isfield(xydata(1), 'kratky') && (xydata(1).kratky==1)) || ...
       (isfield(xydata(1), 'porod') && (xydata(1).porod==1))
   showinfo('Logx or Logy settings are ignored for special plots!');
   set(gca, 'XScale', 'Linear', 'YScale', 'Linear');
else
   linearlog = {'linear', 'log'};
   set(gca, 'XScale', linearlog{plotopt.logx+1}, 'YScale', linearlog{plotopt.logy+1});
end
warning on;

return

if exist('plottext', 'var') && (plot_text ~= 0)
   xpos = [0.02, 0.02, 0.5, 0.5, 0.5];
   ypos = [0.98, 0.6,  0.98, 0.6, 0.6];
   puttext(xpos(plot_text), ypos(plot_text), strrep(plottext, '_', '\_'));
end

% MSA data plot
msa = {xydata.msa};
i=strmatch('msa-', plotdata);
if ~isempty(i)
   if iscell(plotdata)
      names = plotdata(i);
   else
      names = {plotdata};
   end
   for i=1:length(names)
      iplot = iplot + 1;
      plotdata{2*iplot-1} = [xydata(index).x];
      plotdata{2*iplot} = getfield_cellstru(msa, names{i}(5:end));
      plotlege{iplot} = names{i};
      label_x = 'x';
      label_y = names{i};
   end
end
