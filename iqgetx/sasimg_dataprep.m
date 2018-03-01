function imgdata = sasimg_dataprep(imgdata, varargin);
% --- Usage:
%        xydata = sasimg_dataprep(xydata, varargin)
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
% $Id: sasimg_dataprep.m,v 1.1 2014/03/19 05:07:57 xqiu Exp $
%

if (nargin < 1)
   error('No parameter passed!')
   return
end
verbose = 1;
readdata = 0;
parse_varargin(varargin);

num_sets = length(imgdata);
for i = 1:num_sets
   % 0) re-init the data
   %imgdata(i) = sasimg_init(imgdata(i), 'readdata', readdata);
   imgdata(i).im = double(imgdata(i).rawim);
   
   % 1) invert intensity and transpose
   if (imgdata(i).invertim)
      imgdata(i).im = imgdata(i).invertim_zero - imgdata(i).im;
%      min_tmp = imgdata(i).plotopt.min;
%      imgdata(i).plotopt.min = imgdata(i).invertim_zero - ...
%          imgdata(i).plotopt.max;
%      imgdata(i).plotopt.max = imgdata(i).invertim_zero - min_tmp;
   end
   if (imgdata(i).transposeim)
   end
   
   % 2) math corrections
   imgdata(i).im = (imgdata(i).im + imgdata(i).offset)*imgdata(i).scale;
   if imgdata(i).log10I
      imgdata(i).im = log10(imgdata(i).im);
   end
   
   % 3) Mask
   if (imgdata(i).maskim)
      imgdata(i).im = imgdata(i).im.*double(imgdata(i).MaskI);
   end
   
   if isinf(imgdata(i).plotopt.min); imgdata(i).plotopt.min = max([0,min(imgdata(i).im(:))]);end
   if isinf(imgdata(i).plotopt.max); imgdata(i).plotopt.max = max([max(imgdata(i).im(:)), imgdata(i).plotopt.min+1]);end

   % 4) get I(Q) if autogetiq is set
   if imgdata(i).autogetiq
      imgdata(i) = sasimg_run(imgdata(i), 'iq_get');
   end
end