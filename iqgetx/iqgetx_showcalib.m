function [hfig, sdata] = iqgetx_showcalib(sdata, varargin)
% --- Usage:
%        [hfig, sdata] = setup_quickplot(sdata, varargin)
%
% --- Purpose:
%
% --- Parameter(s):
%        sdata - a 2D array or a structure with .iq, .title or .label
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: iqgetx_showcalib.m,v 1.2 2016/10/26 15:21:56 xqiu Exp $
%

dspacing = 58.38;
newfigure = 1;
hidden = 0;
figure_format('smallprint');
parse_varargin(varargin);

scrsz = get(0,'ScreenSize');
varargin_figure = { 'PaperPosition', [0.25,2,8,7], 'defaultlinelinewidth', ...
                    0.5, 'defaultaxeslinewidth', 0.4, ...
                    'DefaultAxesFontSize', 10, 'DefaultLineMarkerSize', ...
                    10, 'DefaultTextFontSize', 10}; % 'position', [1 ...
                                                    %  1,scrsz(3), scrsz(4)]}; % [26,270,600,660]};
% warning off

if ~isstruct(sdata(1))
   sdata = struct('iq', sdata);
   sdata.title = strrep(inputname(1), '_', '-');
end

if ~exist('Spec_to_Phos', 'var')
    if exist('myMOA_startup','file')
        myMOA_startup;
    else
        MOA_startup;
    end
end

if (newfigure == 1)
   if (hidden == 1)
      hf=figure('visible', 'off', varargin_figure{:});
   else
      hf=figure(varargin_figure{:});
   end
else
   hf=gcf;
   clf(hf);
   position = get(hf, 'Position');
   varargin_figure{end} = position;
   set(hf, varargin_figure{:});
end
figure_size(hf, 'king');

% reset MOA variables to match sdata
tmp.X_cen=X_cen;
tmp.Y_cen=Y_cen;
tmp.X_Lambda=X_Lambda;
tmp.Spec_to_Phos=Spec_to_Phos;
X_cen=sdata.X_cen;
Y_cen=sdata.Y_cen;
X_Lambda=sdata.X_Lambda;
Spec_to_Phos=sdata.Spec_to_Phos;

% AgBeh 2-D data with fit
subplot(2,2,1);
agbehFile = [sdata.datadir,sdata.agbeh,sdata.suffix];
if 2 == exist(agbehFile,'file')
    agbeh2D = imread(agbehFile);
    MaskD = ones(size(agbeh2D));
    show(log(im2double(agbeh2D)));
    calibradius = Spec_to_Phos*tan(2*asin(sdata.X_Lambda/2/dspacing));
    plot(sdata.X_cen, sdata.Y_cen, 'w*');
    theta = linspace(0,2*pi, 300)';
    unit_ring = [cos(theta), sin(theta)];
    plot(sdata.X_cen+calibradius*unit_ring(:,1), sdata.Y_cen+calibradius*unit_ring(:,2), 'w.');
    title(['Center: ( ',num2str(sdata.X_cen),' , ',num2str(sdata.Y_cen),' )']);
else
    fprintf(['ERROR!!! could not find ',agbehFile,'\n']);
    return;
end
   
% AgBeh 1-D data
subplot(2,2,2);
switch sdata.dataformat
    case 'FLICAM'
        agbehData = slurp_flicam_1111gline(agbehFile);
        xyplot(agbehData.iq);
        set(gca,'yscale','log');
        %title(regexprep([sdata.agbeh,sdata.suffix],'_',' '));
        title('silver behenate calibrant scattering')
        xlabel('Q (\AA$^{-1}$)','interpreter','latex'); ylabel('I(Q)');
    otherwise
        fprintf([mfilename,' not yet setup for ',sdata.dataformat,' data\n']);
end

% mask on a buffer
subplot(2,2,3);
if 2 == exist(sdata.mask,'file')
    load(sdata.mask);
    MaskD=MaskI;
    bufFileName = [sdata.bufprefix,'_',num2str(sdata.buf1nums(1)),sdata.suffix];
    bufFile = [sdata.datadir,bufFileName];
    if 2 == exist(bufFile,'file')
        bufData = imread(bufFile);
        show(im2double(bufData));
%         show(log(im2double(bufData)));
        %title([bufFileName,' with mask ',sdata.mask]);
        title('Buffer scattering with mask');
    else
        fprintf(['ERROR!!! could not find ',bufFile,'\n']);
        return;
    end
else
    fprintf(['ERROR!!! Mask file: ',sdata.mask,' not found in current directory.\n'])
    fprintf('Please run from directory containing mask file.\n');
    return;
end

% mask on a buffer near beam stop
subplot(2,2,4);
show(im2double(bufData));
% show(log(im2double(bufData)));
win = 100;
axis([sdata.X_cen-win sdata.X_cen+win sdata.Y_cen-win sdata.Y_cen+win]); 
% title([bufFileName,' with mask ',sdata.mask]);
title('Buffer scattering with mask');

annotation('textbox', [0.05,0.84,0.1,0.1], 'String', '(a)', ...
           'FitBoxToText', 'on', 'EdgeColor', 'none');

annotation('textbox', [0.5,0.84,0.1,0.1], 'String', '(b)', 'FitBoxToText', 'on', 'EdgeColor', 'none');

annotation('textbox', [0.05,0.39,0.1,0.1], 'String', '(c)', 'FitBoxToText', 'on', 'EdgeColor', 'none');

annotation('textbox', [0.5,0.39,0.1,0.1], 'String', '(d)', ...
           'FitBoxToText', 'on', 'EdgeColor', 'none');

% reset MOA variables to original
X_cen=tmp.X_cen;
Y_cen=tmp.Y_cen;
X_Lambda=tmp.X_Lambda;
Spec_to_Phos=tmp.Spec_to_Phos;
