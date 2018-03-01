function sAPBS = apbs_readdx(fname, varargin)
% --- Usage:
%        sAPBS = apbs_readdx(fname, varargin)
% --- Purpose:
%        read in the OpenDX format defined in APBS user's
%        guide. Extracted data are: 1)dime, 2)xyzmin, delta, 3)data
%
% --- Parameter(s):
%        fname - the OpenDX file name
% --- Return(s):
%        sAPBS - a structure with relevant fields
%
% --- Example(s):
%
% $Id: apbs_readdx.m,v 1.2 2013/02/28 16:52:10 schowell Exp $
%

% 1) default setting
verbose = 1;
format = 'mg'; % multi-grid format
parse_varargin(varargin);

% 2) read the data file
fid = fopen(fname, 'r');
if (verbose == 1)
   disp(['APBS_READDX:: reading data file: ' fname])
end
red_light = 0; % the stop reading signal
while (red_light == 0) && ~feof(fid)
   newline = fgetl(fid);
   % skip comments
   if strcmp(newline(1), '#')
      %      if (verbose == 1), disp(newline), end
      continue
   end

   % the strategy is to use read block by block
   %  i) the "OBJECT" line, ii) read it content
   tokens = strsplit(newline, ' ');
   if ~strcmp(tokens{1}, 'object')
      disp('WARNING:: this line should start with OBJECT!')
      disp(newline)
   end

   switch tokens{4}
      case 'gridpositions'
         sAPBS.dime = [str2num(tokens{end-2}), str2num(tokens{end-1}), ...
                       str2num(tokens{end})];
         dummy = fgetl(fid);
         sAPBS.xyzmin = str2num(dummy(8:end));
         for i=1:3
            dummy = fgetl(fid);
            sAPBS.delta(i,:) = str2num(dummy(7:end));
         end
      case 'gridconnections'
         
      case 'array'
         sAPBS.num_points = str2num(tokens{10});
         [sAPBS.data, counts] = fscanf(fid, '%f', sAPBS.num_points);
         red_light = 1;
      otherwise
   end
end
fclose(fid);
% --> important matrix shuffling to get it right
sAPBS.data = reshape(sAPBS.data, fliplr(sAPBS.dime));
sAPBS.data = permute(sAPBS.data,[3,2,1]);

