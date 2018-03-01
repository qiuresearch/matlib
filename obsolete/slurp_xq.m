function [result, sigs] = slurp_xq(prefix, signums, sOpt)
% --- Usage:
%        [result, sigs] = slurpadsc_xq(prefix, signums, sOpt)
%           a derivation from Lisa's slurp routine
%
% --- Purpose:
%        read in the image files (adsctake), and dezinger (dezing),
%        normalize (by gdoor value in SPEC file), average.
% --- Parameter(s):
%     
% --- Return(s): 
%        results - 
%
% --- Example(s):
%
% $Id: slurp_xq.m,v 1.2 2012/02/07 00:09:52 xqiu Exp $
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


if nargin < 1
   error('at least one parameter is required, please see the usage! ')
   help slurp_xq
   return
end

% setup the default sOpt (if provided, MUST have all fields!)
if nargin < 3
   sOpt.dezinger_isa = 1;
   sOpt.normalize_isa = 1;
   sOpt.suffix = '.tif';
   sOpt.im_dark = 0;
end

suffix = sOpt.suffix;
result = sOpt;
result.signums=signums;

% 1) initialize the data structure array

templ_struct = struct('prefix', '', 'file', '', 'im', 0.0, 'i0', ...
                      1.0, 'i1', 1.0, 'xflash', 1.0, 'time', 1.0);
if (nargin > 1) && ~isempty(signums)
   num_sigs = length(signums);
   sigs = repmat(templ_struct, 1, num_sigs);
   for i=1:num_sigs
      sigs(i).prefix = [prefix sprintf('%i',signums(i))];
      sigs(i).file = [sigs(i).prefix suffix];
   end
else % if the file name is passed directly
   num_sigs=1;
   sigs = templ_struct;
   sigs.file=prefix;
   [dummy, sigs.prefix] = fileparts(sigs.file);
end

% 2) load the data, and the spec file into the structure fields

for i=1:num_sigs
   % read the image file, and do CORRECT and dark image subtraction
   if exist(sigs(i).file, 'file'); 
      sigs(i).im = double(imread(sigs(i).file, 'tif'));
      sigs(i).im(:,:) = correct(sigs(i).im);
      if isfield(sOpt, 'im_dark') && (length(sOpt.im_dark) > 0)
         sigs(i).im(:,:) = sigs(i).im - sOpt.im_dark;
      end
      sigs(i).mean = mean(sigs(i).im(:));
      disp(sprintf('SLURP_XQ\\> reading image file: %s, average count: %6.1f', sigs(i).file, sigs(i).mean))    
   else
      disp(['WARNING:: signums file:' sigs(i).file ' does not exist!'])
   end
   % get the tag (TAG values are time averaged!!!)
   tags = get_tag(sigs(i).file);
   sigs(i).i0 = tags(1);
   sigs(i).i1 = tags(2);
   sigs(i).xflash = tags(8);
end

% 3) do corrections: dezinger, normalize

if sOpt.dezinger_isa == 1
   disp(['SLURP_XQ\> dezinger and sum together ...'])
   if num_sigs == 1
      sigdata = 0.5*double(dezing(uint16(cat(3,sigs(1).im, sigs(1).im))));
   else 
      sigdata = double(dezing(uint16(cat(3,sigs(:).im)))); 
   end
end

xflash_total = sum([sigs(:).xflash]);
result.xflash = xflash_total;
if (sOpt.normalize_isa == 1) && (xflash_total ~= 1.0) && (xflash_total ~= 0.0)
   sigdata(:,:) = 1.0/xflash_total * sigdata;
   disp(['SLURP_XQ\> normalized by xflash_total=' int2str(xflash_total)])
end

% 4) return

result.im = sigdata;
result.tag =1 ;

if nargout == 2 % dezinger each image if to be retured as well
   for i=1:num_sigs
      % note: this is crossed out because the dezinger doesn't seem
      % to work well when only one image is existing.
%      sigs(i).im = 0.5*double(dezing(uint16(cat(3,sigs(i).im, ...
%                                               zeros(size(sigs(i).im))))));
   end
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Change History:
%
% $Log: slurp_xq.m,v $
% Revision 1.2  2012/02/07 00:09:52  xqiu
% *** empty log message ***
%
% Revision 1.1.1.1  2007-09-19 04:45:38  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.2  2005/06/03 04:15:13  xqiu
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
