function [handle, plotdata] = apbs_plot(sAPBS, option, varargin)
%        [handle, plotdata] = apbs_plot(sqfit, option, varargin)
% --- Purpose:
%    plot the APBS results
%
% --- Parameter(s):
%     
%
% --- Return(s): 
%        results - 
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: apbs_plot.m,v 1.2 2013/02/28 16:52:10 schowell Exp $
%

% 1) check and setup
if (nargin < 1)
   help apbs_plot
   return
end
if (nargin < 2)
   option = 'pot_r';
end

num_data = length(sAPBS);
index = 1:num_data;
label_x = ['r (' char(197) ')'];
label_y = '(KT)';
x_axis = 1;
parse_varargin(varargin);

% 2) plot the data
iplot = 0;
for iselect = 1:length(index)
  idata = index(iselect);
  
  if ~isempty(strmatch('pot_r', option, 'exact')) % potential VS r
    iplot = iplot + 1;
    plotdata{2*iplot-1} = sAPBS(idata).analysis.pot_r(:,1);
    plotdata{2*iplot} = sAPBS(idata).analysis.pot_r(:,2);
    plotlege{iplot} = ['potential VS r - '  sAPBS(idata).name];
  end

  if ~isempty(strmatch('iondens_r', option, 'exact'))  % number of ions
     for iion=1:length(sAPBS(idata).ion)
        iplot = iplot + 1;
        plotdata{2*iplot-1} = sAPBS(idata).analysis.iondens_r(:,1);
        plotdata{2*iplot} = sAPBS(idata).analysis.iondens_r(:,iion+1);
        plotlege{iplot} = ['number of ' sAPBS(idata).ion(iion).name ...
                           ' - ' sAPBS(idata).name];
        label_x = 'distance from center';
        label_y = 'ion number density';
     end
  end

  if ~isempty(strmatch('chargedens_r', option, 'exact'))  % number of ions
     iplot = iplot + 1;
     plotdata{2*iplot-1} = sAPBS(idata).analysis.iondens_r(:,1);
     plotdata{2*iplot} = sAPBS(idata).analysis.iondens_r(:,end);
     plotlege{iplot} = ['net charge density - ' sAPBS(idata).name];
     label_x = 'distance from center';
     label_y = 'net charge density';
  end

  if ~isempty(strmatch('ionnum_ecutoff', option, 'exact'))  % number of ions
     for iion=1:length(sAPBS(idata).ion)
        iplot = iplot + 1;
        plotdata{2*iplot-1} = sAPBS(idata).analysis.ionnum_ecutoff(:,1);
        plotdata{2*iplot} = sAPBS(idata).analysis.ionnum_ecutoff(:,iion+1);
        plotlege{iplot} = ['number of ' sAPBS(idata).ion(iion).name ...
                           ' - ' sAPBS(idata).name];
        label_x = 'energy threshold (KT)';
        label_y = 'ion number';
     end
  end

  if ~isempty(strmatch('chargenum_ecutoff', option, 'exact')) % total ion charge
     label_x = 'energy threshold (KT)';
     label_y = 'net charge';
     iplot = iplot + 1;
     plotdata{2*iplot-1} = sAPBS(idata).analysis.ionnum_ecutoff(:,1);
     plotdata{2*iplot} = sAPBS(idata).analysis.ionnum_ecutoff(:,end);
     plotlege{iplot} = ['net ion charge - '  sAPBS(idata).name];
  end

  if ~isempty(strmatch('ionnum_rcutoff', option, 'exact'))  % number of ions
     for iion=1:length(sAPBS(idata).ion)
        iplot = iplot + 1;
        plotdata{2*iplot-1} = sAPBS(idata).analysis.ionnum_rcutoff(:,1);
        plotdata{2*iplot} = sAPBS(idata).analysis.ionnum_rcutoff(:,iion+1);
        plotlege{iplot} = ['number of ' sAPBS(idata).ion(iion).name ...
                           ' - ' sAPBS(idata).name];
        label_x = 'distance from center';
        label_y = 'ion number';
     end
  end

  if ~isempty(strmatch('chargenum_rcutoff', option, 'exact')) % total ion charge
     label_x = 'distance from center';
     label_y = 'net charge';
     iplot = iplot + 1;
     plotdata{2*iplot-1} = sAPBS(idata).analysis.ionnum_rcutoff(:,1);
     plotdata{2*iplot} = sAPBS(idata).analysis.ionnum_rcutoff(:,end);
     plotlege{iplot} = ['net ion charge - '  sAPBS(idata).name];
  end
  
  if ~isempty(strmatch('radius_pot', option))
     iplot = iplot + 1;
     plotdata{2*iplot-1} = sAPBS(idata).geom.potcutoff; 
     plotdata{2*iplot} = sAPBS(idata).geom.radius_pot;
     plotlege{iplot} = ['radius vs potcutoff - ' sAPBS(idata).name];
     label_x = 'x';
     label_y = 'radius';
  end

  if ~isempty(strmatch('height_pot', option))
     iplot = iplot + 1;
     plotdata{2*iplot-1} = sAPBS(idata).geom.potcutoff; 
     plotdata{2*iplot} = sAPBS(idata).geom.height_pot;
     plotlege{iplot} = ['height vs potcutoff - ' sAPBS(idata).name];
     label_x = 'x';
     label_y = 'height';
  end

  if ~isempty(strmatch('diameter_pot', option))
     iplot = iplot + 1;
     plotdata{2*iplot-1} = sAPBS(idata).geom.potcutoff; 
     plotdata{2*iplot} = sAPBS(idata).geom.diameter_pot;
     plotlege{iplot} = ['diameter vs potcutoff - ' sAPBS(idata).name];
     label_x = 'x';
     label_y = 'diameter';
  end
end

% geometry data plot if not data found yet
if ~exist('plotdata', 'var')
   if isfield(sAPBS(1), 'geom')
      x = index;
      geom = [sAPBS(index).geom];
      if isfield(geom(1), option)
         iplot = iplot + 1;
         plotdata{2*iplot-1} = x;
         plotdata{2*iplot} = [geom.(option)];
         plotlege{iplot} = [option];
         label_x = 'x';
         label_y = option;
      end
   end
end

% plot now
if exist('plotdata')
   plot(plotdata{:})
   legend(plotlege);   xlabel(label_x);   ylabel(label_y);
   if exist('plottext')
     puttext(0.02,0.98, plottext);
   end
   
end
