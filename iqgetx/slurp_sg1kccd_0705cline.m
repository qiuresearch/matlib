function [sumdata, imgdata] = slurp_sg1kccd_0705cline(prefix, imgnums, darknums, sOpt)
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
% $Id: slurp_sg1kccd_0705cline.m,v 1.3 2013/08/19 03:02:26 xqiu Exp $
%
%  slurpnc is like slurp, except for the following: 
%      no intensity or distortion correction.
%      no call to average tag
%      calls take.m instead of fread.
%        (now calls adsctake, which is equivalent C code)
%      uses .img or .imx files and not .tif
%
%  If you call slurp with only prefix and signal, it will load the
% signal, dezinger/distortion/intensity correct and average it and
% return it as result.  It will not scale for the X-ray flux as it has
% no background.  If you give it a background, it will load the
% signal, dezinger/distortion/intensity correct, subtract the
% background, average and then scale for the x-ray flux.  Note, it
% must be a background and not a buffer!  Either way, result is will
% be a M*N image.  Examples x1=slurp('Mochrie',1); -> Loads image
% Mochrie1.tif into variabl x1.
% no dezingering or flux correction but distortion/intensity
%     corrected.
%        x2=slurp('Mochrie',[3,6:8]); -> Gives the average of images
%     Mochrie3.tif, Mochrie6.tif, Mochrie7.tif and Mochrie8.tif
%     dezingered/distortion/intensity corrected but no flux
%     correction.
%        x3=slurp('Kwok',[3,5],[7:8]); -> Gives average of Kwok3.tif
%        and Kwok4.tif minus
%       the background of Kwok7.tif and Kwok8.tif
%     dezingered/distortion/intensity/background subtracted and flux
%     corrected.

verbose = 1;
if nargin < 1
   error('at least one parameter is required, please see the usage! ')
   help slurp_sg1kccd_0705cline
   return
end

% setup the default sOpt (if provided, *MUST* have all fields!)
if nargin < 4
   sOpt.dezinger = 1;
   sOpt.normalize = 1;
   sOpt.datadir = '';
   sOpt.suffix = '.tif';
   sOpt.im_dark = 0;  % a scalar or 512x512 array of the dark image
end

if (nargin > 2) && ~isempty(darknums) % if darknum is passed, use it!
   dezinger = sOpt.dezinger;
   normalize = sOpt.normalize;
   sOpt.normalize = 0; % no normalization for dark images
   sOpt.dezinger = 1;  % always dezinger dark images
   sOpt.im_dark = 0;
   darkdata = slurp_sg1kccd_0705cline(prefix, darknums, [], sOpt);
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
                         sprintf('%i',imgdata(i).num) imgdata(i).suffix];
   end
else % if the file name is passed directly
   num_imgs=1;
   imgdata = templ_struct;
   imgdata.file=prefix;
   imgdata.num = [];
   [dummy, imgdata.prefix] = fileparts(imgdata.file);
end

% 2) load the data, and the tag values into the structure fields

for i=1:num_imgs
   % read the image file, and do CORRECT and dark image subtraction
   if exist(imgdata(i).file, 'file'); 
      imgdata(i).im = double(imread(imgdata(i).file, 'tif'));
      imgdata(i).im(:,:) = correct(imgdata(i).im);
      if isfield(sOpt, 'im_dark') && (length(sOpt.im_dark) > 0)
         imgdata(i).im(:,:) = imgdata(i).im - sOpt.im_dark;
         % maybe add the average dark current
         %         imgdata(i).avg_dark = 
      end
      imgdata(i).mean = mean(imgdata(i).im(:));
      if isfield(sOpt, 'time')
         imgdata(i).expotime = sOpt.expotime;
      else
         imgdata(i).expotime = 1;
      end
      showinfo(sprintf(['reading image file: %s, average count: ' ...
      '%6.1f'], imgdata(i).file, imgdata(i).mean));
   else
      disp(['WARNING:: image file:' imgdata(i).file ' does not exist!'])
   end
   % get the tag (TAG values are time averaged!!! So further
   % normalization by data collection time is still necessary)
   tags = get_tag(imgdata(i).file);
   imgdata(i).monnames = {'xflash', 'i1', 'i0', 'icesr'};
   imgdata(i).moncounts = tags([7,6,5,8]);
   if (sOpt.normalize ~= 0)
      imgdata(i).normconst = imgdata(i).moncounts(sOpt.normalize);
   else
      imgdata(i).normconst = 1;
   end
end

% 3) do corrections: dezinger, normalize

sumdata.dezinger = sOpt.dezinger;
sumdata.normalize = sOpt.normalize;
sumdata.datadir = sOpt.datadir;
sumdata.prefix = prefix;
sumdata.suffix = sOpt.suffix;

sumdata.imgnums = [imgdata(:).num];
sumdata.file = {imgdata.file};

if (sOpt.dezinger == 1)
   showinfo(['dezinger and sum together ...'])
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
   sumdata.normconst = [imgdata(:).normconst];
end
% 4) returning

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Change History:
%
% $Log: slurp_sg1kccd_0705cline.m,v $
% Revision 1.3  2013/08/19 03:02:26  xqiu
% *** empty log message ***
%
% Revision 1.2  2012/02/07 00:09:52  xqiu
% *** empty log message ***
%
% Revision 1.1.1.1  2007-09-19 04:45:39  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.1  2006/05/27 02:56:44  xqiu
% new tools added!
%
% Revision 1.2  2006/01/04 23:31:57  xqiu
% *** empty log message ***
%
% Revision 1.1  2005/12/11 22:45:25  xqiu
% rearrange the slurp routines on 12/09/2005.
%
% Revision 1.2  2005/12/08 06:21:09  xqiu
% *** empty log message ***
%
% Revision 1.1  2005/11/04 04:55:00  xqiu
% *** empty log message ***
%
% Revision 1.4  2005/11/03 00:16:00  xqiu
% *** empty log message ***
%
% Revision 1.3  2005/07/22 19:23:55  xqiu
% corresponding changes due to APBS package
%
% Revision 1.2  2005/06/09 01:54:51  xqiu
% *** empty log message ***
%
% Revision 1.1  2005/06/03 04:15:13  xqiu
% Adding the SAXS getiq routines
%
% Revision 1.1  2004/12/20 04:49:26  xqiu
% New members
%
% Revision 1.3  2004/11/19 05:04:27  xqiu
% Added comments
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
