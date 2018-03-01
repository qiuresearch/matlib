function xlstable = icpaes_gettable(xlsdata, atoms, dilution)

verbose = 1;
if (nargin < 3)
   dilution = 1;
end

% atoms need to be a cell array
if ischar(atoms)
   atoms = cellstr(atoms);
end

xlstable(:,1) = {'sample', xlsdata.sam_names{:}};
itable = 2;
for i=1:length(atoms)
   k = strmatch(upper(atoms{i}), upper(xlsdata.atoms), 'exact');
   if isempty(k); 
      showinfo(['atom not found: ' atoms{k}], 'warning');
      continue; 
   end
   xlstable(1,itable) = {[atoms{i} '(' num2str(xlsdata.atommass(k)) ')']};
   xlstable(2:end,itable) = cellstr(num2str(xlsdata.concen(:,k)*dilution, '%0.2e'));
   itable = itable + 1;
end
