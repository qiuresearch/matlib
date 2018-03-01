function result = gnom_runcfg(config, cfgfile)
% --- Usage:
%        result = gnom_runcfg(config, cfgfile)
%
% --- Purpose:
%        run gnom using a config file
%        
% --- Parameter(s):
%        config
%        cfgfile
%        
% --- Return(s): 
%        result
%
% --- Example(s):
%         sgnom = [sgnom gnom_runcfg(gnomcfg)];
%
% $Id: gnom_runcfg.m,v 1.6 2014/07/17 02:11:14 schowell Exp $

if ~exist('cfgfile', 'var') || isempty(cfgfile)
   cfgfile = 'gnom_tmp.cfg';
end

gnom_savecfg(config, cfgfile);

if (config.ALPHA.value == 0)
   [status, res] = system(['gnom_run.sh ' cfgfile ''])
else
   [status, res] = system(['echo "\n \n" | gnom_run.sh ' cfgfile '']);
end

if status ~= 0
   disp(res)
end

result = gnom_loadout(config.OUTPUT.value);