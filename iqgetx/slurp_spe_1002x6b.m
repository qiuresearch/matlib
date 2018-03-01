function [sumdata, imgdata] = slurp_spe_1002x6b(prefix, imgnums, darknums, sOpt)
% --- Usage:
%        [avgdata, imgdata] = slurp_sgl1ccd_xq(prefix, imgnums, darknums, sOpt)
%           a derivation from Lisa's slurp routine
%
% --- Purpose:
%        read in the image files (imread);  subtract the dark image; 
%        dezinger and sum together (dezing); normalize by XFLASH count; 
%
% --- Parameter(s):
%        prefix   - the file name prefix, e.g., 'c26e'. It can be the full
%                   file name as well. 
%        imgnums  - the image numbers to process
%        darknums - the dark current images numbers to subtract
%        sOpt     - the structure containing the optional settings:
%                    dezinger  - [1] or 0 for dezingering or not
%                    normalize - [1] or 0 for normalizing or not
%                    suffix    - file suffix, default is 'tif'
%                    im_dark   - a scalar or matrix of the same dimension
%                                as the data image
% --- Return(s): 
%        sumdata - a structure containing the summed data
%        imgdata - an array of structures, each of which is from one image
%
% --- Example(s):
%
% $Id: slurp_spe_1002x6b.m,v 1.3 2013/08/19 03:02:26 xqiu Exp $
%
global MaskI

verbose = 1;
if nargin < 1
   funcname = mfilename;
   eval(['help ' funcname]);
   error('at least one parameter is required, please see the usage! ')
end

% setup the default sOpt (if provided, *MUST* have all fields!)
if nargin < 4
   sOpt.dezinger = 0;
   sOpt.smooth = 0;
   sOpt.normalize = 0;
   sOpt.datadir = '';
   sOpt.suffix = '';
   sOpt.im_dark = 0;  % a scalar or 512x512 array of the dark image
end

if (nargin > 2) && ~isempty(darknums) % if darknum is passed, use it!
   dezinger = sOpt.dezinger;
   normalize = sOpt.normalize;
   sOpt.normalize = 0; % no normalization for dark images
   sOpt.dezinger = 1;  % always dezinger dark images
   sOpt.im_dark = 0;
   darkdata = slurp_marccd_0806nsls(prefix, darknums, [], sOpt);
   sOpt.normalize = normalize;
   sOpt.dezinger = dezinger;
   sOpt.im_dark = darkdata.im / length(darknums);
   clear darkdata
end

% 1) initialize the data structure array

templ_struct = struct('prefix', '', 'num', 0, 'suffix', '', 'file', ...
                      '', 'im', 0);
if (nargin > 1) && ~isempty(imgnums)
   num_imgs = length(imgnums);
   imgdata = repmat(templ_struct, 1, num_imgs);
   for i=1:num_imgs
      imgdata(i).prefix = prefix;
      imgdata(i).num = imgnums(i);
      imgdata(i).suffix = sOpt.suffix;
      imgdata(i).file = [sOpt.datadir imgdata(i).prefix ...
                         sprintf(['%0' num2str(sOpt.num_digits) 'i'], ...
                                 imgdata(i).num) imgdata(i).suffix];
   end
else % if the file name is passed directly
   num_imgs=1;
   imgdata = templ_struct;
   imgdata.num = [];
   imgdata.file=[sOpt.datadir prefix sOpt.suffix];
   [dummy, imgdata.prefix] = fileparts(imgdata.file);
end

% 2) load the data, and the tag values into the structure fields

for i=1:num_imgs
   
   % a) read the image file, and do CORRECT and dark image subtraction
   if exist(imgdata(i).file, 'file'); 
      [im, header] = imread_spe(imgdata(i).file);
      imgdata(i).im = double(im);
      %imgdata(i).im(find(imgdata(i).im > 65000)) = 0;
      %imgdata(i).im(:,:) = correct(imgdata(i).im);
      if isfield(sOpt, 'im_dark') && ~isempty(sOpt.im_dark)
         imgdata(i).im(:,:) = imgdata(i).im - sOpt.im_dark;
         % maybe add the average dark current
         %         imgdata(i).avg_dark = 
      end
      imgdata(i).mean = total(imgdata(i).im.*double(MaskI))/total(MaskI);
      if isfield(sOpt, 'time')
         imgdata(i).expotime = sOpt.expotime;
      else
         imgdata(i).expotime = 1;
      end
      showinfo(sprintf(['reading image file: %s, average count: ' ...
      '%6.1f'], imgdata(i).file, imgdata(i).mean));
   else
      showinfo(['image file:' imgdata(i).file ' does not exist!'], 'warning')
   end

   % b) normalization
   imgdata(i).monnames = {'transbeam', 'ion1', 'time', 'mean'};
   
   imgdata(i).moncounts = [header.ion2,header.ion1,header.expotime, ...
                       imgdata(i).mean];

%   % calcuate the transmitted beam intensity by:
%   %     1) get the backgroun from I[beamstop] - I[transtop]
%   %     2) subtract I[transtop] - I[bakcground]
%   beamstop = [688, 585; 706, 641];
%   transtop = [694, 591; 700, 599];
%   numpixels_beam = prod(beamstop(2,:)-beamstop(1,:));
%   numpixels_tran = prod(transtop(2,:)-transtop(1,:));
%   Ibeamstop = total(imgdata(i).im(beamstop(1,1):beamstop(2,1), beamstop(1,2):beamstop(2,2)));
%   Itranstop = total(imgdata(i).im(transtop(1,1):transtop(2,1), transtop(1,2):transtop(2,2)));
%   Ibkg = (Ibeamstop - Itranstop)/(numpixels_beam - numpixels_tran);
%   transbeam = Itranstop - Ibkg*numpixels_tran;
%   
%   % get "bicron", intensity (if a spec file exists)
%   bicron = 1;
%   if isfield(sOpt, 'specfile') && ~isempty(sOpt.specfile)
%      if isempty(sOpt.specdata)
%         sOpt.specdata = readspecfile_0802nsls(sOpt.specfile);
%      end
%      dataname = [imgdata(i).prefix num2str(imgdata(i).num)];
%      if isfield(sOpt.specdata, dataname)
%         bicron = sOpt.specdata.(dataname).bicron;
%      end
%   end
   
   % assign the normconst
   if (sOpt.normalize ~= 0)
      imgdata(i).normconst = imgdata(i).moncounts(sOpt.normalize);
   else
      imgdata(i).normconst = 1;
   end
   
   imgdata(i).smooth = sOpt.smooth;
end

% 3) do corrections: dezinger, normalize

sumdata.dezinger = sOpt.dezinger;
sumdata.smooth = sOpt.smooth;
sumdata.normalize = sOpt.normalize;
sumdata.datadir = sOpt.datadir;
sumdata.prefix = prefix;
sumdata.suffix = sOpt.suffix;

sumdata.imgnums = [imgdata(:).num];
sumdata.file = {imgdata.file};

if (sOpt.dezinger == 1)
   showinfo('dezinger and sum together ...')
   for i=1:length(imgdata)
      imgdata(i).im = 0.5*double(dezing(uint16(cat(3,imgdata(i).im, ...
                                                   imgdata(i).im))));
   end
   
   if num_imgs == 1 % at least two images are needed for dezingering!
      sumdata.im = 0.5*double(dezing(uint16(cat(3,imgdata.im, imgdata.im))));
   else 
      sumdata.im = double(dezing(uint16(cat(3,imgdata(:).im)))); 
   end
else
   sumdata.im = sum(cat(3,imgdata(:).im),3);
end

sumdata.mean = [imgdata(:).mean];
sumdata.expotime = [imgdata(:).expotime];
%sumdata.expotime = [imgdata(:).expotime];
if isfield(imgdata(1), 'moncounts')
   sumdata.monnames = imgdata(1).monnames;
   sumdata.moncounts = reshape([imgdata(:).moncounts], ...
                               length(sumdata.monnames), num_imgs)';
end
sumdata.normconst = [imgdata(:).normconst];

% 4) returning
