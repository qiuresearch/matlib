function datastr = showxycen(siqgetx)

names = fieldnames(siqgetx);
%datastr = {};
ii=0;
for i=1:length(names)
   if ~isstruct(siqgetx.(names{i}))
      continue
   end
   %datastr = {datastr{:} sprintf('%18s %8.4f %8.4f', names{i}, ...
   %                              siqgetx.(names{i}).X_cen, ...
   %                              siqgetx.(names{i}).Y_cen)};
   ii=ii+1;
   datastr(ii,:) =sprintf('%30s %8.4f %8.4f %8.4f', names{i}, ...
                          siqgetx.(names{i}).Spec_to_Phos, ...
                          siqgetx.(names{i}).X_cen, siqgetx.(names{i}).Y_cen);
end
