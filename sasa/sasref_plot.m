function sasref_plot(samname, varargin)
% --- Usage:
%        sasref_plot(samname, lege)
%
% --- Purpose:
%
%
% --- Parameter(s):
%        samname
%
%
% --- Return(s):
%
%
% --- Example(s):
%
% $Id: sasref_plot.m,v 1.7 2014/05/13 00:59:09 schowell Exp $

if (nargin < 1)
   fprintf('nargin == %d\n',nargin)
   help sasref_plot
   return
end

match_range = [.035 .08];
samdir = './';
parse_varargin(varargin);

figure_format('normal'); 
figure; %figure_fullsize(); % this command makes unprofessional output
clf; haxes = axes_create(2, 2, 'xmargin', 0, 'ymargin', 0);

% I(Q) and its fit
axes(haxes(1)); set(gca, 'YScale', 'Log', 'XAxisLocation', 'Top');
fitdatafile = [samname, '-1.fit'];
[fitdata, descrip] = gnom_loaddata(fitdatafile);
if exist('data','var')
    fulldata = gnom_loaddata(data);
    qmax = fulldata(end,1);
    match_range = [fitdata(1,1) fitdata(end,1)];
else
    qmax = max(fitdata(:,1));
end
% calculate the I(Q) from the bestfit pdb
[~, pdbIqFile] = system(['ls -1 ' samname '*int']);
i = 0;
while ~exist(pdbIqFile,'file')
   pdbIqFiles = regexp(pdbIqFile, '[\f\n\r]', 'split');
   if length(pdbIqFiles)>1
      pdbIqFile = pdbIqFiles{1};
      fprintf('WARNING!!! Found multiple CRYSOL calculations......\n');
      fprintf(['using: ' pdbIqFile '\n']);
   end
   if ~exist(pdbIqFile,'file')
      fprintf(['could not find crysol calculation ' pdbIqFile]);
      fprintf('\ncalculating now........\n');
      system(['crysol -lm 50 -fb 18 -sm ' num2str(qmax) ' ' samname '.pdb']);
      [~, pdbIqFile] = system(['ls -1 ' samname '*int']);
   end
   fprintf(['iteration: ' num2str(i) '\n']);
   i=i+1;
end
if exist(pdbIqFile,'file');
   [pdbIq, ~] = gnom_loaddata(pdbIqFile);
else
   fprintf([pdbIqFile 'does not exist!\n']);
   pause
end

if exist('data','var')
    fulldata = gnom_loaddata(data);
    hline(1)=xyeplot(match(fulldata, fitdata, match_range, 'scale', 1, ...
        'offset', 0), 'Ylog', 1);    
    hline(2)=plot(fitdata(:,1), fitdata(:,4));
    hline(3)=xyplot(match(fitdata(:,[1,4]), fitdata(:,[1,2]), match_range, ...
        'offset', 1, 'scale', 0));
    [~, scale, ~] = match(pdbIq(pdbIq(pdbIq(:,1)<match_range(2),1)>match_range(1),:),fitdata(:,[1,4]));
    pdbIq(:,2) = pdbIq(:,2)*scale;
    hline(4)=xyplot(pdbIq)
    minfit = fitdata(1,1);
    maxfit = fitdata(end,1);    
    axis tight
    plot([minfit minfit], ylim, '-k');
    plot([maxfit maxfit], ylim, '-k');
else
    hline(1)=xyeplot(fitdata(:,1), fitdata(:,2), fitdata(:,3), 'Ylog', 1);
    hline(2)=plot(fitdata(:,1), fitdata(:,4));
    hline(3)=xyplot(match(fitdata(:,[1,4]), fitdata(:,[1,2]), match_range, ...
        'offset', 1, 'scale', 0));
    hline(4)=xyplot(match(pdbIq,fitdata(:,[1,4]),match_range, 'scale', 1, ...
        'offset', 0));
end
axis tight
xlim([0,inf]);
xylabel('iq');
legend(hline, {samname, 'sasref fit', 'offset fit', 'pdb I(Q)'}, 'Location', 'NorthEast');
legend boxoff

% Get .tga if not existing or too old
tgaimgfile = [samname '_3.tga'];
if ~exist(tgaimgfile, 'file') || file_newer(fitdatafile, tgaimgfile);
   % thisdir = fileparts(mfilename('fullpath'));
   tmpvmd = {'# vmd -e tmp.vmd', 'source ../sasref_plot.vmd', ...
             ['sasref_plot ' samname], 'exit'};
   tmpvmdfile = 'tmp.vmd';
   cellarr_saveascii(tmpvmd,  tmpvmdfile);
   
   system(['vmd -e ' tmpvmdfile]);
end

% Convert to png if not exiting or too old
pngfile = [samname '_3.png'];
if ~exist(pngfile, 'file') || file_newer(tgaimgfile, pngfile);
   showinfo('converting tga files to png files ...');
   for i=1:3
      tgaimgfile = num2str(i, [samname '_%1d.tga']);
      pngfile = num2str(i, [samname '_%1d.png']);
      system(['convert ' tgaimgfile ' ' pngfile]);
      %system(['\rm ' tgaimgfile]);
   end
end

% plot the three images
for i=1:3
   pngfile = num2str(i, [samname '_%1d.png']);
   axes(haxes(i+1)); set(gca, 'XTick', [], 'YTick', []);
   pngdata = imread(pngfile);
   tmpdata = sum(pngdata,3);
   [num_rows, num_cols] = size(tmpdata);
   irows = find(255*3*num_cols - sum(tmpdata,2));
   icols = find(255*3*num_rows - sum(tmpdata,1));
   pngdata = pngdata(irows(1):irows(end), icols(1):icols(end), :);
   image(pngdata);
   axis equal
   puttext(0.01, 0.05, num2str(i, 'View #%1d'));
   if i==1
      title(descrip);
   end
end
xlabel([strrep(samdir,'_','\_') samname]);

savepng(gcf, [samname '_fit.png']);
saveps(gcf, [samname '_fit.eps']);
