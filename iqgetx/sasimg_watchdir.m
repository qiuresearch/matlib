function sas_new = sasimg_loadnewfile(sas, watchdir, varargin);

verbose = 1;
if ~isempty(sas)
   suffix = sas(1).suffix;
else
   suffix = '';
end
parse_varargin(varargin);

if isempty(sas)
   showinfo(['A pre-existing image must have been loaded first!!!']);
   sas = sasimg_init();
end

loadedfiles = strcat({sas.prefix}, {sas.suffix});
currentfiles = dir([watchdir '*' suffix]);
currentfiles(find([currentfiles.isdir] ==1)) = [];
currentfiles = currentfiles(sort([currentfiles.datenum]));

currentfiles = {currentfiles.name};
[commonfiles, icommon] = intersect(currentfiles, loadedfiles);

%[newfiles, inew] = setdiff({currentfiles.name}, loadedfiles);

if icommon == length(currentfiles)
   showinfo(['No new files in ' watchdir]);
   sas_new = [];
   return
else
   newfiles = currentfiles(icommon+1:end);
end

sas_new = sasimg_init(strcat(repmat({watchdir}, 1, length(inew)), ...
                             newfiles), 'copystru', sas(end));
[sas_new.select] = deal(1);
