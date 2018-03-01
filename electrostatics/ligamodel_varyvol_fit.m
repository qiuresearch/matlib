function [ligaconcen, ligafit] = ligamodel_varyvol_fit(boundconcen, valence, ...
                                               freeconcen, volume, varargin)
% --- Usage:
%        [ligaconcen, ligafit] = ligamodel_fit(boundconcen, valence, ...
%                                              freeconcen, volume, varargin);
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%        var   - 
%
% --- Example(s):
%
% $Id: ligamodel_fit.m,v 1.4 2013/05/08 01:32:34 xqiu Exp $
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

% initialize and check for zero concentrations
ligafit.boundconcen = boundconcen; % [x, 1st ion, 2nd ion]
ligafit.valence = valence; % [1st ion, 2nd ion, ..]
ligafit.freeconcen = freeconcen; % [1st ion, 2nd ion, ...]
ligafit.volume = volume; % [volume_x]

inonzero = find((ligafit.boundconcen(:,1) > 0) & ...
                (ligafit.boundconcen(:,2) > 0) & ...
                (ligafit.freeconcen(:,1) > 0) & ...
                (ligafit.freeconcen(:,2) > 0));

ligafit.boundconcen = ligafit.boundconcen(inonzero,:);
ligafit.freeconcen  = ligafit.freeconcen(inonzero,:);
ligafit.volume  = ligafit.volume(inonzero,:);

% solve the equation to symbols
ligafit.equation = sprintf('x^%0i/(1-x)^%0i=b', ligafit.valence([2,1]));
ligafit.sol = solve(ligafit.equation, 'x');
ligafit.sol = ligafit.sol(1);

% Fit the "boundconcern" to obtain "b", which is a multiplicative of
% the term below:
b=ligafit.freeconcen(:,1).^ligafit.valence(2)./ ...
  ligafit.freeconcen(:,2).^ligafit.valence(1) ...
  .*ligafit.volume(:,1).^(ligafit.valence(2)-ligafit.valence(1));
% this correction is because the entropy is ln(n_ion), while the "x"
% here is n_ion*z_ion
%b=b*ligafit.valence(1)^ligafit.valence(2)/ ...
%  ligafit.valence(2)^ligafit.valence(1);
ligafit.b = b;
% Default is to fit first ion
y=ligafit.boundconcen(:,2).^ligafit.valence(2)./ ...
  (1-ligafit.boundconcen(:,2)).^ligafit.valence(1);
if (length(ligafit.boundconcen(1,:))>2)
   dy = (y./ligafit.boundconcen(:,2)*ligafit.valence(2) - ...
         y./(1-ligafit.boundconcen(:,2))*ligafit.valence(1)).* ...
        ligafit.boundconcen(:,3);
else
   dy = repmat(1, length(y), 1);
end

% solve/calculate the constant "a" to minimize ((y-a*b)./dy).^2
% the additive constant in paper equals 1/3*ln(a)
a = total(y.*b./dy.^2)/total(b.^2./dy.^2);
ligafit.multi_factor = a;
ligafit.multi_factor_note = ['This factor is multiplied to b=[Co]^2/[Mg]^3 ' ...
                    'term'];

% plug in and solve
b=a*freeconcen(:,1).^valence(2)./ freeconcen(:,2).^valence(1) ...
  .*volume(:,1).^(valence(2)-valence(1));;
x=eval(ligafit.sol);
x(isinf(b)==1) = 1.0;
x(isnan(x)==1) = 0;
ligaconcen = [boundconcen(:,1), x, 1-x];
ligafit.data = ligaconcen;

if (do_plot == 1)
   title(['Ion numbers: ' ligafit.title]);
   for i=1:num_ions
      hion(i) = plot(ligafit.data(:,1), ligafit.data(:,i+1), 's-');
   end
   axis tight
   xlabel(ligafit.xname);
   ylabel('Ion/P Charge Ratio');
   legend_add(hion, strcat(cellstr(repmat([ligafit.title '-'], ...
                                          num_ions,1))', ...
                           ligafit.ion(1:num_ions)));
   legend boxoff
end
