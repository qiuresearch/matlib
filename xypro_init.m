function xydata = xypro_init(initpar, varargin)
%        xydata = xypro_init(initpar)
%             initpar can be empty, a file name, a cell array of file
%             names or a xypro structure

readdata = 1;
dataformat = '';
parse_varargin(varargin);

% if no input parameter given
if ~exist('initpar', 'var') || isempty(initpar)
   xydata.id = 1; % its index
   xydata.select = 1; % whether selected for action
   xydata.title = '';
   xydata.datadir = '';
   xydata.prefix = '';
   xydata.suffix = '';
   xydata.filename = '';
   xydata.dataformat = dataformat;
   
   xydata.scannum = [];
   xydata.columnnames = [];
   xydata.rawcolumnnames = [];
   xydata.data = [];
   xydata.rawdata = [];
   
   xydata.xcol = 1;
   xydata.ycol = 2;
   xydata.ecol = 4;
   xydata.sortx = 1;
   xydata.imin = [];
   xydata.imax = [];
   xydata.xmin=[];
   xydata.xmax=[];
   xydata.offset = 0;
   xydata.scale = 1.0;
   xydata.smooth = 0;
   xydata.smooth_span = 5;
   xydata.smooth_type = 1;
   xydata.smooth_method = {'moving', 'lowess', 'loess', 'sgolay', ...
                       'rlowess', 'rloess'};
   xydata.smooth_degree = 1;
   xydata.smooth_range = [-Inf, Inf];
   
   xydata.match = 0;
   xydata.match_data = [1,1];
   xydata.match_scale = 1;
   xydata.match_offset = 0;
   xydata.match_range = [];
   xydata.offset_match = 0;
   xydata.scale_match = 1;
   
   xydata.mathstring = 'x=x;y=y;e=e;';

   % sas settings
   xydata.concentration = 1;
   xydata.ionstrength = 1;
   xydata.dmax = 100;
   xydata.molweight = 0;
   xydata.guinier = 0;
   xydata.guinier_range = [0, 0.01];

   xydata.kratky = 0;
   xydata.porod = 0;
   
   xydata.calcdata = [];
   xydata.fitdata = [];
   xydata.difdata = [];

   % fitting options
   xydata.ifunc = 1;
   xydata.funclist = {'linear', 'gauss', 'lorentz', 'sine', 'guinierRg', ...
                      'osmodata', 'osmodata2', 'dnapeak'};
   xydata.algorithmlist = {'trust-region-reflective', 'levenberg-marquardt'};
   xydata.fitpar = [];
   xydata = xypro_fitfunc(xydata, 'init_fitpar', 1:length(xydata.funclist));

elseif ischar(initpar) % if one file name is passed
   xydata = xypro_init([], varargin{:});
   xydata.filename = initpar;
   [xydata.datadir, xydata.prefix, xydata.suffix] = fileparts(initpar);
   xydata = xypro_init(xydata);
elseif iscell(initpar) % if a cell array of filenames
   xydata = repmat(xypro_init([], varargin{:}), 1, length(initpar)); 
   [xydata.filename] = deal(initpar{:});
   for i=1:length(xydata)
      [xydata(i).datadir, xydata(i).prefix, xydata(i).suffix] = ...
          fileparts(initpar{i});
   end
   xydata = xypro_init(xydata);
elseif isnumeric(initpar); % if a numeric array is passed
   xydata = xypro_init();
   xydata.rawdata = initpar;
   xydata.title = inputname(1);
   xydata = xypro_init(xydata, 'readdata',0);
elseif isstruct(initpar); % if a structure (array)
   xydata = initpar;
   % 1) read in data if necessary
   if (readdata == 1)
      xydata_new = [];
      for i=1:length(xydata)
         % guess file format if it's not specified
         if isempty(xydata(i).dataformat)
            runit = fopen(xydata(i).filename, 'r');
            first_line = fgetl(runit);
            second_line = fgetl(runit);
            fclose(runit);
            
            if strncmpi(second_line, 'NanoVUE', 7)
               xydata(i).dataformat = 'NanoVUE';
            else
               xydata(i).dataformat = 'SPEC';
            end
            
         end
         % read the data file
         switch upper(xydata(i).dataformat)
            case {'SPEC', 'XY', 'NXM'}
               specdata = specdata_readfile(xydata(i).filename);
            case 'NANOVUE'
               specdata = uvspec_readspectrum(xydata(i).filename, ...
                                              'dataformat', 'NanoVUE');
               
            otherwise
               showinfo(['Dataformat: ' xydata(i).dataformat ' is ' ...
                                   'not supported!']);
         end
         
         for j=1:length(specdata)
            xydata_new = [xydata_new, struct_assign(specdata(j), xydata(i), 'copyempty', 0)];
            xydata_new(end).rawdata = xydata_new(end).data;
            xydata_new(end).rawcolumnnames = xydata_new(end).columnnames;
         end
      end
      xydata = xydata_new;
      
      % add the error bar if not present
      for i=1:length(xydata)
         num_rowcols = size(xydata(i).rawdata);
         switch num_rowcols(2)
            case 0
               showinfo(['No data in ' xydata(i).filename num2str(i, '(i=%i)')]);
            case 1
               xydata(i).rawcolumnnames = {'No', xydata(i).rawcolumnnames{1}, 'err'};
               xydata(i).rawdata(:,2) = xydata(i).rawdata(:,1);
               xydata(i).rawdata(:,1) = 1:num_rowcols(1);
               xydata(i).ecol = 3;
               xydata(i).rawdata(:,3) = sqrt(abs(xydata(i).rawdata(:,2)));
            case 2
               xydata(i).rawcolumnnames = {xydata(i).rawcolumnnames{:}, 'err'};
               xydata(i).ecol = 3;
               xydata(i).rawdata(:,3) = sqrt(abs(xydata(i).rawdata(:,2)));
            case 3
               xydata(i).ecol = 3;
            otherwise
         end
      end
   end

   % 2) reset data, xmin, xmax
   for i = 1:length(xydata)
      xydata(i).id = i;
      if isempty(xydata(i).title)
         xydata(i).title = xydata(i).filename;
      end
      
      xydata(i).data = xydata(i).rawdata(:,[xydata(i).xcol, xydata(i).ycol, ...
                          xydata(i).ecol, xydata(i).ecol]);
      xydata(i).columnnames = xydata(i).rawcolumnnames([xydata(i).xcol, ...
                          xydata(i).ycol, xydata(i).ecol, xydata(i).ecol]);
      
      if (xydata(i).sortx ==1)
         [dummy, isorted] = sort(xydata(i).data(:,1));
         xydata(i).data = xydata(i).data(isorted,:);
      end
      
      if isempty(xydata(i).xmin)
         xydata(i).xmin = xydata(i).data(1,1);
         xydata(i).imin = 1;
      end
      if isempty(xydata(i).xmax)
         xydata(i).xmax = xydata(i).data(end,1);
         xydata(i).imax = length(xydata(i).data(:,1));
      end
      
      if isempty(xydata(i).match_range)
         xydata(i).match_range = [xydata(i).xmin*0.6+xydata(i).xmax*0.4, ...
                             xydata(i).xmin*0.4+xydata(i).xmax* 0.6];
      end
      [xydata(i).fitpar.xmin] = deal(xydata(i).xmin);
      [xydata(i).fitpar.xmax] = deal(xydata(i).xmax);
   end
else
   showinfo('The input parameter is not recognized')
end
