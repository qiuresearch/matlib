function [im, dataformat] = imread_any(imgfile, dataformat, varargin);
   
   if ~exist('dataformat', 'var') || isempty(dataformat)
      dataformat = dataformat_guess(imgfile);
   end
   switch upper(dataformat)
      case 'MAR345'
         im = imread_mar345(imgfile);
      case {'TIF', 'TIFF'}
         im = imread(imgfile);
      otherwise
         im = imread(imgfile);
   end