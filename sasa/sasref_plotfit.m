function hf = sasref_plotfit(fitfile, varargin)
% --- Usage:
%        hf = sasref_plotfit(fitfile, varargin)
%
% --- Purpose:
%        plot the sasref fit together with the experimental curve
%
% --- Parameter(s):
%        fitfile  -  sasref fitfile
%
%
% --- Return(s):
%        hf  -  figure handle
%
%
% --- Example(s):
%
% $Id: sasref_plotfit.m,v 1.2 2014/02/27 14:16:17 schowell Exp $

if (nargin < 1)
   fprintf('nargin == %d\n',nargin)
   help sasref_plotfit
   return
end

new_figure = 1;
parse_varargin(varargin);

[data, descrip] = gnom_loaddata(fitfile);
if (new_figure == 1)
   figure
else
   clf
end

hold all
hf = xyeplot(data(:,1), data(:,2), data(:,3), 'Ylog', 1);
plot(data(:,1), data(:,4));
set(gca, 'YScale', 'Log');
iqlabel
title(fitfile, 'Interpreter', 'None');
legend({descrip}, 'Interpreter', 'None');
legend boxoff
axis tight
zoomout(.1)
