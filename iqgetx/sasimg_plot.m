function handle = sasimg_plot(sas, dataselect, plotopt, varargin)
%        handle = sasimg_plot(sas, dataselect, plotopt, varargin)
% --- Purpose:
%        plot the xydata
%
% --- Parameter(s):
%
% --- Return(s): 
%        results - 
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: sasimg_plot.m,v 1.7 2014/05/01 19:50:56 xqiu Exp $
%
verbose = 1;
imaxes = [];
zoomaxes = [];
iqaxes = [];
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
if isnumeric(sas); % if an image is passed
   sas = sasimg_init(sas);
end
if ~exist('dataselect', 'var') || isempty(dataselect)
   dataselect = {};
end
if ~exist('plotopt', 'var') || isempty(plotopt)
   plotopt = sas(1).plotopt;
else
   plotopt = struct_assign(plotopt, sas(1).plotopt, 'append');
end
parse_varargin(varargin);

if isempty(sas(1).im); showinfo('No image'); return; end

% 2) plot the data
axes(imaxes);
if ~isempty(strmatch('im', dataselect, 'exact')) || (plotopt.im == 1)
   % remove old objects and keep the limits
   children = get(imaxes, 'Children');
   if (numel(children) >= 1) && (plotopt.locklim == 1);
      xlimit = get(imaxes, 'XLIM');
      ylimit = get(imaxes, 'YLIM');
   else
      axis equal
      xlimit = [0,sas(1).im_size(1)];
      ylimit = [0,sas(1).im_size(2)];
   end
   if ~isempty(children); delete(children); end

   % only the last image is shown as of now!
   im = sas(end).im;
   title(sas(end).title, 'Interpreter', 'None');
   if (plotopt.MaskI == 1);
      im = im .* double(sas(1).MaskI);
   end
%   if (plotopt.MaskD == 1);
%      im = im .* double(sas(1).MaskD);
%   end
   
   colormap(plotopt.colormap);
   if (plotopt.logscale == 1);
      imagesc(log10(double(im)),log10(double([plotopt.min, plotopt.max])));
   else
      imagesc(im, [plotopt.min, plotopt.max]);
   end
   if (plotopt.colorbar == 1)
      %      colorbar('EastOutside');
   end
end

if ~isempty(strmatch('calibring', dataselect, 'exact')) || ...
       (plotopt.calibring == 1)
   plot(sas(1).X_cen, sas(1).Y_cen, 'w*', 'MarkerSize', 10);
   theta = linspace(0,2*pi,300);
   for i=1:plotopt.calibring_num
      calibradius = sas(1).Spec_to_Phos*tan(2*asin(sas(1).X_Lambda/2/sas(1).calib_dspacing*i));
      plot(sas(1).X_cen+calibradius*cos(theta), sas(1).Y_cen+calibradius*sin(theta), ...
           'w--');
   end
end

% plot xydata list
if ~isempty(sas(1).calib_ringxy) && (~isempty(strmatch('calib_ringxy', ...
         dataselect, 'exact')) || (plotopt.calib_ringxy == 1))
   plot(sas(1).calib_ringxy(:,1), sas(1).calib_ringxy(:,2), 'w+', ...
        'MarkerSize', 10);
end
if ~isempty(sas(1).mask_polygonxy) && (plotopt.mask_polygonxy == 1)
   plot([sas(1).mask_polygonxy(:,1);sas(1).mask_polygonxy(1,1)], ...
        [sas(1).mask_polygonxy(:,2);sas(1).mask_polygonxy(1,2)], 'w+--', ...
        'MarkerSize', 10);
end

if exist('xlimit', 'var'); xlim(xlimit); ylim(ylimit); end

% need to update the zoom axes
if ~isempty(strmatch('zoom', dataselect, 'exact')) || (plotopt.zoom == 1)
   cla(zoomaxes);
   hplots = get(imaxes, 'Children');
   hplots = copyobj(hplots, zoomaxes);
   if isempty(plotopt.mousexy)
      plotopt.mousexy=[sas(1).X_cen, sas(1).Y_cen];
   end
   % use current mousexy position, color limit as current setting
   set(zoomaxes, 'xlim', plotopt.mousexy(1) + [-0.5*plotopt.zoomsize, ...
                       0.5*plotopt.zoomsize], 'ylim', plotopt.mousexy(2)+ ...
                 [-0.5*plotopt.zoomsize, 0.5*plotopt.zoomsize], ...
                 'clim', [plotopt.min, plotopt.max]);
   %   axis equal
end

if (plotopt.iq == 1) && ~isempty(sas(1).iq)
   axes(iqaxes);
   children = get(iqaxes, 'Children');
   if (numel(children) > 1) && (plotopt.locklim == 1);
      xlimit = get(iqaxes, 'XLIM');
      ylimit = get(iqaxes, 'YLIM');
   else
      xlimit = [-Inf, Inf];
      ylimit = [-Inf, Inf];
   end
   cla reset; hold all
   ascale = {'linear', 'log'};
   set(iqaxes, 'XScale', ascale{plotopt.iq_logx+1}, 'YScale', ...
               ascale{plotopt.iq_logy+1});
   for i=1:length(sas)
      if plotopt.iq_qiq
         sas(i).iq(:,2) = sas(i).iq(:,2).*(sas(i).iq(:,1).^plotopt.iq_qiqpower);
      end
      if plotopt.iq_match
         xyplot(match(sas(i).iq, [0.1,0.1], ...
                      plotopt.iq_matchrange, 'scale', ...
                      plotopt.iq_matchscale, 'offset', ...
                      plotopt.iq_matchoffset));
      else
         xyplot(sas(i).iq);
      end
   end
   xlim(xlimit); ylim(ylimit);
   legend({sas(:).title}, 'Interpreter', 'None', 'Location', 'NorthEast');
   legend boxoff
end
