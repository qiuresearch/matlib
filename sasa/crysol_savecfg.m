function config = crysol_savecfg(config, cfgfile, varargin)

fid = fopen(cfgfile, 'W');

names = fieldnames(config);
for i=1:length(names)
   switch config.(names{i}).type
      case 'R' % numeric
         outstr = sprintf('%-23.4g', config.(names{i}).value);
      case 'I' % numeric
         outstr = sprintf('%-23d', config.(names{i}).value);
      case 'C' % string
         outstr = sprintf('%-23s', config.(names{i}).value);
      otherwise
         showinfo('unknown parameter type!!!', 'warning');
   end

   outstr = [outstr '    !! ' config.(names{i}).note];
   fprintf(fid, '%s\n', outstr);
end
fclose(fid);
