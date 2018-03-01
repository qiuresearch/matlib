function [iq, specdata] = crysol_runcfg(cfg, varargin)
% run crysol based on the structure "cfg", which can be a file
% name. In this case, all default values are used.
%
%   varargin
%       cfgfile - the file name to be saved
%       <any field name>, see crysol_readcfg()
%            

verbose = 1;
cleanup = 0;
cfgfile = 'crysol_tmp.cfg'; % default cfg file name
parse_varargin(varargin);

% if cfg is a PDB file name, instead of a config structure
if ischar(cfg) && exist(cfg, 'file');
   cfg_tmp = crysol_readcfg();
   cfg_tmp.PDB_file.value = cfg;
   cfg = cfg_tmp;
end

% any fieldname of the cfg can be modified via varargin
par_names = fieldnames(cfg);
for i=1:length(par_names)
   if exist(par_names{i}, 'var') && isfield(cfg, parnames{i})
      cfg.(par_names{i}).value = eval(par_names{i});
   end
end

% save cfg and run it
time_start = clock;
showinfo(sprintf('Running crysol on <%s> with cfg: <%s>', ...
                 cfg.PDB_file.value, cfgfile));
crysol_savecfg(cfg, cfgfile);
system(['crysol < ' cfgfile ' >/dev/null']);
calctime = etime(clock, time_start);
showinfo(sprintf('total elapsed time: %8.0fs', calctime));

% get the saved file name
[dummy, prefix, dummy] =  fileparts(cfg.PDB_file.value);

% only read the last intensity file
file_list = dir([prefix '*.int']);
showinfo(sprintf('Reading intensity results from <%s>', file_list(end).name));
[iq, title] = gnom_loaddata(file_list(end).name);

% 
specdata.title = title;
specdata.columnnames = {'Q', 'IQ', 'IQ_vacuum', 'IQ_solvent', 'IQ_borderlayer'};
specdata.calctime = calctime;
specdata.time = datestr(now);
specdata.data = iq;

if (cleanup == 1);
   crysol_cleanup(prefix);
end

return

% Set the hydration shell to zero and re-run
showinfo(sprintf(['Running crysol with no hydration shell on <%s> ' ...
                  'with cfg: <%s>'], cfg.PDB_file.value, cfgfile));
cfg.contrast_solvation.value = 0.0;
crysol_savecfg(cfg, cfgfile);
system(['crysol < ' cfgfile ' >/dev/null']);

file_list = dir([prefix '*.int']);
showinfo(sprintf('Reading intensity results from <%s>', file_list(end).name));
[iq, title] = gnom_loaddata(file_list(end).name);
