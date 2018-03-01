% --- Usage:
%        datgnom_batch_script
%
% --- Purpose:
%        this script executes gnom for several files
%        
% --- Parameter(s):
%        itodos
%        samnames
%        seriesname
%        Rmax
%        xlimit (optional)
%        
% --- Return(s): 
%        N/A
%
% --- Example(s):
%         samnames = {'wtTEK010', 'wtTEK50', 'wtTEK100', 'wtTEK200', 'wtMg02', ...
%                     'wtMg10'};
%         samnames = strcat(strcat('ffdata/', samnames), '_ff');
%      
%         seriesname = 'wt';
%         Rmax = 420;
%         itodos = 1:length(samnames);
%      
%         datgnom_batch_script
%
% $Id: datgnom_batch_script.m,v 1.5 2014/07/09 15:36:18 schowell Exp $

sdgnom = [];
Rmin = zeros(max(itodos),1);
Rmax = zeros(max(itodos),1);
Qmin = zeros(max(itodos),1);
Qmax = zeros(max(itodos),1);
for i=itodos
   showinfo(sprintf('#%0i) processing file: %s', i, samnames{i}));
   
   % set up the structure
   inFile  = [samnames{i} '.gdat'];
   outFile = [samnames{i} '_dg.out'];
   rg = num2str(gdat{i,2});

   % run datgnom
   [~, out] = system(['datgnom ' inFile ' -o ' outFile ' -r ' rg]);
   
   sdgnom = [sdgnom gnom_loadout(outFile)];
   [filedir, filename] = fileparts(samnames{i});
   sdgnom(end).title = [sdgnom(end).title '-' filename];
   
   if (flag_saveall == 1);
      gnom_saveiqpr(sdgnom(end), filedir);
      saveascii(sdgnom(end).pr,[sdgnom(end).filedir '/' filename '_dg.pr'])
   end
   sdgnom(end).iq = sdgnom(end).iq(~isnan(sdgnom(end).iq(:,2)),:);
   Rmin(i) = min(sdgnom(end).pr(:,1));
   Rmax(i) = max(sdgnom(end).pr(:,1));
   Qmin(i) = min(sdgnom(end).iq(:,1));
   Qmax(i) = max(sdgnom(end).iq(:,1));
end

for i=itodos
   sdgnom(i).rmax = Rmax(i);
   sdgnom(i).rmin = Rmin(i);
   sdgnom(i).qmax = Qmax(i);
   sdgnom(i).qmin = Qmin(i);   
end

% plot and save
if (flag_plot == 1);
   figure_fullsize(); clf;
   gnom_plotfit(sdgnom, 'kratky_plot', 0)
   subplot(2,1,1);
   xlim([0.95*min(Qmin), 1.05*max(Qmax)]);
   if (flag_saveall == 1);
      ok = savefigps(gcf, [seriesname '_dgnom']);
      saveps(gcf, 'dgnom_tmp.eps');
   end
end

if exist('do_gnom','var') && do_gnom == 1
   display('running gnom using datgnom Dmax values')
   gnom_batch_script
end
