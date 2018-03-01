function config = gnom_readcfg(cfgfile, varargin)

verbose =1;
cellarr = cellarr_readascii(cfgfile);

config.title = cellarr{1};
for i=2:length(cellarr)
   tokens = strsplit(cellarr{i}, ' ');
   config.(tokens{1}).name = tokens{1};
   config.(tokens{1}).type = tokens{2};
   config.(tokens{1}).value = cellarr{i}(strfind(cellarr{i},'[')+1: ...
                                         strfind(cellarr{i},']')-1);
   config.(tokens{1}).note = cellarr{i}(strfind(cellarr{i},']')+1:end);
   
   switch config.(tokens{1}).type
      case 'R'
         config.(tokens{1}).value = str2num(config.(tokens{1}).value);
      case 'I'
         config.(tokens{1}).value = fix(str2num(config.(tokens{1}).value));
      case 'C'
         config.(tokens{1}).value = strtrim(config.(tokens{1}).value);
      otherwise
         showinfo('unknown parameter type!!!', 'warning');
   end
   
end
