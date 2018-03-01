function [ligamod, sol] = ligamodel_calc(ligamod, varargin)
% --- Usage:
%        [ligamod, sol] = ligamodel_calc(ligamod, varargin)
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
% $Id: ligamodel_calc.m,v 1.2 2012/09/04 21:02:35 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

do_plot = 0;
do_init = 0;
parse_varargin(varargin);

if ~exist('ligamod', 'var') || isempty(ligamod)
   ligamod.title = 'ligamodel';
   ligamod.x = logspace(2,3,3)';
   ligamod.xname = 'Ion-concentration-(mM)';
   ligamod.ion = {'Mg', 'Na+', 'Cl-'};
   ligamod.valence = [2, 1,-1]; % Na, Cl
   ligamod.ionconcen = [repmat(10,length(ligamod.x),1), ligamod.x, ...
                       20+ligamod.x];
end

if (do_init == 1)
   sol = [];
   return
end

num_ions = length(ligamod.ion)-1; % coion is not of interest here

% solve the equation to symbols
ligamod.equation = sprintf('x^%0i/(1-x)^%0i=b', ligamod.valence([2,1]));
ligamod.sol = solve(ligamod.equation, 'x');
ligamod.sol = ligamod.sol(1);

% plug in the "b", and evaluate. 
% "b" has a somewhat arbitrary scale due to different entropy forms
b=ligamod.ionconcen(:,1).^ligamod.valence(2)./ ...
  ligamod.ionconcen(:,2).^ligamod.valence(1);
% this correction is because the entropy is ln(n_ion), while the "x"
% here is n_ion*z_ion
b=b*ligamod.valence(1)^ligamod.valence(2)/ ...
  ligamod.valence(2)^ligamod.valence(1);

x=eval(ligamod.sol);
x(isnan(x)==1) = 1.0;
% data to save
ionnames = strcat(ligamod.ion(1:num_ions), cellstr(repmat('-total',num_ions,1))');
ligamod.columnnames = {ligamod.xname, ionnames{:}};
ligamod.data = [ligamod.x, x, 1-x];

if (do_plot == 1)
   title(['Ion numbers: ' ligamod.title]);
   for i=1:num_ions
      hion(i) = plot(ligamod.data(:,1), ligamod.data(:,i+1), 's-');
   end
   axis tight
   xlabel(ligamod.xname);
   ylabel('Ion/P Charge Ratio');
   legend_add(hion, strcat(cellstr(repmat([ligamod.title '-'], ...
                                          num_ions,1))', ...
                           ligamod.ion(1:num_ions)));
   legend boxoff
end
