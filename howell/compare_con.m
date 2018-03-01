function datascales = compare_con(xydata, refdata, varargin)
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
% $Id: compare_con.m,v 1.2 2015/05/21 17:09:47 schowell Exp $
%

verbose = 1;
if nargin < 1
   funcname = msavename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
match_prefix = refdata.prefix;
match_data = refdata.data;
match_range = [];
match_offset = [];
savename = match_prefix;
istep = 1;
do_saveps = 1;
do_plot = 1;
parse_varargin(varargin);

% 1) initilize some variables
num_sams = length(xydata);
samconcens = reshape([xydata.concentration], 1, num_sams);
maxconcen = refdata.concentration;

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
[~, i_ref] = min(abs(1-datascales));
datascales = datascales(i_ref)./datascales*maxconcen;
datascales(samconcens <= 0.001) = 0.0001; % reset for the zerocon extrapolation

% 5) plot result
if do_plot
    figure_fullsize(); clf;
    subplot(211);
    plot_param = struct('istep', istep, 'markersize', 1, 'errorbar', 0, ...
        'line', 1, 'linewidth', 1, 'grid', 0);
    xypro_plot(xydata, 'plotopt', plot_param);
    % xyplot(xydata, 'plotopt', plot_param);
    xylabel('iq');
    title(['(a) I(Q) series and form factor ' num2str(match_offset, [ ...
        '(match_offset:%0d)'])], 'Interpreter', 'None');
    set(gca, 'XScale', 'Log', 'YScale', 'Log');
    legend('Location', 'SouthWest'); legend boxoff
    axis tight
    zoomout(.1)
    if ~isempty(match_range)
        vline(match_range, 'color', [.2 .2 .2], 'linestyle','--');
    end
    
    subplot(212); hold all;
    plot(samconcens, 's--');
    plot(datascales, 'o--');
    legend('expt. values', 'I(Q) scales');
    legend boxoff
    title(['Getting concentration using: ' match_prefix],'Interpreter','none');
    xlabel('Sample No.'); ylabel('Sample Concentration');
    
    if do_saveps;saveps(gcf, [savename '_normConc.eps']);end;
end
