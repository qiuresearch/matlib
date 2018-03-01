function [sumdata, imgdata] = slurp_flicam_0602gline(prefix, scannums, darknums, sOpt)
% --- Usage:
%        [sumdata, imgdata] = slurpadsc_flicam_0602gline(prefix,
%                                             scanums, darknums, sOpt)
%           a derivation from Lisa's slurpadsc routine
%
% --- Purpose:
%        read in the image files (imread), and dezinger (dezing),
%        normalize (by gdoor value in SPEC file), average. Steps:
%
%           1) set default options "sOpt" if not passed.
%
%           2) sOpt.readraw determines whether to read each image
%           or the corrected/dezingered data provided by Arthur.
%
%           3) if "readraw == 1", only one scannums is
%           supported. Sub-images are searched for automatically. If
%           "readraw == 0", mutiple scans can be read. Each scan is
%           the smallest unit now. 
%
%           4) the SPEC file containing the monitor counts is read in,
%           and the corresponding scan numbers are looked for. If
%           "readraw ==0", the monitor counts are summed.
%
%           5) the images "imgdata" are merged together to "sumdata",
%           including the sub-fields. 
%
%           6) dezinger if necessary. assign the correct "normconst"
%           values depending on the "normalize" setting. 
%
%           7) if "darknums" passed, read it first. Use the result as
%           the dark immage to subtract. Otherwise, do not do
%           subtraction.
%
% --- Parameter(s):
%     
% --- Return(s): 
%        sumdatas - 
%
% --- Example(s):
%
% $Id: slurp_flicam_0602gline.m,v 1.3 2013/08/19 03:02:25 xqiu Exp $

verbose = 1;
if nargin < 1
   error('at least one parameter is required, please see the usage! ')
   help slurq_flicam_0602gline
   return
end

% setup the default sOpt (if provided, MUST have all fields!)
if nargin < 4
   sOpt.dezinger = 0;
   sOpt.correct = 1;   % intensity and distortion correction?
   sOPt.lblcorrect = 0;% line by line correction? 
   sOPt.setzero = 1;   % 
   sOpt.normalize = 0;
   sOpt.readraw = 0;   % whether to read the raw images or corrected
   sOpt.datadir = '';
   sOpt.suffix = '_cz.tif';
   sOpt.im_dark = 100;
end

if (nargin > 2) && ~isempty(darknums) % if darknums is passed, use it!
   sOpt2 = sOpt;
   sOpt2.dezinger = 1;  % always dezinger dark images
   sOpt2.correct = 0;   % no intensity/distortion correction
   sOpt2.lblcorrect = 1;% do line by line correction too
   sOpt2.setzero = 0;   % do line by line correction too
   sOpt2.normalize = 0; % no normalization for dark images
   sOpt2.readraw = 1;   % always read raw images
   sOpt2.im_dark = 0;   % no dark subtraction for dark images
   darkdata = slurp_flicam_0602gline(prefix, darknums, [], sOpt2);
   
   sOpt.im_dark = darkdata.im / length(darkdata.imgnums);
   sOpt.moncounts_dark = mean(darkdata.moncounts, 1); % assume same
                                                      % exposure time
   clear darkdata sOpt2;
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
      num_imgs = length(dir([prefix2 '0*' suffix])); %assume less than 
      signums = 0:(num_imgs-1);
      imgdata = repmat(templ_struct, 1, num_imgs);
      for i=1:num_imgs
         imgdata(i).prefix = prefix2;;
         imgdata(i).num = scannums + signums(i)/num_imgs*2;
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
      iscan = find([specdata.scannum] == (scannums(1)));
      itime = strmatch('SECONDS', upper(specdata(iscan).columnnames), 'exact');
      
      monnames = {'gdoor' 'i0', 'i1', 'i2'};
      igdoor = strmatch('GDOOR', upper(specdata(iscan).columnnames), 'exact');
      ii0 = strmatch('I0',  upper(specdata(iscan).columnnames), 'exact');
      ii1 = strmatch('I1',  upper(specdata(iscan).columnnames), 'exact');
      ii2 = strmatch('I2',  upper(specdata(iscan).columnnames), 'exact');
      ii0 = ii0(1);
   end
end


% 3) load the data, and the spec file into the structure fields
mean_im_dark = mean(sOpt.im_dark(:));
for i=1:num_imgs
   if exist(imgdata(i).file, 'file'); 
      imgdata(i).im = double(imread(imgdata(i).file));
      imgdata(i).mean = mean(imgdata(i).im(:)) - mean_im_dark;
      showinfo(['reading image file: ' imgdata(i).file ', average ' ...
                'est.: ' num2str(imgdata(i).mean)]);
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
            imgdata(i).im = imgdata(i).im * ...
                length(specdata(iscan).data(:,itime));
            imgdata(i).expotime = sum(specdata(iscan).data(:,itime));
            imgdata(i).moncounts = [sum(specdata(iscan).data(:,igdoor)), ...
                                sum(specdata(iscan).data(:,ii0)), ...
                                sum(specdata(iscan).data(:,ii1)), ...
                                sum(specdata(iscan).data(:,ii2))];
            if isfield('sOpt', 'moncounts_dark')
               imgdata(i).moncounts_dark = sOpt.moncounts_dark;
               imgdata(i).moncounts(igdoor) = imgdata(i).moncounts(igdoor) ...
                   - sOpt.moncounts_dark(igdoor);
            end
         end
      end
   end % if ~isempty(specdata)
   
   if (sOpt.normalize ~= 0)
      imgdata(i).normconst = imgdata(i).moncounts(sOpt.normalize);
   else
      imgdata(i).normconst = 1;
   end
end

% 4) sum the images and dezinger if applicable

%  % if want to do line by line of each image first do it here:
%  
%  for i=1:length(imgdata)
%     imgdata(i).im = lblcorrect_flicam(imgdata(i).im, 'setzero', 0);
%  end
%  
sumdata.dezinger = sOpt.dezinger;
sumdata.normalize = sOpt.normalize;
sumdata.readraw = sOpt.readraw;
sumdata.datadir = sOpt.datadir;
sumdata.prefix = prefix;
sumdata.suffix = sOpt.suffix;

sumdata.imgnums = [imgdata(:).num];
sumdata.file = {imgdata.file};

if (sOpt.dezinger == 1)
   showinfo(['dezinger and sum together ...'])
   if (num_imgs == 1)
      sumdata.im = 0.5*double(dezing(uint16(cat(3,imgdata(1).im, imgdata(1).im))));
   else 
      sumdata.im = double(dezing(uint16(cat(3,imgdata(:).im)))); 
   end
else
    sumdata.im = sum(cat(3, imgdata(:).im),3);
end

if isfield(imgdata(1), 'mean')
   sumdata.mean = [imgdata(:).mean];
end
if isfield(imgdata(1), 'time')
   sumdata.expotime = [imgdata(:).expotime];
end
if isfield(imgdata(1), 'moncounts')
   sumdata.monnames = imgdata(1).monnames;
   sumdata.moncounts = reshape([imgdata(:).moncounts], ...
                               length(sumdata.monnames), num_imgs)';
   sumdata.normconst = [imgdata(:).normconst];
end

% 5) dark , line by line, intensity/distortion correction 

% dark image subtraction
if (length(sOpt.im_dark) ~=1) || (sOpt.im_dark ~= 0.0)
   sumdata.im(:,:) = sumdata.im(:,:) - sOpt.im_dark* ...
       length(imgdata);
   for i=1:length(imgdata)
      imgdata(i).im = imgdata(i).im - sOpt.im_dark;
   end
end

% line by line correction
if isfield(sOpt, 'lblcorrect') && (sOpt.lblcorrect == 1)
   showinfo(['doing line by line flicam correction, setzero:' ...
             num2str(sOpt.setzero), ' ...']);
   sumdata.im(:,:) = lblcorrect_flicam(sumdata.im, 'setzero', sOpt.setzero);
   for i=1:length(imgdata)
      imgdata(i).im = lblcorrect_flicam(imgdata(i).im, 'setzero', ...
                                        sOpt.setzero);
      imgdata(i).mean = mean(imgdata(i).im(:));
   end
end

% intensity/distortion correction
if isfield(sOpt,'correct') && (sOpt.correct == 1)
   showinfo('doing intensity and distortion correction ...');
   sumdata.im = correct(sumdata.im);
   for i=1:length(imgdata)
      imgdata(i).im = correct(imgdata(i).im);
      imgdata(i).mean = mean(imgdata(i).im(:));
   end
end
