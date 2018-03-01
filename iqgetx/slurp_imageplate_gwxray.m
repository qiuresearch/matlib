function [sumdata, imgdata] = slurp_imageplate_gwxray(prefix, scannums, ...
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
% $Id: slurp_imageplate_gwxray.m,v 1.9 2014/05/19 13:21:28 xqiu Exp $

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
   sOpt.suffix = '.mar2300';
   sOpt.dataformat = dataformat_guess(sOpt.suffix);
   sOpt.im_dark = 0;
end

% 1) initialize the data structure array

templ_struct = struct('datadir', '', 'prefix', '', 'num', 0, 'suffix', ...
                      sOpt.suffix, 'filename', '', 'dataformat', ...
                      [], 'im', 0.0);

suffix = sOpt.suffix;
if ~exist('scannums', 'var') || isempty(scannums)
   % if the file name is passed directly
   scannums = 0;
   num_imgs=1;
   imgdata = templ_struct;
   [imgdata.datadir, imgdata.prefix, imgdata.suffix] = fileparts(prefix);
   imgdata.imgnums = 0;
   imgdata.filename=prefix;
   specdata = [];
else % has scan number
   num_imgs = length(scannums);
   imgdata = repmat(templ_struct, 1, num_imgs);
   for i=1:num_imgs
      imgdata(i).prefix = prefix;
      imgdata(i).num = scannums(i);
      imgdata(i).imgnums = scannums(i);
      imgdata(i).filename = [sOpt.datadir sprintf('gw%04i_%s%s', ...
                         scannums(i), imgdata(i).prefix, suffix)];
      if ~exist(imgdata(i).filename, 'file')
         showinfo(['File: ' imgdata(i).filename ' not found! ' ...
                             'auto-searching using scannum ...']);
         filenames = dir([sOpt.datadir sprintf('gw%04i_', scannums(i)) ...
                          '*' suffix]);
         if isempty(filenames); continue; end
         if (length(filenames) > 1); showinfo(['found more than one ' ...
                                'match!']); end
         imgdata(i).filename = [sOpt.datadir filenames(1).name];
         showinfo(['Found file: ' imgdata(i).filename]);
      end
   end
end

% 3) load the data
for i=1:num_imgs
   if exist(imgdata(i).filename, 'file'); 
      [imgdata(i).im, imgdata(i).dataformat] = ...
          imread_any(imgdata(i).filename, sOpt.dataformat);
      imgdata(i).im = double(imgdata(i).im);
      if (sOpt.invertim == 1)
         imgdata(i).im = 2^16-1-imgdata(i).im;
      end
      if (length(sOpt.im_dark) ~=1) || (sOpt.im_dark ~= 0.0)
         imgdata(i).im = imgdata(i).im - sOpt.im_dark;
      end
      imgdata(i).mean = mean(imgdata(i).im(:));
      showinfo(['reading image file: ' imgdata(i).filename ', average ' ...
                          'count: ' num2str(imgdata(i).mean)]);
   else
      warning(['signums file:' imgdata(i).filename ' does not exist!'])
   end
   
   % check the existence of SPEC file for normalization
   imgdata(i).monnames = {'Detector', 'Time', 'Mean'};
   if isfield(sOpt, 'specdata') && ~isempty(sOpt.specdata)
      specdata = sOpt.specdata;
      iscan = find([specdata.scannum] == (scannums(i)));
      if isempty(iscan)
         showinfo(['Scan #' num2str(scannums(i)) ' is not found in ' ...
                   'SPEC file'], 'warning');
         imgdata(i).moncounts = [imgdata(i).mean,0,0];
      else
         iscan = iscan(end);
         showinfo(sprintf(['Extract monitor counts from SPEC data for ' ...
                        'scan #%0i(i=%0i)'], scannums(i), iscan));
         idetector = strmatch('DETECTOR', upper(specdata(iscan).columnnames), 'exact');
         itime = strmatch('TIME', upper(specdata(iscan).columnnames), 'exact');
         if isempty(itime)
            itime = strmatch('SECONDS', upper(specdata(iscan).columnnames), 'exact');
         end
         if ~isempty(specdata(iscan).data) && ~isempty(idetector)
            imgdata(i).expotime = specdata(iscan).data(end,itime);
            imgdata(i).moncounts = [total(specdata(iscan).data(:,idetector))*1e-6, ...
                                specdata(iscan).data(end,itime), ...
                                imgdata(i).mean];
         elseif isfield(specdata(iscan), 'beamstop')
            imgdata(i).moncounts = [imgdata(i).mean, 1, ...
                                imgdata(i).mean];
         end
      end
   end
   % dark current of the normalization constant
   if isfield(sOpt, 'normconst_dark')
      imgdata(i).normconst_dark = sOpt.normconst_dark;
   end
   % assign the normalization constant
   if (sOpt.normalize ~= 0) && isfield(imgdata(i), 'moncounts');
      imgdata(i).normconst = imgdata(i).moncounts(sOpt.normalize)-imgdata(i).normconst_dark;
   else
       imgdata(i).normconst = 1;
   end
end


% 4) do corrections: dezinger, normalize

sumdata = struct_assign(imgdata(1), sOpt, 'append', 1);
sumdata.filename = {imgdata.filename};
sumdata.imgnums = [imgdata(:).imgnums];
sumdata.normconst = [imgdata(:).normconst];

if (sOpt.dezinger == 1)
   showinfo('dezinger and sum together ...');
   if (num_imgs == 1)
      sumdata.im = 0.5*double(dezing(uint16(cat(3,imgdata(1).im, imgdata(1).im))));
   else 
      sumdata.im = double(dezing(uint16(cat(3,imgdata(:).im)))); 
   end
else
    sumdata.im = sum(cat(3, imgdata(:).im),3);
    %s display('skipping error in slurp line 138');
end

sumdata.mean = [imgdata(:).mean];
%sumdata.expotime = [imgdata(:).expotime];
if isfield(imgdata(1), 'moncounts')
   sumdata.monnames = imgdata(1).monnames;
   sumdata.moncounts = reshape([imgdata(:).moncounts], ...
                               length(sumdata.monnames), num_imgs)';
   sumdata.normconst = [imgdata(:).normconst];
end
