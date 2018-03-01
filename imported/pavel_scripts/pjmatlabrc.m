% my preferences, common for all machines
% set(0, 'DefaultAxesLineWidth', .25, 'DefaultAxesGridLineStyle', '-');
set(0, 'DefaultAxesGridLineStyle', '-');
set(0, 'DefaultAxesBox', 'on');
set(0, 'DefaultFigureMenuBar', 'none', 'DefaultFigureToolbar', 'figure');
% system_dependent RemoteCWDPolicy  TimecheckDirFile;
% set random seed
pjmrc_clock = clock; pjmrc_clock = sum(100*pjmrc_clock(4:6));
rand('state', pjmrc_clock);
clear pjmrc_*
