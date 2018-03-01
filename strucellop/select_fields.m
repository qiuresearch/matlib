function selected = select_fields(sdata, matchstr)
% use regular expression to match the field names, an array of the
% matched fields is returned.
   
   allnames = fieldnames(sdata);
   imatch = 1;
   for i=1:length(allnames)
      if regexpi(allnames{i}, matchstr, 'once');
         selected(imatch)=sdata.(allnames{i});
         imatch = imatch+1;
      end
   end
      
   if ~exist('selected', 'var')
      selected = [];
   end
   