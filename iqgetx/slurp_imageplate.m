function [sumdata, imgdata] = slurp_imageplate(prefix, scannums, ...
                                               darknums, sOpt)
% --- Usage:
%        [sumdata, imgdata] = slurpadsc_xq(prefix, scanums, sOpt)
%           a derivation from Lisa's slurpadsc routine
%
% --- Purpose:
%        read in the image files (imread), and dezinger (dezing),
%        normalize (by gdoor value in SPEC file), average.
% --- Parameter(s):
%     
% --- Return(s): 
%        sumdatas - 
%
% --- Example(s):
%
% $Id: slurp_imageplate.m,v 1.7 2014/04/05 19:37:48 xqiu Exp $

verbose = 1;
if nargin < 1
   error('at least one parameter is required, please see the usage! ')
   help slurq_imageplate
   return
end

% setup the default sOpt (if provided, MUST have all fields!)
if nargin < 4
   sOpt.invertim = 0; % whether the 0 is represented as 2^bits-1
   sOpt.dezinger = 0;
   sOpt.normalize = 0;
   sOpt.readraw = 1;
   sOpt.datadir = './';
   sOpt.suffix = '.tif';
   sOpt.im_dark = 0;
end

suffix = sOpt.suffix;

% 1) initialize the data structure array

templ_struct = struct('datadir', '', 'prefix', '', 'num', 0, 'suffix', ...
                      sOpt.suffix, 'file', '',  'im', 0.0);

if ~exist('scannums', 'var') || isempty(scannums)
   % if the file name is passed directly
   scannums = 0;
   num_imgs=1;
   imgdata = templ_struct;
   [imgdata.datadir, imgdata.prefix, imgdata.suffix] = fileparts(prefix);
   imgdata.imgnums = 0;
   imgdata.file=prefix;
   specdata = [];
else % has scan number
   showinfo('Not implemented yet!!!');
end

% 3) load the data
for i=1:num_imgs
   if exist(imgdata(i).file, 'file'); 
      imgdata(i).im = double(imread(imgdata(i).file));
      if (sOpt.invertim == 1)
         imgdata(i).im = 2^16-1-imgdata(i).im;
      end
      if (length(sOpt.im_dark) ~=1) || (sOpt.im_dark ~= 0.0)
         imgdata(i).im = imgdata(i).im - sOpt.im_dark;
      end
      imgdata(i).mean = mean(imgdata(i).im(:));
      showinfo(['reading image file: ' imgdata(i).file ', average ' ...
                          'count: ' num2str(imgdata(i).mean)]);
   else
      warning(['signums file:' imgdata(i).file ' does not exist!'])
   end
   
   if (sOpt.normalize ~= 0)
      imgdata(i).normconst = 1;
   else
      imgdata(i).normconst = 1;
   end
end

% 4) do corrections: dezinger, normalize
sumdata = sOpt;
sumdata.datadir = imgdata(1).datadir;
sumdata.prefix = imgdata(1).prefix;
sumdata.suffix = imgdata(1).suffix;

sumdata.imgnums = [imgdata(:).imgnums];
sumdata.file = {imgdata.file};

if (sOpt.dezinger == 1)
   showinfo('dezinger and sum together ...');
   if (num_imgs == 1)
      sumdata.im = 0.5*double(dezing(uint16(cat(3,imgdata(1).im, imgdata(1).im))));
   else 
      sumdata.im = double(dezing(uint16(cat(3,imgdata(:).im)))); 
   end
else
    sumdata.im = sum(cat(3, imgdata(:).im),3);
end

sumdata.mean = [imgdata(:).mean];
%sumdata.expotime = [imgdata(:).expotime];
if isfield(imgdata(1), 'moncounts')
   sumdata.monnames = imgdata(1).monnames;
   sumdata.moncounts = reshape([imgdata(:).moncounts], ...
                               length(sumdata.monnames), num_imgs)';
   sumdata.normconst = [imgdata(:).normconst];
end
   
% 5) return
sumdata = struct_assign(struct_assign(imgdata(1), sOpt, 'noappend'), sumdata);