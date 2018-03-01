function [fullfilename, filename, filebase] = gwxray_getfilebynum(scannums, varargin);
   
   verbose = 1;
   datadir = '/home/gwdata/xray/2014a';
   suffix = '.iq';
   filename = [];
   
   parse_varargin(varargin);

   if ~strcmp(datadir(end), FILESEP)
      datadir = [datadir FILESEP];
   end
      
   if (numel(scannums) == 1)
      filenames = dir(fullfile(datadir, [sprintf('gw%04i_', scannums) '*' suffix]));
      if isempty(filenames);
         showinfo(['No file found in <' datadir '> with scan #;' ...
                   num2str(scannums)]); 
      end
      if (length(filenames) > 1); 
         showinfo(['Found more than one match, the first is used!']);
      end
      fullfilename = fullfile(datadir, filenames(1).name);
      filename = filenames(1).name;
      filebase = filename(1:end-length(suffix));
      showinfo(['Found file: ' fullfilename]);
   else
      allfiles = dir(fullfile(datadir, ['gw*' suffix]));
      allnames = {allfiles.name};
      allfullnames = strcat(datadir, allnames);

      num_files= length(scannums);
      fullfilename = cell(1,num_files);
      filename = cell(1,num_files);
      filebase = cell(1,num_files);
      for i=1:length(scannums)
          imatch = find(strncmp(sprintf('gw%04i_', scannums(i)), allnames, 7));
          fullfilename{i}=allfullnames{imatch(1)};
          filename{i} = allnames{imatch(1)};
          filebase{i} = filename{i}(1:end-length(suffix));
      end
   end
   
   return
   
   
