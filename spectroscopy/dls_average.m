function dlsdata_avg = dls_average(dlsdata, varargin);
% --- Usage:
%        dlsdata_avg = dls_average(dlsdata, varargin);
% --- Purpose:
%        Average the multiple records in DLS measurements on one
%        sample. Records are merged into one if:
%           1) with the same sample name
%           2) at the same temperature
% --- Parameter(s):
%        dlsdata  - an array of DLS data structure
%        varargin - only parameter now is "verbose"
% --- Return(s):
%        dlsdata_avg - 
%
% --- Example(s):
%
% $Id: dls_average.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

% 1) Simple check on input parameters

if nargin <
   help dls_average
   return
end

verbose = 1;
parse_varargin(varargin);

% shoud have the same Sample_Name except the last char

dlsdata_avg(1) = dlsdata(1);
dlsdata_avg(end).Sample_Name = strtrim(dlsdata_avg(end).Sample_Name(1:end-1));

tagnames = fieldnames(dlsdata_avg);
for i=1:length(tagnames)
   if isstr(dlsdata_avg(1).(tagnames{i}))
      tagtypes(i)=0; % is a string
   else
      tagtypes(i)=1; 
   end
end
showinfo(['total number of records: ' num2str(length(dlsdata))]);

for i=2:length(dlsdata)
   new_start = 1;
   Sample_Name = strtrim(dlsdata(i).Sample_Name(1:end-1));
   if strcmp(Sample_Name, dlsdata_avg(end).Sample_Name) &&  ...
          (dlsdata(i).Temperature == dlsdata_avg(end).Temperature)
      new_start = 0;
      for j=1:length(tagnames)
         switch tagtypes(j)
            case 0
               dlsdata_avg(end).(tagnames{j}) = [ ...
                   dlsdata_avg(end).(tagnames{j}), '|' ...
                   dlsdata(i).(tagnames{j})];
            case 1
               dlsdata_avg(end).(tagnames{j}) = [ ...
                   dlsdata_avg(end).(tagnames{j}); dlsdata(i).(tagnames{j})];
            otherwise 
         end
         dlsdata_avg(end).Sample_Name = Sample_Name;
         dlsdata_avg(end).Temperature = dlsdata(i).Temperature;
      end
   end
   
   % wrap up current average
   if (new_start == 1) || (i == length(dlsdata))
      % check whether it has the same delay times
      for j=2:length(dlsdata_avg(end).Record_Number)
         if ~isequal(dlsdata_avg(end).Correlation_Delay_Times(1,:), ...
                     dlsdata_avg(end).Correlation_Delay_Times(j,:))
            warning(['Correlation Delay Times not equal for record #' ...
                     num2str(dlsdata_avg(end).Record_Number(j))])
         end
      end
      dlsdata_avg(end).Correlation_Delay_Times = ...
          mean(dlsdata_avg(end).Correlation_Delay_Times,1);
      dlsdata_avg(end).Correlation_Data = ...
          mean(dlsdata_avg(end).Correlation_Data,1);
      dlsdata_avg(end).Sizes = mean(dlsdata_avg(end).Sizes,1);
      dlsdata_avg(end).Intensities = mean(dlsdata_avg(end).Intensities,1);
      dlsdata_avg(end).Numbers = mean(dlsdata_avg(end).Numbers, 1);
      dlsdata_avg(end).Volumes = mean(dlsdata_avg(end).Volumes,1);
      showinfo(['average record number: ' ...
                strjoin(num2str(dlsdata_avg(end).Record_Number), ',')]);
   end
   
   if (new_start ==1)   % new average
      dlsdata_avg(end+1) = dlsdata(i);
      dlsdata_avg(end).Sample_Name = ...
          strtrim(dlsdata_avg(end).Sample_Name(1:end-1));
   end
end
showinfo(['total number of averaged records: ' num2str(length(dlsdata_avg))]);
