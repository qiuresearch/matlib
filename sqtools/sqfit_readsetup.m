function sqfit = sqfit_readsetup(setupfile, varargin)
% varargin
%     'readiq' - 1 or 0

if (nargin < 1)
   error('One setup file should be provided')
   return
end
readiq = 1;
verbose = 1;
parse_varargin(varargin)

% 2) read the file
runit = fopen(setupfile, 'r');
setupdata = fread(runit);
fclose(runit);

setupdata = strtrim(strsplit(char(setupdata'), sprintf('\n')));
setupdata(strmatch('%', setupdata)) = '';
setupdata = setupdata(~strcmp(setupdata, ''));
setupdata = strrep(setupdata, sprintf('\t'), ' ');

% 3) parse the setup

sqfit_tmp = sqfit_init();
      
entry_isa=0;
i_entry = 0;
num_lines = length(setupdata);
for i_line = 1:num_lines
  
   % handle the assignments before the file name entries
   if (entry_isa == 0)
      if ~isempty(strmatch('#L', setupdata{i_line}))
         entry_isa = 1;
         continue
      end
      tokens = strsplit(setupdata{i_line}, '=');
      if (length(tokens) > 1) && iscell(tokens)
         switch strtrim(tokens{1})
            case 'molweight'
               sqfit_tmp.molweight = str2num(tokens{2});
            case 'smooth_width'
               sqfit_tmp.smooth_width = str2num(tokens{2});
            case 'smooth_degree'
               sqfit_tmp.smooth_degree = str2num(tokens{2});
            case 'q_min'
               sqfit_tmp.q_min = str2num(tokens{2});
            case 'q_max'
               sqfit_tmp.q_max = str2num(tokens{2});
            case 'hqratio'
               sqfit_tmp.hqratio = str2num(tokens{2});
            case 'hqmethod'
               sqfit_tmp.hqmethod = str2num(tokens{2});
            case 'ff_sol'
               sqfit_tmp.fname_ff_sol = strtrim(tokens{2});
               if (readiq ~= 0); 
                  sqfit_tmp.ff_sol = loadxy(tokens{2}); 
                  disp(['Solution form factor file: ' tokens{2} ' loaded.'])
               end
            case 'ff_vac'
               sqfit_tmp.fname_ff_vac = strtrim(tokens{2});
               if (readiq ~= 0);
                  sqfit_tmp.ff_vac = loadxy(tokens{2});
                  disp(['Vaccum form factor file: ' tokens{2} ' loaded.'])
               end
            case 'ff_exp'
               sqfit_tmp.fname_ff_exp = strtrim(tokens{2});
               if (readiq ~= 0);
                  sqfit_tmp.ff_exp = loadxy(tokens{2});
                  disp(['Experimental form factor file: ' tokens{2} ' loaded.'])
               end
            case 'ff_inp'
               sqfit_tmp.fname_ff_inp = strtrim(tokens{2});
               if (readiq ~= 0);
                  sqfit_tmp.ff_inp = loadxy(tokens{2});
                  disp(['Inp form factor file: ' tokens{2} ' loaded.'])
               end
            case 'ff_cyl'
               sqfit_tmp.fname_ff_cyl = strtrim(tokens{2});
               if (readiq ~= 0);
                  sqfit_tmp.ff_cyl = loadxy(tokens{2});
                  disp(['Cylindrical form factor file: ' tokens{2} ' loaded.'])
               end
            case 'ff_use'
               sqfit_tmp.ff_use = str2num(tokens{2});
            case 'radius_cyl'
               sqfit_tmp.radius_cyl = str2num(tokens{2});
            case 'height_cyl'
               sqfit_tmp.height_cyl = str2num(tokens{2});
            case 'msamethod'
               sqfit_tmp.msa.method = str2num(tokens{2});
            otherwise
               disp(['WARNING:: unknown line --> ' setupdata{i_line}])
         end  
      end
   end
   
   % one line is a data set
   if (entry_isa == 1)
      tokens = strsplit(setupdata{i_line}, ' ');
      if (length(tokens) >= 9 ) 
         i_entry = i_entry + 1;
         
         sqfit_tmp.num = i_entry;
         sqfit_tmp.x = str2num(tokens{1});
         sqfit_tmp.fname = tokens{2};
         [dummy, sqfit_tmp.legend] = fileparts(tokens{2});
         sqfit_tmp.legend = [sqfit_tmp.legend, ' (x=',tokens{1}, ...
                             ')'];
         sqfit_tmp.legend = strrep(sqfit_tmp.legend, '_', '-');
         disp(['Data #' int2str(i_entry) ': ' sqfit_tmp.legend])

         if (readiq ~= 0)
            sqfit_tmp.iq_raw = load('-ascii', tokens{2});
            disp(['   I(Q) data: ' tokens{2} ' loaded.'])
         end
         [sqfit_tmp.msa.z_m, sqfit_tmp.msa.sigma, ...
          sqfit_tmp.msa.n, sqfit_tmp.msa.scale] = ...
             deal(str2num(tokens{3}), str2num(tokens{4}), ...
                  str2num(tokens{5}), str2num(tokens{6}));
         [sqfit_tmp.msa.T, sqfit_tmp.msa.I, ...
          sqfit_tmp.msa.epsilon, ] = deal(str2num(tokens{7}), ...
                                               str2num(tokens{8}), ...
                                               str2num(tokens{9}));
         if (length(tokens) >=  21)
            [sqfit_tmp.q_min, sqfit_tmp.q_max, ...
             sqfit_tmp.auto_rescale, sqfit_tmp.ff_use, ...
             sqfit_tmp.hqratio, sqfit_tmp.hqmethod] = ...
                deal(str2num(tokens{10}), str2num(tokens{11}), ...
                     str2num(tokens{12}), str2num(tokens{13}), ...
                     str2num(tokens{14}), str2num(tokens{15}));
            [sqfit_tmp.offset_iq, sqfit_tmp.scale_iq, ...
             sqfit_tmp.radius_cyl, sqfit_tmp.height_cyl, ...
             sqfit_tmp.diameter_equiv, ...
             sqfit_tmp.use_diameter_equiv] = deal(str2num(tokens{16}), ...
                                                       str2num(tokens{17}), ...
                                                       str2num(tokens{18}), ...
                                                       str2num(tokens{19}), ...
                                                       str2num(tokens{20}), ...
                                                       str2num(tokens{21}));
         end
         if (length(tokens) == 22) % each data has its own form factor
            if (readiq ~= 0)
               sqfit_tmp.ff_inp = load('-ascii', tokens{22});
            end
            sqfit_tmp.fname_ff_inp = tokens{22};
         end
         if (length(tokens) > 22)  % Two Yukawa settings
            sqfit_tmp.msa.z_m2 = str2num(tokens{22});
            sqfit_tmp.msa.I2 = str2num(tokens{23});
            sqfit_tmp.msa.method = str2num(tokens{24});
         end
         if (length(tokens) == 25) % each data has its own form factor
            if (readiq ~= 0)
               sqfit_tmp.ff_inp = load('-ascii', tokens{25});
               disp(['   form factor: ' tokens{25} ' loaded.'])
            end
            sqfit_tmp.fname_ff_inp = tokens{25};
         end
         
         % check the existence of msa data
         [dummy, msafile] = fileparts(sqfit_tmp.fname);
         msafile = [msafile, '.msa'];
         if exist(msafile, 'file') && (readiq ~=0)
            specdata = specdata_readfile(msafile);
            sqfit_tmp.iq = specdata.data(:,[1,2]);
            sqfit_tmp.iq_fit = specdata.data(:,[1,3]);
            sqfit_tmp.iq_dif = sqfit_tmp.iq;
            sqfit_tmp.iq_dif(:,2) = sqfit_tmp.iq(:,2) - sqfit_tmp.iq_fit(:,2);
            sqfit_tmp.sq = specdata.data(:,[1,4]);
            sqfit_tmp.sq_fit = specdata.data(:,[1,5]);
            sqfit_tmp.sq_dif = sqfit_tmp.sq;
            sqfit_tmp.sq_dif(:,2) = sqfit_tmp.sq(:,2) - sqfit_tmp.sq_fit(:,2);
         end
         
         sqfit(i_entry) = sqfit_tmp;
      end
   end
end % for i_line = 1:num_lines
showinfo(['Successfully read SQFIT setup file: ', setupfile])
return
