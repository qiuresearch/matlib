function config = dammin_savecfg(config, cfgfile, varargin)

fid = fopen(cfgfile, 'W');

names = fieldnames(config);
for i=1:length(names)
   switch config.(names{i}).type
      case 'N' % numeric
         outstr = sprintf('%-16.2g', config.(names{i}).value);
      case 'C' % string
         outstr = sprintf('%-16s', config.(names{i}).value);
      otherwise
         showinfo('unknown parameter type!!!', 'warning');
   end

   if (i ~= 4) % no note for the title row
      outstr = [outstr '!! ' config.(names{i}).note];
   end
   fprintf(fid, '%s\n', outstr);
end
fclose(fid);
