function config = gnom_savecfg(config, cfgfile, varargin)
% --- Usage:
%        gnom_savecfg(config, cfgfile);
%
% --- Purpose:
%        save the values in config into the cfgfile
%        cfgfile is a gnom input file
%        
% --- Parameter(s):
%        config
%        cfgfile
%        
% --- Return(s): 
%
% --- Example(s):
%        gnom_savecfg(config, cfgfile);
%
% $Id: gnom_savecfg.m,v 1.3 2014/07/17 02:11:14 schowell Exp $

fid = fopen(cfgfile, 'W');

fprintf(fid, '%s\n', config.title);
names = fieldnames(config);
for i=2:length(names)
   outstr = sprintf('%-8s%1c [ ', config.(names{i}).name, ...
                    config.(names{i}).type);
   
   if isempty(config.(names{i}).value) && ~strcmpi('C',config.(names{i}).type) 
      outstr = [outstr blanks(16)];
   else
      switch config.(names{i}).type
         case 'R'
             %s changes this to save more digits, 2 was not enough
            outstr = [outstr sprintf('%-16.4g', config.(names{i}).value)];
         case 'I'
            outstr = [outstr sprintf('%-16d', config.(names{i}).value)];
         case 'C'
            outstr = [outstr sprintf('%-16s', config.(names{i}).value)];
         otherwise
            showinfo('unknown parameter type!!!', 'warning');
      end
   end
   
   outstr = [outstr ' ]' config.(names{i}).note];
   fprintf(fid, '%s\n', outstr);
end
fclose(fid);
