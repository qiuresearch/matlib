function saveascii(data, file, format, varargin)
% --- Usage:
%        saveascii(data, file, format, varargin)
%
% --- Purpose:
%        save ascii data into a text file
% --- Parameter(s):
%        data   -  can be numerical 
%        varargin -
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: saveascii.m,v 1.3 2013/10/22 18:34:23 schowell Exp $
%
%
% save "data" to ascii file "file"
%

% 1) 
if nargin < 2
   help saveascii
   return
end

if ~exist('format', 'var') || isempty(format)
   format = '-ASCII';
end

% 2)
switch upper(format)
   case '-ASCII'
      save('-ASCII', file, 'data');
   case 'CRYSOL' % assuming it is numerical array
      fid = fopen(file, 'w');
      fprintf(fid, 'Crysol Data Format @ %s\n', datestr(now));
      
      [num_rows, num_cols] = size(data);
      %  number of points limited to 512
      if (num_rows > 512) 
         data = data(1:ceil(num_rows/512):num_rows, :);
      end
      
      fprintf(fid, [repmat('%0.7g    ', 1, num_cols-1) '%0.7g\n'], data');
      fclose(fid);
   otherwise
end
