function ffdata = iqcorr_zeroCon(xydata, varargin)
% --- Usage:
%        xydata =  xypro_sasff(xydata, varargin)
% --- Purpose:
%        correct the inter-particle interference effect through
%        linear extrapolation of a concentration series
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: iqcorr_zeroCon.m,v 1.11 2016/10/26 15:21:56 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = msavename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
compare_methods = 0;
match_data = [];
match_range = [];
match_offset = [];
savename = 'noname';
do_saveps = 1;

% default plot options
axisfontsize = 10;
grid = 1;
add_legend = 1;
legendfontsize = 10;
ploterr = 0;
marker = 1;
markersize = 1; 
line = 1;
linewidth = 1;
logx = 1;
logy = 1;
istep = 1;


parse_varargin(varargin);

% 1) initilize some variables
num_sams = length(xydata);
samconcens = reshape([xydata.concentration], 1, num_sams);
[maxconcen, imax] = max(samconcens);

if isempty(match_data)
   match_data = xydata(imax).data;
   showinfo(['No match_data passed, use the most concentrated sample: ' ...
             'No. ' num2str(imax)]);
end

[xydata.match] = deal(1);
[xydata.match_scale] = deal(1);
[xydata.match_data] = deal(match_data);

if ~isempty(match_range);
   [xydata.match_range] = deal(match_range);
end
if ~isempty(match_offset);
   [xydata.match_offset] = deal(match_offset);
end

% 2) scale the data and analyze

xydata = xypro_dataprep(xydata);
datascales = [xydata.scale_match];
datascales = min(datascales)./datascales*maxconcen;

[datascales, isort] = sort(datascales, 2, 'descend');
xydata = xydata(isort);
samconcens = samconcens(isort);

% 3) construct the matrixes and then solve the linear least square
% equation: for each i (Q in this case), a(i)*x(:) + b(i) = y(i,:), 
% where, : refers to the data series (e.g., concentration,
%          temperature etc). 

% initialize arrays
shape = [length(xydata(1).data),length(xydata)];
x = repmat(samconcens, [shape(1), 1]);
y = zeros(shape);
e = zeros(shape);
% n = 
for k=1:length(xydata)
    y(:,k) = xydata(k).data(:,2);    % I(Q,c)
    e(:,k) = xydata(k).data(:,4);    % Er_I(Q,c)

%     % Remove bad data (by making the error enormous)
%     if k>1
%         i_qmin = locate(xydata(k).data(:,1),xydata(k).guinier_range(1))-1;
%         e(1:i_qmin,k) = e(1:i_qmin,k)*100;
%     end
end
if compare_methods == 1
    figure; hold all;
    logxy
    for k=1:length(xydata)
        errorbar(xydata(1).data(:,1), y(:,k), e(:,k))
        if k == 1; xy_range = axis();  end
    end
    axis(xy_range);
end

% following https://www.che.udel.edu/pdf/FittingData.pdf
% This produces reasonable error 
% For our case, 
%      x(:) = [samconcen]  
%      y(Q,c_i) = [I(Q,c_i)/dI(Q,c_i)^2]     

%%%%%%%%%%%%%%%%%% Modular Code %%%%%%%%%%%%%%%%%%%%
x_e2 = sum(x./e.^2,2);
y_e2 = sum(y./e.^2,2);
xy_e2 = sum(x.*y./e.^2,2);
inv_e2 = sum(e.^-2,2);
x2_e2 = sum(x.^2./e.^2,2);

a_num = x_e2 .* y_e2 - xy_e2 .* inv_e2;
a_den = x_e2.^2 - x2_e2 .* inv_e2;
a = a_num ./ a_den;
b = (xy_e2 -a .* x2_e2) ./ x_e2;
ae = sqrt(-inv_e2 ./ a_den);
be = sqrt(-x2_e2 ./ a_den);

% 4) collect the result
ffdata = xydata(1);
ffdata.concentration = 0;
ffdata.data(:,2) = b;
ffdata.data(:,4) = be;
%%%%%%%%%%%%%%%%%% Modular Code %%%%%%%%%%%%%%%%%%%%

% % old algorithm, did not give proper error values but same I(Q) 
% % 3) construct the matrixes and then solve the linear least square
% % equation: for each i (Q in this case), a(i)*x(:) + b(i) = y(i,:), 
% % where, : refers to the dats series (e.g., concentration,
% %          temperature etc). 
% 
% % For our case, i=Q
% %               a(Q) = 2*M*A2(Q)/P(Q)
% %               b(Q) = 1/P(Q)
% %               x(:) = [samconcen]
% %               y(i,:) = 1/[I(Q,c)] here I(Q,c) is I(Q,c)/c
% 
x_j1 = reshape(datascales, numel(datascales), 1);
y_ij = y;
dy_ij = e;
y_ij = 1./y_ij;
dy_ij = dy_ij.*y_ij.^2;

% the code below can/should be modular

inv_dy2_ij = 1./dy_ij.^2;
inv_dy2_i1 = sum(inv_dy2_ij,2);
inv_dy2_x_i1 = inv_dy2_ij*x_j1;
inv_dy2_x2_i1 = inv_dy2_ij*(x_j1.^2);

a_i1 = ((y_ij.*inv_dy2_ij*x_j1).*inv_dy2_i1 - ...
        inv_dy2_x_i1.*sum(y_ij.*inv_dy2_ij,2))./ ...
       (inv_dy2_x2_i1.*inv_dy2_i1 -inv_dy2_x_i1.^2);

% da_i1 = sqrt(((dy_ij.*inv_dy2_ij*x_j1).*inv_dy2_i1).^2 + ...
%              (inv_dy2_x_i1.*sum(dy_ij.*inv_dy2_ij,2)).^2)./ ...
%         (inv_dy2_x2_i1.*inv_dy2_i1 -inv_dy2_x_i1.^2);
% 
if compare_methods == 1
    errorbar(xydata(1).data(:,1), ffdata.data(:,2), ffdata.data(:,4), 'linewidth',2);

    b_i1 = ((y_ij.*inv_dy2_ij*x_j1)-inv_dy2_x2_i1.*a_i1)./inv_dy2_x_i1;
    
    db_i1 = (dy_ij.*inv_dy2_ij*x_j1)./inv_dy2_x_i1;
    errorbar(xydata(1).data(:,1), 1./b_i1, db_i1./(b_i1.^2), 'linewidth', 2);
    leg_entries = {xydata.title, 'new', 'old'};
    legend(leg_entries)
    legend boxoff
end
% %a_i1 = ((iq_ij.*inv_diq2_ij*c_j1).*sum(inv_diq2_ij,2) - ...
% %        (inv_diq2_ij*c_j1).*sum(iq_ij.*inv_diq2_ij,2))./ ...
% %       ((inv_diq2_ij*c_j1.^2).*sum(inv_diq2_ij,2) - (inv_diq2_ij*c_j1).^2);
% %b_i1 = ((iq_ij.*inv_diq2_ij*c_j1)-(inv_diq2_ij*c_j1.^2).*a_i1)./ ...
% %       (inv_diq2_ij*c_j1);
% 
% % 4) collect the result
% ffdata = xydata(1);
% ffdata.concentration = 0;
% ffdata.data(:,2) = 1./b_i1;
% ffdata.data(:,4) = db_i1./(b_i1.^2);

if xydata(1).data(:,3) == xydata(1).data(:,4)
    ffdata.data(:,3) = ffdata.data(:,4); % to keep 3 column data consistent
end
if ~isempty(match_range);
    % perform a weighted average to smoothly transition from low to high Q
    imin = locate(ffdata.data(:,1), match_range(1));
    imax = locate(ffdata.data(:,1), match_range(2));
    n = imax - imin + 1;
    weight = linspace(0,1,n)';
    ffdata.data(imin:imax,2) = ...
        xydata(1).data(imin:imax,2).*weight + ...
        ffdata.data(imin:imax,2).*(1-weight);
    ffdata.data(imin:imax,3) = ...
        sqrt(xydata(1).data(imin:imax,3).^2 .* weight.^2 + ...
        ffdata.data(imin:imax,3).^2 .* (1-weight).^2);
    ffdata.data(imin:imax,4) = ffdata.data(imin:imax,3);
    ffdata.data(imax:end,:) = xydata(1).data(imax:end,:);
end

ffdata.title = [savename ' - ff_zeroCon'];
ffdata.columnnames = ffdata.columnnames(1:4);
ffdata.filename = [savename '_zeroCon.iq'];
ffdata.prefix = [ffdata.filename(1:end-3)];
specdata_savefile(ffdata, [ffdata.datadir ffdata.filename]);

% rearrange the order for improved visibility when plotting
[~, isort] = sort(datascales, 2, 'ascend');
xydata = xydata(isort);
samconcens = samconcens(isort);
datascales = datascales(isort);

% 5) plot result
figure_size(figure, 'king'); clf;
height = 8;
width = 8;
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperSize', [width height]);
set(gcf, 'PaperPosition', [0 0 width height]); % last 2 are width/height.
set(gcf, 'renderer', 'painters');

% set the plot options
plotopt_default = struct('axisfontsize', axisfontsize, 'grid', grid, ...
    'legend', add_legend, 'legendfontsize', legendfontsize, 'errorbar', ploterr, ... 
    'marker', marker, 'markersize', markersize, 'line', line, 'linewidth', linewidth, ...
    'logx', logx, 'logy', logy, 'istep', istep);
if exist('q_min','var')
    i_min = locate(xydata(1).data(:,1), q_min);
    for i=1:length(xydata)
        xydata(i).data = xydata(i).data(i_min:end, :);
    end
    % i_min = locate(ffdata.data(:,1), q_min);
    ffdata.data = ffdata.data(i_min:end, :);
else
    q_min = ffdata.data(1, 1);
    i_min = 1;
end

% main plot
subplot(3,2,1:4);
plotopt = plotopt_default;
plotopt.legend = 0;
xypro_plot([xydata, ffdata], 'plotopt', plotopt);
xylabel('iq');
h = get(gca, 'xlabel');
set(h, 'Units', 'Normalized');
pos = get(h, 'position') + [0 0.03 0];
set(h, 'position', pos);
set(gca,'yticklabel',[])
axis tight
zoomout(.1)
yrange = ylim;
i_match = locate(xydata(isort(1)).data(:,1), 0.15);
yrange(1) = mean(xydata(isort(1)).data(i_match:end,2))*.3;
yrange(2) = yrange(2) * 2;
ylim(yrange);
% add verticle lines showing the match region
if ~isempty(match_range)
    vline(match_range, 'color', [.5 .5 .5], 'linestyle','--'); 
end
sub_position = get(gca, 'position'); % for the inset
% add label
if exist('plt_title', 'var')
    sub_label = ['(a) ' plt_title];
else
    sub_label = '(a)';
end    
% text(0.02, 0.06, sub_label, 'units', 'normalized');
text(0.02, 0.96, sub_label, 'units', 'normalized');
      

% concentration plot
subplot(3,2,5); hold all;
plot(samconcens, 's--');
plot(datascales, 'o--');
ymin = min([samconcens, datascales]) * .8;
ymax = max([samconcens, datascales]) * 1.3;
ylim([ymin ymax]);
xlim([0.9 length(samconcens)+.1])
legend('Exp values', 'I(Q) scales', 'location', 'North');
% legend('Exp values ^.', 'I(Q) scales', 'location', 'NorthEast'); 
legend boxoff
xlabel('Sample Number'); 
ylabel('Concentration [mg/mL]');
text(0.03, 0.9, '(b)', 'units', 'normalized');

% 2nd viral coefficient plot
subplot(3,2,6);
%errorbar(ffdata.data(:,1), -a_i1, da_i1);
plot(ffdata.data(:,1), a_i1(i_min:end).*ffdata.data(:,2), '.');
axis tight;      
set(xlabel('Q (\AA\textsuperscript{-1})', 'Interpreter', 'Latex'), ...
    'FontName', 'Arial');
set(ylabel('Apparent 2^{nd} virial'), 'FontName', 'Arial');
ylim([-3,3]);
text(0.03, 0.9, '(c)', 'units', 'normalized');

% create the legend
plot_data = [xydata, ffdata];
for i=1:length(plot_data)
    leg_entries{i} = [num2str(plot_data(i).concentration, '%0.2f') ' mg/mL'];
end
leg_entries{1} = [leg_entries{1} ' ^.'];
subplot(3,2,1:4)
legend(leg_entries, 'Location', 'NorthEast'); 
legend boxoff

% create inset of the low Q region
sub_position =  (sub_position + [0.05 0.05 0 0]) .* [1  1 0.45 0.45];
axes('Position', sub_position)
box on
q_max = 0.015;
plot_data = [xydata, ffdata];
for i=1:length(plot_data)
    plot_data(i).data = plot_data(i).data(plot_data(i).data(:,1) < q_max ,:);
end
plotopt = plotopt_default;
plotopt.legend = 0;
xypro_plot(plot_data, 'plotopt', plotopt);
ax = gca;
set(ax,'YTickLabel',[])
q_ticks = 0.001 * (0:2:10) + floor(q_min*1000)/1000;
if (q_ticks(4) - 0.0095) < 0.001
    % q_ticks(4);
    q_ticks(4:end) = q_ticks(4:end) + 0.001;
end
set(ax,'XTick', q_ticks([1:4,6]))
axis tight
zoomout(.1)
xlimit = [q_ticks(1), q_max];
xlim(xlimit)
% legend(leg_entries, 'Location', 'SouthWest'); legend boxoff

if do_saveps;saveps(gcf, [savename '_zeroCon.eps']);end;