function [result, sigs] = slurpadsc_xq(prefix, signums, sOpt)
% --- Usage:
%        [result, sigs] = slurpadsc_xq(prefix, signums, sOpt)
%           a derivation from Lisa's slurpadsc routine
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
% $Id: slurp_adsc_0411gline.m,v 1.3 2013/08/19 03:02:25 xqiu Exp $
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
   help slurqadsc_xq
   return
end

% setup the default sOpt (if provided, MUST have all fields!)
if nargin < 3
   sOpt.dezinger_isa = 1;
   sOpt.normalize_isa = 1;
   sOpt.suffix = '.img';
end

suffix = sOpt.suffix;
result = sOpt;

% 1) initialize the data structure array

templ_struct = struct('prefix', '', 'file', '', 'im', 0.0, 'i0', ...
                      1.0, 'i1', 1.0, 'gdoor', 1.0, 'time', 1.0);
if (nargin > 1) && ~isempty(signums)
   num_sigs = length(signums);
   sigs = repmat(templ_struct, 1, num_sigs);
   for i=1:num_sigs
      sigs(i).prefix = [prefix sprintf('%03i', signums(i))];
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
   if exist(sigs(i).file, 'file'); 
      disp(['SLURPADSC_XQ\> reading image file: ' sigs(i).file])
      sigs(i).im = adsctake(sigs(i).file);
   else
      warning(['signums file:' sigs(i).file ' does not exist!'])
   end
   % check whether SPEC file exists
   specfile = [sigs(i).file '.spec'];
   if exist(specfile, 'file')
      specdata = specdata_readfile(specfile); % read the SPEC file
      % search for "gdoor" value
      itime = 0;
      for k = 1:length(specdata)
         itemp = strmatch('TIME', upper(specdata(k).columnnames), 'exact');
         if ~isempty(itemp) % found a match of "TIME"
            if (itime ~= 0); 
               disp(['WARNING:: More than one TIME scans found in ' specfile]);
               disp('  only the last found scan is used!')
            end
            ispec = k;
            itime = itemp;
         end
      end
      if exist('ispec') % found the target scan
         sigs(i).expotime = specdata(ispec).data(1, itime);
         igdoor = strmatch('GDOOR', upper(specdata(ispec).columnnames), ...
                                          'exact');
         if ~isempty(igdoor) % "gdoor" field found!
            sigs(i).gdoor = specdata(ispec).data(1, igdoor);
            disp(['SLURPADSC_XQ\> gdoor value found: ' int2str(sigs(i).gdoor)])
         end
      end
      
   end % if exist(specfile, 'file')
end

% 3) do corrections: dezinger, normalize

if sOpt.dezinger_isa == 1
   disp(['SLURPADSC_XQ\> dezinger and sum together ...'])
   if num_sigs == 1
      sigdata = 0.5*double(dezing(uint16(cat(3,sigs(1).im, sigs(1).im))));
   else 
      sigdata = double(dezing(uint16(cat(3,sigs(:).im)))); 
   end
end

gdoor_total = sum([sigs(:).gdoor]);
result.gdoor = gdoor_total;
if (sOpt.normalize_isa == 1) && (gdoor_total ~= 1.0) && (gdoor_total ~= 0.0)
   sigdata(:,:) = 1.0/gdoor_total * sigdata;
   disp(['SLURPADSC_XQ\> normalized by gdoor_total=' int2str(gdoor_total)])
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
% $Log: slurp_adsc_0411gline.m,v $
% Revision 1.3  2013/08/19 03:02:25  xqiu
% *** empty log message ***
%
% Revision 1.2  2012/02/07 00:09:51  xqiu
% *** empty log message ***
%
% Revision 1.1.1.1  2007-09-19 04:45:39  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.1  2005/12/08 03:10:56  xqiu
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
