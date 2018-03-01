function result = dammin_runcfg(config, cfgfile)

if ~exist('cfgfile', 'var') || isempty(cfgfile)
   cfgfile = 'dammin_tmp.cfg';
end

dammin_savecfg(config, cfgfile);

system(['dammin51 < ' cfgfile]);

result = gnom_loaddata([config.Project_file_name.value '.fir']);
