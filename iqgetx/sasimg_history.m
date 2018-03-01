function sas = sasimg_history(sas, varargin);

   verbose = 1;

   for i=1:length(sas)
      if strmatch(varargin, 'save');
         sas(i).history = [rmfield(sas(i), 'history'), sas(i).history];
         sas(i).history(sas(i).num_history+1:end)=[];
         showinfo(num2str(length(sas(i).history), ['saving history (total ' ...
                             'num: %d)']));
      end
      
      if strmatch(varargin, 'undo');
         if length(sas(i).history) > 0
            sas(i).history(sas(i).num_history:end)=[]; % remove 
            sas(i).history = [sas(i).history, rmfield(sas(i), 'history')];
            sas(i) = setfield(sas(i).history(1), 'history', sas(i).history(2:end));
         else
            showinfo('No history records availabel');
         end
      end
      
      if strmatch(varargin, 'redo');
         if length(sas(i).history) > 0
            sas(i).history(sas(i).num_history:end)=[]; % remove 
            sas(i).history = [rmfield(sas(i), 'history'), sas(i).history];
            sas(i) = setfield(sas(i).history(end), 'history', sas(i).history(1:end-1));
         else
            showinfo('No history records availabel');
         end
      end
   end
   