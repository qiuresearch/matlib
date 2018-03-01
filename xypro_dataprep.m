function xydata = xypro_dataprep(xydata, varargin)
% --- Usage:
%        xydata = xypro_dataprep(xydata, varargin)
% --- Purpose:
%        preprocess data for compatibility/consistency issues,
%        0) re-read all the data 
%        1) double check the q_min, and q_max
%        2) interpolate all the form factor in compliance with sqfit.iq_raw
%
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: xypro_dataprep.m,v 1.5 2015/09/25 19:02:42 schowell Exp $
%

if (nargin < 1)
   error('No parameter passed!')
   return
end
verbose = 1;
readdata = 0;
parse_varargin(varargin);

num_sets = length(xydata);
for i = 1:num_sets
   % 0) re-init the data
   xydata(i) = xypro_init(xydata(i), 'readdata', readdata);
   
   % 1) reset imin, imax
   xydata(i).imin = locate(xydata(i).data(:,1), xydata(i).xmin);
   xydata(i).imax = locate(xydata(i).data(:,1), xydata(i).xmax);
   xydata(i).data = xydata(i).data(xydata(i).imin:xydata(i).imax, :);

   % 2) math corrections
   data = xydata(i).data;
   data(:,2) = data(:,2) + xydata(i).offset;
   data(:,[2,4]) = data(:,[2,4]) * xydata(i).scale;
   
   if isfield(xydata(i), 'smooth') && (xydata(i).smooth > 0);
      imin = locate(xydata(i).data(:,1), xydata(i).smooth_range(1));
      imax = locate(xydata(i).data(:,1), xydata(i).smooth_range(2));
      data(imin:imax,2) = smooth(data(imin:imax,1), data(imin:imax,2), xydata(i).smooth_span, ...
                         xydata(i).smooth_method{xydata(i).smooth_type}, ...
                         xydata(i).smooth_degree);
   end
   
   if isfield(xydata(i), 'min_x2') && (xydata(i).match > 0)
       [xydata(i).data, xydata(i).scale_match, xydata(i).offset_match, ~] ...
          = scale_offset(xydata(i).data, xydata(i).match_data, ...
                  'match_range', xydata(i).match_range, ...
                  'scale', xydata(i).match_scale, ...
                  'offset', xydata(i).match_offset);
   elseif isfield(xydata(i), 'match') && (xydata(i).match > 0)
      [xydata(i).data, xydata(i).scale_match, xydata(i).offset_match] ...
          = match(xydata(i).data, xydata(i).match_data, ...
                  xydata(i).match_range, 'scale', xydata(i).match_scale, ...
                  'offset', xydata(i).match_offset);
   end
   
   if isfield(xydata(i), 'mathstring') && ~strcmpi(xydata(i).mathstring, ...
                                                   'x=x;y=y;e=e;')
      x = xydata(i).data(:,1); y = xydata(i).data(:,2); e = xydata(i).data(:,4);
      eval(xydata(i).mathstring);
      xydata(i).data(:,[1,2,4]) = [x,y,e];
   end
   
   % 3) sas specific
   if isfield(xydata(i), 'guinier') && (xydata(i).guinier == 1)
      xydata(i).data(:,4) = xydata(i).data(:,4)./xydata(i).data(:,2);
      xydata(i).data(:,2) = log(xydata(i).data(:,2));
      xydata(i).data(:,1) = xydata(i).data(:,1).^2;
   end

   if isfield(xydata(i), 'kratky') && (xydata(i).kratky == 1)
      xydata(i).data(:,[2,4]) = xydata(i).data(:,[2,4]).*xydata(i).data(:,[1,1]).^2;
   end

   if isfield(xydata(i), 'porod') && (xydata(i).porod == 1)
      xydata(i).data(:,[2,4]) = xydata(i).data(:,[2,4]).*xydata(i).data(:,[1,1]).^4;
   end
end
