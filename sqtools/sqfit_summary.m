function handle = sqfit_summary(sqfit, varargin)
%        handle = sqfit_plot(sqfit, varargin)
% --- Purpose:
%        plot the sqfit results
%
% --- Parameter(s):
%        varargin - 'xdata'
%
% --- Return(s): 
%        results - 
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: sqfit_summary.m,v 1.4 2013/04/11 01:29:07 xqiu Exp $
%


% 1) check and setup
if (nargin < 1)
   help sqfit_plot
   return
end

verbose = 1;

num_data = length(sqfit);
index = 1:num_data;
xdata = 'n';
x_label = 'x';
parse_varargin(varargin);

% find out the x axis
msa = [sqfit.msa];
if strcmpi(xdata, 'n');
   xdata = [msa.n];
   x_label='concentration (mM)';
end
if strcmpi(xdata, 'I');
   xdata = [msa.I];
   x_label='ionic strength (mM)';
end
[xdata, iorder] = sort(xdata);
sqfit = sqfit(iorder);
msa = msa(iorder);

% 2) plot the data
symbol = {'s', 'o', '<', '>', 'd', '^'};
istep = ceil(length(sqfit(1).iq(:,1))/50);
match_range = [0.08,0.13];
xlimit = [0,max([sqfit.q_max])];

clf; figure_fullsize(gcf);
figure_paperpos(gcf, 'queesize'); figure_format('tiny');

% I(Q) and fit
subplot(3,2,1, 'yscale', 'log'), hold all
for i = 1:length(sqfit)
   [dummy, sam_names{i}, dummy] = fileparts(sqfit(i).fname);
   sam_names{i} = [sam_names{i} sprintf('(chi2=%0.1f)',sqfit(i).chi2)];
   data = sqfit(i).iq;
   hdata(i)=plot(data(1:istep:end,1), data(1:istep:end,2), ...
                 symbol{mod(i-1,length(symbol))+1});
   data = sqfit(i).iq_cal;
   set(plot(data(:,1), data(:,2), 'k'), 'color', get(hdata(i), 'color'));
end
iqlabel; xlim(xlimit); ylim([0,inf])
legend(hdata, sam_names, 'Location', 'SouthWest', 'interpreter', 'none'); legend boxoff;

% S(Q)
subplot(3,2,3), hold all
for i = 1:length(sqfit)
   [dummy, sam_names{i}, dummy] = fileparts(sqfit(i).fname);
   sam_names{i} = [sprintf('n=%0.2fmM I1=%0.1f I2=%0.1f', sqfit(i).msa.n, ...
                           sqfit(i).msa.I, sqfit(i).msa.I2)];
   data = sqfit(i).sq_cal;
   hdata(i)=plot(data(:,1), data(:,2));
end
sqlabel, axis tight; zoomout(0.08);
legend(hdata, sam_names, 'interpreter', 'none', 'Location', 'SouthEast'); legend boxoff

% U(r)
subplot(3,2,5), hold all
for i = 1:length(sqfit)
   [dummy, sam_names{i}, dummy] = fileparts(sqfit(i).fname);
   data = sqfit(i).ur_cal;
   idiameter = locate(data(:,1), sqfit(i).msa.sigma);
   data(1:idiameter,2) = data(idiameter,2);
   hdata(i)=plot(data(:,1), data(:,2));
   
   sam_names{i} = sprintf('D=%0.1fA U0=%0.2f', sqfit(i).msa.sigma, data(idiameter,2));
end
urlabel, axis tight; zoomout(0.08);
legend(hdata, sam_names, 'interpreter', 'none', 'Location', 'SouthEast'); legend boxoff

% Results

% scale
subplot(3,2,2), hold all;
plot(xdata, [msa.n], 's');
plot(xdata, [sqfit.scale_iq]/sqfit(end).scale_iq*msa(end).n, 'o');
axis tight; zoomout(0.08);
legend({'concentration (mM)', 'fitted scale (normalized)'}, 'location', 'NorthWest');
legend boxoff
xlabel(x_label); ylabel('scale');

% effective charge
subplot(3,2,4), hold all
z_m = [msa.z_m];
z_m2= [msa.z_m2];
z_min = min(z_m); z_max = max(z_m);

scale_factor = roundsig(z_max/max(z_m2),2);

%errorbar(xdata, z_m, [msa.z_m_delta],'s--')
%errorbar(xdata, z_m2*scale_factor, [msa.z_m2_delta]*scale_factor, 'o-.')
%ylim([min([z_min, min(z_m2*scale_factor)]),z_max]+(z_max-z_min)*[-0.1,0.1]);

[ax, h1, h2] = plotyy(xdata, z_m, xdata, z_m2);
set(h1, 'Marker', 's', 'LineStyle', '-');
set(h2, 'Marker', 'o', 'LineStyle', '--');
xlabel(x_label); ylabel('Zeff (e)');
axis tight; zoomout(0.08), ytick(ax(1), 5);
axes(ax(2)); % axis tight; zoomout(0.08); ytick(ax(2), 5);
set(get(ax(2), 'Ylabel'), 'String', 'Zattr (e)');
legend('repulsive charge', 'attractive charge');
legend boxoff

% virial coefficient
subplot(3,2,6); hold all
virial = [sqfit.virial];
A2 = reshape([virial.A2],3,length(virial))';
%[ax, h1, h2] = plotyy(xdata, A2(:,2), xdata, A2(:,3));
%set(h1, 'Marker', 's', 'LineStyle', '-');
%set(h2, 'Marker', 'o', 'LineStyle', '--');
h1 = plot(xdata, A2(:,2), 's-');
%h2 = plot(xdata, A2(:,3), 'o--');
h3 = plot(xdata, A2(:,1), 'r<-');

legend([h1,h3], virial(1).legend([2,1]), 'interpreter', 'none', ...
       'Location', 'NorthWest'); legend boxoff
xlabel(x_label), ylabel(['A2 (' virial(1).A2_unit, ')']);
axis tight; zoomout(0.08);
%axes(ax(1)); legend boxoff; ytick(ax(1), 5);
%axes(ax(2)); ylabel('U(r) integration');
saveps(gcf, 'sqfit_summary.eps');
