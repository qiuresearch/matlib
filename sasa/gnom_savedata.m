function data = gnom_savedata(data, file, varargin)
% --- Usage:
%        data = gnom_savedata(data, file, varargin)
% --- Purpose:
%        save data into GNOM compatible format (a title + 3 columns)
% --- Parameter(s):
%        data -
%        file - file name to save as
%        varargin - 'err', 'header'
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: gnom_savedata.m,v 1.3 2013/08/29 03:45:06 xqiu Exp $
%

verbose = 1;
if (nargin < 1)
   help gnom_savedata
   return
end

parse_varargin(varargin);

% get default header
if ~exist('header', 'var') || isempty(header)
   index = strfind(file, '.');
   if ~isempty(index)
      header = strrep(file(1:(index(end)-1)), '_', ' ');
   else
      header = strrep(file, '_', ' ');
   end
end

% default error level 8%
if ~exist('err', 'var') || isempty(err)
   err = 0.03;
end

% reduce to three columns or estimate the error to the 3rd column
data_size = size(data);

if (data_size(2) >= 4)
   data(:,3) = data(:,4);
   data(:,4:end) = [];
end
if (data_size(2) == 2)
   showinfo('estimate standard deviations...');
   data(:,3) = abs(data(:,2).*data(:,1)*err/data(fix(end/2),1));
   %data(:,3) = error_estimate(data,1,13)*32;
end

% remove zero intensities in the beginning
[num_rows, num_cols] = size(data);
i_1stnozero = find(data(:,2), 1, 'first');
i_endnozero = find(data(:,2), 1, 'last');
if (i_1stnozero ~= 1)
   showinfo(['removing leading ' num2str(i_1stnozero-1) ' zeros...']);
   data(1:i_1stnozero-1,:) = [];
end
if (i_endnozero ~= num_rows)
   showinfo(['removing trailing ' num2str(num_rows-i_endnozero) ' zeros...']);
   data(i_endnozero+1-i_1stnozero+1:end,:) = [];
end

% check number of lines
%data(:,2) = abs(data(:,2));
[num_rows, num_cols] = size(data);
if (num_rows > 1024)
   nspan = ceil(num_rows/1024);
   data(:,2) = smooth(data(:,2), nspan);
   data = data(1:nspan:end,:);
   showinfo(['too many data points: ' num2str(num_rows) [', reduce ' ...
                       'by a factor of '] num2str(nspan)]);
end

% save data to file
fid = fopen(file, 'w');
fprintf(fid, '%s\n', header);
fprintf(fid, [repmat(['%8.6e    ' ''], 1, num_cols-1) '%8.6e\n'], data');
fclose(fid);
showinfo(['saved to file: ' file]);
