function fem = runfl_setconst(fem, const)

% change the content of fem.const with the structure "const"

names_field = fieldnames(const);
for ii=1:length(names_field)
   
   index = strmatch(names_field{ii}, fem.const, 'exact');
   
   if isempty(index)
      fem.const = {fem.const{:}, names_field{ii}, num2str(getfield(const, ...
                                                        names_field{ii}))};
   else
      fem.const{index(1)+1} = num2str(getfield(const, names_field{ii}));
   end
end
