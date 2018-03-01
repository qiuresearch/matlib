function specdata = crysol_cleanup(prefix, varargin)
% only keep the last .log and .int file

i = 0;
parse_varargin(varargin);

%
last_isa = 0; % whether this is the last file
while last_isa == 0
   if exist(sprintf('%s%02d.int', prefix, i+1), 'file')
      filenames = sprintf('%s%02d.*', prefix, i);
      showinfo(['Deleting ' filenames]);
      delete(filenames);
      i = i +1;
   else
      last_isa = 1;
      delete(sprintf('%s%02d.sav', prefix, i));
      delete(sprintf('%s%02d.flm', prefix, i));
      delete(sprintf('%s%02d.alm', prefix, i));
   end
end

% convert the crysol .int format into SPEC data format
intfile = sprintf('%s%02d.int', prefix, i);
if ~exist(intfile, 'file')
   specdata = [];
   return;
end

[iqdata, title] = gnom_loaddata(intfile);

specdata.title = title;
specdata.scannum = 1;
specdata.columnnames = {'Q', 'IQ', 'IQ_vacuum', 'IQ_solvent', 'IQ_borderlayer'};
specdata.data = iqdata;
specdata_savefile(specdata, [prefix '_crysol.iq']);

