function [sumdata, imgdata] = slurp_flicam_0511gline(prefix, scannums, darknums, sOpt)
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
% $Id: slurp_flicam_0511gline.m,v 1.3 2013/08/19 03:02:25 xqiu Exp $

verbose = 1;
if nargin < 1
   error('at least one parameter is required, please see the usage! ')
   help slurq_flicam_0511gline
   return
end

% setup the default sOpt (if provided, MUST have all fields!)
if nargin < 4
   sOpt.dezinger = 0;
   sOpt.normalize = 0;
   sOpt.readraw = 0;  % whether to read the raw images or corrected
   sOpt.datadir = '';
   sOpt.suffix = '_cz.tif';
   sOpt.im_dark = 100;
end

if (nargin > 2) && ~isempty(darknums) % if darknums is passed, use it!
   dezinger = sOpt.dezinger;
   normalize = sOpt.normalize;
   sOpt.normalize = 0; % no normalization for dark images
   sOpt.dezinger = 1;  % always dezinger dark images
   sOpt.readraw = 1;   % always read raw images
   sOpt.im_dark = 0;
   darkdata = slurp_flicam_0511gline(prefix, darknums, [], sOpt);
   sOpt.normalize = normalize;
   sOpt.dezinger = dezinger;
   sOpt.im_dark = darkdata.im / length(darknums);
   clear darkdata
end

suffix = sOpt.suffix;

% 1) initialize the data structure array

templ_struct = struct('prefix', '', 'num', 0, 'suffix', sOpt.suffix, ...
                      'file', '', 'im', 0.0);

if ~exist('scannums', 'var') || isempty(scannums)
   % if the file name is passed directly
   scannums = 0;
   num_imgs=1;
   imgdata = templ_struct;
   [dummy, imgdata.prefix] = fileparts(prefix);
   imgdata.num = 0;
   imgdata.file=[sOpt.datadir prefix];
   specdata = [];
else % has scan number
   if (sOpt.readraw == 1) % read every raw file (assume only one
                          % scan to read!!!)
      prefix2 = [prefix sprintf('%03i_', scannums)];
      num_imgs = length(dir([prefix2 '0*' suffix]));
      signums = 0:(num_imgs-1);
      imgdata = repmat(templ_struct, 1, num_imgs);
      for i=1:num_imgs
         imgdata(i).prefix = prefix2;;
         imgdata(i).num = signums(i);
         imgdata(i).file = [sOpt.datadir imgdata(i).prefix ...
                            sprintf('%03i', signums(i)) suffix];
      end
   end

   if (sOpt.readraw == 0) % read the corrected image
      num_imgs = length(scannums);
      imgdata = repmat(templ_struct, 1, num_imgs);
      for i=1:num_imgs
         imgdata(i).prefix = prefix;
         imgdata(i).num = scannums(i);
         imgdata(i).file = [sOpt.datadir imgdata(i).prefix ...
                            sprintf('%03i', scannums(i)) suffix];
      end
   end

   % check the existence of SPEC file for normalization
   specfile = [sOpt.datadir strrep(prefix, '_', '')];
   specdata = specdata_readfile(specfile); % read the SPEC file
   if ~isempty(specdata)
      itime = strmatch('SECONDS', upper(specdata(1).columnnames), 'exact');
      
      monnames = {'gdoor' 'i0', 'i1', 'i2'};
      igdoor = strmatch('GDOOR', upper(specdata(1).columnnames), 'exact');
      ii0 = strmatch('I0',  upper(specdata(1).columnnames), 'exact');
      ii1 = strmatch('I1',  upper(specdata(1).columnnames), 'exact');
      ii2 = strmatch('I2',  upper(specdata(1).columnnames), 'exact');
      ii0 = ii0(1);
   end
end


% 3) load the data, and the spec file into the structure fields
for i=1:num_imgs
   if exist(imgdata(i).file, 'file'); 
      imgdata(i).im = double(imread(imgdata(i).file));
      if (length(sOpt.im_dark) ~=1) || (sOpt.im_dark ~= 0.0)
         imgdata(i).im = imgdata(i).im - sOpt.im_dark;
      end
      imgdata(i).mean = mean(imgdata(i).im(:));
      showinfo(['reading image file: ' imgdata(i).file ', average ' ...
                          'count: ' num2str(imgdata(i).mean) ]);
   else
      warning(['signums file:' imgdata(i).file ' does not exist!'])
   end
   
   % Get counts from SPEC files
   if ~isempty(specdata)

      imgdata(i).monnames = monnames;

      if (sOpt.readraw == 1) % images are all in one scan
         iscan = find([specdata.scannum] == (scannums));
         if ~isempty(iscan)
            imgdata(i).expotime = specdata(iscan).data(i,itime);
            imgdata(i).moncounts = [specdata(iscan).data(i,igdoor), ...
                                specdata(iscan).data(i,ii0), ...
                                specdata(iscan).data(i,ii1), ...
                                specdata(iscan).data(i,ii2)];
         end
      end
      
      if (sOpt.readraw == 0)
         iscan = find([specdata.scannum] == (scannums(i)));
         if ~isempty(iscan)
            imgdata(i).expotime = sum(specdata(iscan).data(:,itime));
            imgdata(i).moncounts = [sum(specdata(iscan).data(:,igdoor)), ...
                                sum(specdata(iscan).data(:,ii0)), ...
                                sum(specdata(iscan).data(:,ii1)), ...
                                sum(specdata(iscan).data(:,ii2))];
         end
      end
   end % if ~isempty(specdata)
   
   if (sOpt.normalize ~= 0)
      imgdata(i).normconst = imgdata(i).moncounts(sOpt.normalize);
   else
      imgdata(i).normconst = 1;
   end
end

% 4) do corrections: dezinger, normalize

if nargin < 4
   sOpt.dezinger = 0;
   sOpt.normalize = 0;
   sOpt.readraw = 0;  % whether to read the raw images or corrected
   sOpt.datadir = '';
   sOpt.suffix = '_cz.tif';
   sOpt.im_dark = 100;
end
sumdata.dezinger = sOpt.dezinger;
sumdata.normalize = sOpt.normalize;
sumdata.readraw = sOpt.readraw;
sumdata.datadir = sOpt.datadir;
sumdata.prefix = prefix;
sumdata.suffix = sOpt.suffix;

sumdata.imgnums = [imgdata(:).num];
sumdata.file = {imgdata.file};

if (sOpt.dezinger == 1)
   disp(['SLURPADSC_XQ\> dezinger and sum together ...'])
   if (num_imgs == 1)
      sumdata.im = 0.5*double(dezing(uint16(cat(3,imgdata(1).im, imgdata(1).im))));
   else 
      sumdata.im = double(dezing(uint16(cat(3,imgdata(:).im)))); 
   end
else
    sumdata.im = sum(cat(3, imgdata(:).im),3);
end

sumdata.mean = [imgdata(:).mean];
sumdata.expotime = [imgdata(:).expotime];
if isfield(imgdata(1), 'moncounts')
   sumdata.monnames = imgdata(1).monnames;
   sumdata.moncounts = reshape([imgdata(:).moncounts], ...
                               length(sumdata.monnames), num_imgs)';
   sumdata.normconst = [imgdata(:).normconst];
end
   

% 5) return

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Change History:
%
% $Log: slurp_flicam_0511gline.m,v $
% Revision 1.3  2013/08/19 03:02:25  xqiu
% *** empty log message ***
%
% Revision 1.2  2012/02/07 00:09:51  xqiu
% *** empty log message ***
%
% Revision 1.1.1.1  2007-09-19 04:45:39  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.3  2006/01/04 23:31:57  xqiu
% *** empty log message ***
%
% Revision 1.2  2005/12/11 22:45:25  xqiu
% rearrange the slurp routines on 12/09/2005.
%
% Revision 1.1  2005/12/08 06:21:09  xqiu
% *** empty log message ***
%
% Revision 1.1  2005/11/04 04:55:00  xqiu
% *** empty log message ***
%
% Revision 1.4  2004/12/20 04:48:29  xqiu
% minor changes only
%
% Revision 1.3  2004/11/19 05:04:27  xqiu
% Added comments
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
