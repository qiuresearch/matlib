function sam_concen = uvspec_getconcen(uvspec, dilution, varargin)

if (nargin < 1)
   help uvspec_getconcen
   return
end

verbose = 1;
parse_varargin(varargin);

if (nargin < 2)
   dilution.default = 1; % 200;
   dilution.convertor = 1; %3.125e-3; % 3.125e-3 mM per OD=1
end
if ~isfield(dilution, 'default')
   dilution.default = 1; % 200;
end
if ~isfield(dilution, 'convertor')
   dilution.convertor = 1; %3.125e-3;
end

sam_names = strrep(uvspec.sam_names, '-', '_');
%
if strcmpi(uvspec.format, 'Cary')
   i260 = locate(uvspec.(sam_names{1})(:,1), 260);
   i320 = locate(uvspec.(sam_names{1})(:,1), 320);

   for i=1:length(uvspec.sam_names)
      if isfield(dilution, uvspec.sam_names{i})
         dilution_factor = dilution.(uvspec.sam_names{i});
      else
         dilution_factor = dilution.default;
      end
      data = uvspec.(sam_names{i});
      sam_concen.(sam_names{i}) = (data(i260,2)-data(i320,2))* ...
          dilution_factor*dilution.convertor;
   end
end
%
if strcmpi(uvspec.format, 'Cuvette')
   i260 = locate(uvspec.data(:,1), 260);
   i320 = locate(uvspec.data(:,1), 320);
   spec_concen = (uvspec.data(i260,:) - uvspec.data(i320,:)) * ...
       dilution.convertor;
   for i=1:length(uvspec.sam_names)
      icol = strmatch(uvspec.well_ids{i}, uvspec.column_names, 'EXACT');
      if isempty(icol)
         showinfo(['no data found for sample: ' uvspec.sam_names{i} ...
                   '!!!'], 'warning');
         continue
      end
      if isfield(dilution, uvspec.sam_names{i})
         dilution_factor = dilution.(uvspec.sam_names{i});
      else
         dilution_factor = dilution.default;
      end
      sam_concen.(sam_names{i}) = spec_concen(icol)*dilution_factor;
   end
end

%
if strcmpi(uvspec.format, 'Microplate')
   i260 = strmatch('A260', uvspec.column_names, 'EXACT');
   i320 = strmatch('A320', uvspec.column_names, 'EXACT');
   spec_concen = (uvspec.data(:,i260) - uvspec.data(:,i320)) * ...
       dilution.convertor;
   for i=1:length(uvspec.sam_names)
      if isfield(dilution, uvspec.sam_names{i})
         dilution_factor = dilution.(uvspec.sam_names{i});
      else
         dilution_factor = dilution.default;
      end
      sam_concen.(sam_names{i}) = spec_concen(i)*dilution_factor;
   end
end
