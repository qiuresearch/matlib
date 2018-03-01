function result = parse_varargin(cell_par)
%        result = parse_varargin(cell_par)
%  
% Just serves to parse the cell_par according to my convention:
%        1) the var_name, var_value should come in pairs
%        2) only exception is the last var_name with default values
%        of 1

if isempty(cell_par)
   return
end

num_vars = length(cell_par);
for i=1:2:num_vars
   if i < num_vars
      %assigns cell_par{i+1} into cell_par{i} in the caller function
      assignin('caller', cell_par{i}, cell_par{i+1}); 
      %evalin('caller', [cell_par{i} '=' cell_par{i+1} ';']);
   else
      % the last string is given a value of 1
      assignin('caller', cell_par{i}, 1);
      %evalin('caller', [cell_par{i} '=1;']);
   end
end
