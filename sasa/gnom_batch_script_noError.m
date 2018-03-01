% --- Usage:
%        gnom_batch_script
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
%         gnom_batch_script
%
% $Id: gnom_batch_script.m,v 1.10 2014/07/09 15:36:18 schowell Exp $

sgnom = [];
minR = zeros(max(itodos),1);
maxR = zeros(max(itodos),1);
minQ = zeros(max(itodos),1);
maxQ = zeros(max(itodos),1);

if length(Rmax) > length(itodos) || length(Rmax) < length(itodos)
    if length(Rmax) == 1
        Rmax = ones(size(itodos)*Rmax);
    else
        display('ERROR!!! wrong number of Rmax values. Review input')
        return
    end
    
end

for i=itodos
   showinfo(sprintf('#%0i) processing file: %s', i, samnames{i}));
   
   % set up the structure
   
   gnomcfg.INPUT1.value = [samnames{i} '.gdat'];
   gnomcfg.OUTPUT.value = [samnames{i} '.out'];
   gnomcfg.RMAX.value = Rmax(i);
   
   % optimize dmax (needs improvement)
   if (flag_optimizeDmax == 1);
      dmax = gnom_optimizeDmax(gnomcfg);
      gnomcfg.RMAX.value = dmax;
   end
   
   % run gnom
   sgnom = [sgnom gnom_runcfg(gnomcfg)];
   [filedir, filename] = fileparts(samnames{i});
   sgnom(end).title = [sgnom(end).title '-' filename];
   
   if (flag_saveall == 1);
      gnom_saveiqpr(sgnom(end), filedir);
      saveascii(sgnom(end).pr,[sgnom(end).filedir '/' filename '_g.pr'])
   end
   sgnom(end).iq = sgnom(end).iq(~isnan(sgnom(end).iq(:,2)),:);
   minR(i) = min(sgnom(end).pr(:,1));
   maxR(i) = max(sgnom(end).pr(:,1));
   minQ(i) = min(sgnom(end).iq(:,1));
   maxQ(i) = max(sgnom(end).iq(:,1));
end

% plot and save
if (flag_plot == 1);
   figure_fullsize(); clf;
   gnom_plotfit_noError(sgnom, 'kratky_plot', 0)
   subplot(2,1,1);
   xlim([0.95*min(minQ), 1.05*max(maxQ)]);
   if (flag_saveall == 1);
      savefigps(gcf, [seriesname '_gnom']);
      saveps(gcf, ['gnom_tmp.eps']);
   end
end