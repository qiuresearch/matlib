function handle = sqfit_plot(sqfit, option, varargin)
%        handle = sqfit_plot(sqfit, option, varargin)
% --- Purpose:
%        plot the sqfit results
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
% $Id: sqfit_plot.m,v 1.2 2011-04-11 20:38:14 xqiu Exp $
%

% 1) check and setup
if (nargin < 1)
   help sqfit_plot
   return
end
if (nargin < 2)
   option = 'iq';
end

num_data = length(sqfit);
index = 1:num_data;
label_x = ['Q (' char(197) '^{-1})'];
label_y = 'I(Q)';
plot_legend = 1;
plot_text = 1;
line_style = '-';
parse_varargin(varargin);

% 2) plot the data
iplot = 0;
for iselect = 1:length(index)
  idata = index(iselect);
  
  if ~isempty(strmatch('iq_raw', option, 'exact'))  % plot I(Q) raw
    iplot = iplot + 1;
    plotdata{2*iplot-1} = sqfit(idata).iq_raw(:,1);
    plotdata{2*iplot} = sqfit(idata).iq_raw(:,2);
    plotlege{iplot} = ['raw I(Q) - '  sqfit(idata).legend];
  end

  if ~isempty(strmatch('iq', option, 'exact'))  % plot I(Q)
    iplot = iplot + 1;
    plotdata{2*iplot-1} = sqfit(idata).iq(:,1);
    plotdata{2*iplot} = sqfit(idata).iq(:,2);
    plotlege{iplot} = ['I(Q) - '  sqfit(idata).legend];
  end

  if ~isempty(strmatch('iq_cal', option, 'exact'))  % plot I(Q)
    iplot = iplot + 1;
    plotdata{2*iplot-1} = sqfit(idata).iq_cal(:,1);
    plotdata{2*iplot} = sqfit(idata).iq_cal(:,2);
    plotlege{iplot} = ['calc I(Q) - '  sqfit(idata).legend];
  end

  if ~isempty(strmatch('iq_fit', option, 'exact'))  % plot I(Q)
    iplot = iplot + 1;
    plotdata{2*iplot-1} = sqfit(idata).iq_fit(:,1);
    plotdata{2*iplot} = sqfit(idata).iq_fit(:,2);
    plotlege{iplot} = ['fit I(Q) - '  sqfit(idata).legend];
    iplot = iplot + 1;
    plotdata{2*iplot-1} = sqfit(idata).iq_dif(:,1);
    plotdata{2*iplot} = sqfit(idata).iq_dif(:,2);
    plotlege{iplot} = ['dif I(Q) - '  sqfit(idata).legend];
    iplot = iplot + 1;
    plotdata{2*iplot-1} = [sqfit(idata).iq(:,1); nan; sqfit(idata).iq(:,1)] ;
    plotdata{2*iplot} = [sqfit(idata).iq(:,4); nan; sqfit(idata).iq(:,4)];
    plotlege{iplot} = ['err I(Q) - '  sqfit(idata).legend];
  end

  if ~isempty(strmatch('sq', option, 'exact')) % plot S(Q) experimental
    iplot = iplot + 1;
    plotdata{2*iplot-1} = sqfit(idata).sq(:,1);
    plotdata{2*iplot} = sqfit(idata).sq(:,2);
    plotlege{iplot} = ['S(Q) - ' sqfit(idata).legend];
  end

  if ~isempty(strmatch('sq_all', option, 'exact')) % plot S(Q) experimental
    if length(sqfit(idata).sq_sol) > 2
      iplot = iplot + 1;
      plotdata{2*iplot-1} = sqfit(idata).sq_sol(:,1);
      plotdata{2*iplot} = sqfit(idata).sq_sol(:,2);
      plotlege{iplot} = ['sol S(Q) - ' sqfit(idata).legend];
    end
    
    if length(sqfit(idata).sq_vac) > 2
      iplot = iplot + 1;
      plotdata{2*iplot-1} = sqfit(idata).sq_vac(:,1);
      plotdata{2*iplot} = sqfit(idata).sq_vac(:,2);
      plotlege{iplot} = ['vac S(Q) - ' sqfit(idata).legend];
    end
    
    if length(sqfit(idata).sq_exp) > 2
      iplot = iplot + 1;      
      plotdata{2*iplot-1} = sqfit(idata).sq_exp(:,1);
      plotdata{2*iplot} = sqfit(idata).sq_exp(:,2);
      plotlege{iplot} = ['exp S(Q) - ' sqfit(idata).legend];
    end
    
    if length(sqfit(idata).sq_inp) > 2
       iplot = iplot + 1;
       plotdata{2*iplot-1} = sqfit(idata).sq_inp(:,1);
       plotdata{2*iplot} = sqfit(idata).sq_inp(:,2);
       plotlege{iplot} = ['inp S(Q) - ' sqfit(idata).legend];
    end

    if length(sqfit(idata).sq_cyl) > 2
       iplot = iplot + 1;
       plotdata{2*iplot-1} = sqfit(idata).sq_cyl(:,1);
       plotdata{2*iplot} = sqfit(idata).sq_cyl(:,2);
       plotlege{iplot} = ['cyl S(Q) - ' sqfit(idata).legend];
    end

  end
  
  if ~isempty(strmatch('ff', option, 'exact')) % plot ff (used)
     iplot = iplot + 1;
     switch sqfit(idata).ff_use
     case 1
        plotdata{2*iplot-1} = sqfit(idata).ff_sol(:,1);
        plotdata{2*iplot} = sqfit(idata).ff_sol(:,2);
        case 2
           plotdata{2*iplot-1} = sqfit(idata).ff_vac(:,1);
           plotdata{2*iplot} = sqfit(idata).ff_vac(:,2);
        case 3
           plotdata{2*iplot-1} = sqfit(idata).ff_exp(:,1);
           plotdata{2*iplot} = sqfit(idata).ff_exp(:,2);
        case 4
           plotdata{2*iplot-1} = sqfit(idata).ff_inp(:,1);
           plotdata{2*iplot} = sqfit(idata).ff_inp(:,2);
        case 5
           plotdata{2*iplot-1} = sqfit(idata).ff_cyl(:,1);
           plotdata{2*iplot} = sqfit(idata).ff_cyl(:,2);
        otherwise
           warning('the field "ff_use" is not set right!')
     end
     
     plotlege{iplot} = ['ff - ' sqfit(idata).legend];
  end
  
  if ~isempty(strmatch('ff_all', option)) % plot ff (all)
     
     if length(sqfit(idata).ff_sol) > 3
        iplot = iplot + 1;
        plotdata{2*iplot-1} = sqfit(idata).ff_sol(:,1);
        plotdata{2*iplot} = sqfit(idata).ff_sol(:,2);
        plotlege{iplot} = ['sol ff - ' sqfit(idata).legend];
     end
     
     if length(sqfit(idata).ff_vac) > 3
        iplot = iplot + 1;
        plotdata{2*iplot-1} = sqfit(idata).ff_vac(:,1);
        plotdata{2*iplot} = sqfit(idata).ff_vac(:,2);
        plotlege{iplot} = ['vac ff - ' sqfit(idata).legend];
     end
     
     if length(sqfit(idata).ff_exp) > 3
        iplot = iplot + 1;      
        plotdata{2*iplot-1} = sqfit(idata).ff_exp(:,1);
        plotdata{2*iplot} = sqfit(idata).ff_exp(:,2);
        plotlege{iplot} = ['exp ff - ' sqfit(idata).legend];
     end
    
     if length(sqfit(idata).ff_inp) > 3
        iplot = iplot + 1;
        plotdata{2*iplot-1} = sqfit(idata).ff_inp(:,1);
        plotdata{2*iplot} = sqfit(idata).ff_inp(:,2);
        plotlege{iplot} = ['inp ff - ' sqfit(idata).legend];
     end

     if length(sqfit(idata).ff_cyl) > 3
        iplot = iplot + 1;
        plotdata{2*iplot-1} = sqfit(idata).ff_cyl(:,1);
        plotdata{2*iplot} = sqfit(idata).ff_cyl(:,2);
        plotlege{iplot} = ['cyl ff - ' sqfit(idata).legend];
     end

  end
  
  if ~isempty(strmatch('sq_fit', option)) % plot S(Q) MSA model
     iplot = iplot + 1;
     plotdata{2*iplot-1} = sqfit(idata).sq_fit(:,1);
     plotdata{2*iplot} = sqfit(idata).sq_fit(:,2);
     plotlege{iplot} = ['fit S(Q) - ' sqfit(idata).legend];
     iplot = iplot + 1;
     plotdata{2*iplot-1} = sqfit(idata).sq_dif(:,1);
     plotdata{2*iplot} = sqfit(idata).sq_dif(:,2) + sqfit(idata).sq_fit(1,2);
     plotlege{iplot} = ['dif S(Q) - ' sqfit(idata).legend];
  end
  
  if ~isempty(strmatch('sq_cal', option)) % plot S(Q) MSA model
     iplot = iplot + 1;
     plotdata{2*iplot-1} = sqfit(idata).sq_cal(:,1);
     plotdata{2*iplot} = sqfit(idata).sq_cal(:,2);
     plotlege{iplot} = ['cal S(Q) - ' sqfit(idata).legend];
  end
  
  if  ~isempty(strmatch('sq_fit', option)) ||  ~isempty(strmatch('sq_cal', ...
                                                       option))  || ...
         ~isempty(strmatch('iq_cal', option))  ||  ~ ...
         isempty(strmatch('iq_fit', option))
     plottext = {'MSA model:', sprintf('Charge=%5.2f, Diameter=%5.1f', ...
                                       sqfit(idata).msa.z_m, ...
                                       sqfit(idata).msa.sigma), ...
                 sprintf('Concen.=%0.2fmM, IS=%0.2fmM', sqfit(idata).msa.n, ...
                         sqfit(idata).msa.I)};
  end
end

% I(Q) parameter plot
if ~isempty(strmatch('offset_iq', option))
   iplot = iplot + 1;
   plotdata{2*iplot-1} = [sqfit(index).x];
   plotdata{2*iplot} = [sqfit(index).offset_iq];
   plotlege{iplot} = ['I(Q) offset'];
   label_x = 'x';
   label_y = 'I(Q) offset';
end
if ~isempty(strmatch('scale_iq', option))
   iplot = iplot + 1;
   plotdata{2*iplot-1} = [sqfit(index).x];
   plotdata{2*iplot} = [sqfit(index).scale_iq];
   plotlege{iplot} = ['I(Q) scale'];
   label_x = 'x';
   label_y = 'I(Q) scale';
end
if ~isempty(strmatch('radius_cyl', option))
   iplot = iplot + 1;
   plotdata{2*iplot-1} = [sqfit(index).x];
   plotdata{2*iplot} = [sqfit(index).radius_cyl];
   plotlege{iplot} = ['cylinder radius'];
   label_x = 'x';
   label_y = 'cylinder radius';
end
if ~isempty(strmatch('height_cyl', option))
   iplot = iplot + 1;
   plotdata{2*iplot-1} = [sqfit(index).x];
   plotdata{2*iplot} = [sqfit(index).height_cyl];
   plotlege{iplot} = ['cylinder height'];
   label_x = 'x';
   label_y = 'cylinder height';
end
if ~isempty(strmatch('diameter_equiv', option))
   iplot = iplot + 1;
   plotdata{2*iplot-1} = [sqfit(index).x];
   plotdata{2*iplot} = [sqfit(index).diameter_equiv];
   plotlege{iplot} = ['cylinder diameter'];
   label_x = 'x';
   label_y = 'diameter height';
end


% MSA data plot
msa = {sqfit.msa};
i=strmatch('msa-', option);
if ~isempty(i)
   if iscell(option)
      names = option(i);
   else
      names = {option};
   end
   for i=1:length(names)
      iplot = iplot + 1;
      plotdata{2*iplot-1} = [sqfit(index).x];
      plotdata{2*iplot} = getfield_cellstru(msa, names{i}(5:end));
      plotlege{iplot} = names{i};
      label_x = 'x';
      label_y = names{i};
   end
end

% plot now
if exist('plotdata')
   plot(plotdata{:}, line_style)
   if (plot_legend == 1)
      legend(strrep(plotlege, '_', '\_')); 
      legend boxoff
   end
   xlabel(strrep(label_x, '_', '\_'));   ylabel(strrep(label_y, '_', '\_'));
   if exist('plottext') && (plot_text ~= 0)
      xpos = [0.02, 0.02, 0.5, 0.5, 0.5];
      ypos = [0.98, 0.6,  0.98, 0.6, 0.6];
      puttext(xpos(plot_text), ypos(plot_text), strrep(plottext, '_', '\_'));
   end
end
