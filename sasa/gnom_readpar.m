function sPar = gnom_readpar(parfile, varargin)

verbose =1;
cellarr = cellarr_readascii(parfile);

names = strsplit(cellarr{1}, ' ');

for i=2:length(cellarr)
   tokens = strsplit(cellarr{i}, ' ');
   for k=2:length(names)
      sPar.(names{k}).(tokens{1}) = str2num(tokens{k});
   end
end
