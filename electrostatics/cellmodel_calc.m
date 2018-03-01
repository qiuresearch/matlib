function [cellmod, sol] = cellmodel_calc(cellmod, varargin)
% --- Usage:
%        [cellmod, sol] = cellmodel_calc(cellmod, varargin)
%
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%        var   - 
%
% --- Example(s):
%
% $Id: cellmodel_calc.m,v 1.7 2015/06/09 19:12:52 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

do_plot = 0;
do_init = 0;
RelTol = 3e-4;
parse_varargin(varargin);

if ~exist('cellmod', 'var') || isempty(cellmod)
   cellmod.title = 'Cell model demo';
   cellmod.x = logspace(2,3,3)';
   cellmod.xname = 'Ion-concentration-(mM)';
   cellmod.lambda = -2/3.4; % linear charge density
   cellmod.radius = 10;     % cylinder radius
   cellmod.R = 20;
   cellmod.ion = {'Na+', 'Cl-'};
   cellmod.valence = [1,-1]; % Na, Cl
   cellmod.ionconcen = [cellmod.x, cellmod.x];
   cellmod.num_points = 200000;
end

if (do_init == 1)
   sol = [];
   return
end

if ~isfield(cellmod, 'num_points');
   cellmod.num_points = 6666;
end

for i=1:length(cellmod.x)
   num_ions = length(cellmod.ion);
   showinfo(['Solve NLPB cylinderical model for ' ...
             strjoin(strcat(cellmod.ion, cellstr(strsplit(num2str(cellmod.ionconcen(min(i,end),:), ' :%0.2fmM')))), ', ')]);
   inozero = find(cellmod.ionconcen(min(i,end),:) > 0);
   for i2=0:30
      try
         R = cellmod.R(min(i,end))*(1+i2);
         disp(sprintf('Radius: %0.2f, RelTol: %0.2g', R, RelTol));
         sol_tmp = nlpbsolve_cylinder2('lambda', cellmod.lambda(min(i,end)), ...
                                       'radius', cellmod.radius(min(i,end)), ...
                                       'R', R, 'concen', cellmod.ionconcen(min(i,end),inozero), ...
                                       'valence', cellmod .valence(min(i,end),inozero), ...
                                       'num_points', cellmod.num_points, ...
                                       'RelTol', RelTol);
         if (i == 1)
            sol(i) = sol_tmp;
         else
            sol(i) = struct_assign(sol_tmp, sol(i-1), 'append', 0);
         end
      catch
         showinfo(['Cylindrical cell model solver error, small R? ' ...
                   'too few or too many points?']);
      end
      if exist('sol', 'var') && (length(sol) == i)
         break;
      else
         showinfo(['Try lowering the tolerance (x2) automatically...']);
         RelTol = RelTol*2;
      end
   end
   num_total(inozero) = sol(i).num_total;
   sol(i).num_total = num_total;
   cellmod.data(i,:) = [cellmod.x(i), sol(i).osmopressure, sol(i).Z_eff, ...
                       sol(i).kappa_PB, sol(i).phir, sol(i).phiR, ...
                       sol(i).num_total, total(sol(i).num_total.* ...
                                               cellmod.valence(min(i,end),:))];
end
ionnames = strcat(cellmod.ion, cellstr(repmat('-total',num_ions,1))');
cellmod.columnnames = {str2varname(cellmod.xname), 'osmopressure', 'Z-eff', ...
                    'kappa-PB', 'phi-r', 'phi-R', ionnames{:}, 'charge_total'};

if (do_plot == 1)
   % pressure result
   subplot(1,2,1); hold all;
   title(['Osmotic pressure: ' cellmod.title]);
   hmodel=plot(cellmod.data(:,1), cellmod.data(:,2), 's-');
   legend_add(hmodel,[cellmod.title '-cell model']); legend boxoff
   xlabel(cellmod.xname);
   ylabel('log(\Pi) (dynes/cm^2)');
   axis tight
   
   % ion number results
   subplot(1,2,2); hold all;
   title(['Ion numbers: ' cellmod.title]);
   for i=1:length(cellmod.ion)
      hion(i) = plot(cellmod.data(:,1), cellmod.data(:,i+6), 's-');
   end
   axis tight
   xlabel(cellmod.xname);
   ylabel('Ion/P Charge Ratio');
   legend_add(hion, strcat(cellstr(repmat([cellmod.title '-'], ...
                                          length(cellmod.ion),1))', ...
                           cellmod.ion));
   legend boxoff
end
