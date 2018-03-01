function sPar = gnom_savepar(sPar, parfile, varargin)
% save the EXPERT parameter file for GNOM

fid = fopen(parfile, 'W');

names = fieldnames(sPar);
fprintf(fid, '%s\n', strjoin({'Parameter', names{:}}, '    '));

tokens = fieldnames(sPar.(names{1}));
for i=1:length(tokens)
   outstr = sprintf(' %-8s', tokens{i});
   for k=1:length(names)
      outstr = [outstr, sprintf('%10.3f', sPar.(names{k}).(tokens{i}))];
   end
   fprintf(fid, '%s\n', outstr);
end
fclose(fid);
