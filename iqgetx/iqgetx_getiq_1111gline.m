function [iq, sIqgetx] = iqgetx_getiq_1111gline(sIqgetx, startnum, skipnums, sOpt)
% --- Usage:
%        [iq, sIqgetx] = iqgetx_getiq(sIqgetx, startnum, skipnums, sOpt)
% --- Purpose:
%        read in the data images and process them to get I(Q). 
%        Two variations are possible: 
%             1) one buffer; and 2) two buffer (before and after)
%
% --- Parameter(s):
%        sIqgetx  - the structure as defined in iqgetx_init()
%        startnum - the starting image number 
%        skipnums - image numbers to skip
%        sOpt     - a structure to pass on options, e.g., dezinger,
%        normalize, etc..
%     
% --- Return(s): 
%        iq      - the final I(Q) of sIqgetx(1) only
%        sIqgetx - the full structure with processed data
%
% --- Example(s):
%
% $Id: iqgetx_getiq_1111gline.m,v 1.5 2013/08/23 18:52:47 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename;
   eval(['help ' funcname]);
   return
end

% 2) set default behaviors
if isstr(sIqgetx) % file prefix is passed
    prefix = sIqgetx;
    sIqgetx = iqgetx_init('twobuf');
    sIqgetx.samprefix = prefix;
    sIqgetx.bufprefix = prefix;
end
if (nargin > 1) && ~isempty(startnum)
    sIqgetx.startnum = startnum;
end
if (nargin > 2) && ~isempty(skipnums)
    sIqgetx.skipnums = skipnums;
end
if (nargin > 3)
    sIqgetx = struct_assign(sOpt, sIqgetx);
end

% 3) action
num_data = length(sIqgetx);
for i=1:num_data
   % compute the run numbers for dark, buf1, sam, buf2
   if (sIqgetx(i).runnums_autogen == 1)
      % image numbers for dark
      if (sIqgetx(i).run_config(1) == 0)
         sIqgetx(i).darknums = [];
      else
         sIqgetx(i).darknums = sIqgetx(i).startnum: ...
             (sIqgetx(i).startnum+sIqgetx(i).run_config(1)-1);
         if ~isempty(sIqgetx(i).skipnums)
            sIqgetx(i).darknums = setdiff(sIqgetx(i).darknums, ...
                                          sIqgetx(i).skipnums);
         end
      end
      % image numbers for buf or buf1 (depending on one/two buffer)
      if isfield(sIqgetx(i), 'bufnums') % one buffer setup
         if (sIqgetx(i).run_config(2) == 0)
            sIqgetx(i).bufnums = [];
         else
            sIqgetx(i).bufnums = sIqgetx(i).startnum+ ...
                sIqgetx(i).run_config(1):(sIqgetx(i).startnum+ ...
                                          sum(sIqgetx(i).run_config(1:2))-1);
            if ~isempty(sIqgetx(i).skipnums)
               sIqgetx(i).bufnums = setdiff(sIqgetx(i).bufnums, ...
                                            sIqgetx(i).skipnums);
            end
         end
      else
         if (sIqgetx(i).run_config(2) == 0)
            sIqgetx(i).buf1nums = [];
         else
            sIqgetx(i).buf1nums = sIqgetx(i).startnum+ ...
                sIqgetx(i).run_config(1):(sIqgetx(i).startnum+ ...
                                          sum(sIqgetx(i).run_config(1:2))-1);
            if ~isempty(sIqgetx(i).skipnums)
               sIqgetx(i).buf1nums = setdiff(sIqgetx(i).buf1nums, ...
                                             sIqgetx(i).skipnums);
            end
         end
      end
      % image numbers for sam
      if (sIqgetx(i).run_config(3) == 0)
         sIqgetx(i).samnums = [];
      else
         sIqgetx(i).samnums = sIqgetx(i).startnum+ ...
             sum(sIqgetx(i).run_config(1:2)):(sIqgetx(i).startnum+ ...
                                              sum(sIqgetx(i).run_config(1:3))-1);
         if ~isempty(sIqgetx(i).skipnums)
            sIqgetx(i).samnums = setdiff(sIqgetx(i).samnums, ...
                                         sIqgetx(i).skipnums);
         end
      end
      % image numbers for buf2 or buf
      if isfield(sIqgetx(i), 'bufnums')
         if (sIqgetx(i).run_config(4) == 0)
            % do nothing
         else
            sIqgetx(i).bufnums = [sIqgetx(i).bufnums, sIqgetx(i).startnum+ ...
                                sum(sIqgetx(i).run_config(1:3)): ...
                                (sIqgetx(i).startnum+ ...
                                 sum(sIqgetx(i).run_config(1:4))-1)];
            if ~isempty(sIqgetx(i).skipnums)
               sIqgetx(i).bufnums = setdiff(sIqgetx(i).bufnums, ...
                                            sIqgetx(i).skipnums);
            end
         end
      else
         if (sIqgetx(i).run_config(4) == 0)
            sIqgetx(i).buf2nums = [];
         else
            sIqgetx(i).buf2nums = sIqgetx(i).startnum+ ...
                sum(sIqgetx(i).run_config(1:3)):(sIqgetx(i).startnum+ ...
                                                 sum(sIqgetx(i).run_config(1:4))-1);
            if ~isempty(sIqgetx(i).skipnums)
               sIqgetx(i).buf2nums = setdiff(sIqgetx(i).buf2nums, ...
                                             sIqgetx(i).skipnums);
            end
         end
      end
   end
   
   % choose the correct slurp routine
   switch sIqgetx(i).dataformat
      case 'SG1KCCD'
         slurp_saxsimg = @slurp_sg1kccd_0705cline;
      case 'FLICAM'
         slurp_saxsimg = @slurp_flicam_1111gline;
      case 'MarCCD'
         slurp_saxsimg = @slurp_marccd_0802nsls;
      case 'ADSC'
         slurp_saxsimg = @slurpadsc_xq;           
      otherwise
   end
   
   % read the dark image and save it to the sIqgetx structure
   if ~isempty(sIqgetx(i).darknums) && (sIqgetx(i).darksub == 1)
      sIqgetxtmp = sIqgetx(i);
      sIqgetxtmp.im_dark = 0;
      sIqgetxtmp.moncounts_dark = 0;
      sIqgetxtmp.normconst_dark = 0;
      
      % different settings for dark
      sIqgetxtmp.dezinger = 1;  % always dezinger dark images
      sIqgetxtmp.correct = 0;   % no intensity/distortion correction
      sIqgetxtmp.lblcorrect = 0;% no line by line correction
      sIqgetxtmp.setzero = 0;   % no line by line correction
      sIqgetxtmp.readraw = 1;   % always read raw images
      
      darkdata = feval(slurp_saxsimg, sIqgetx(i).samprefix, ...
                       sIqgetx(i).darknums, [], sIqgetxtmp);
      
      sIqgetx(i).im_dark = darkdata.im/length(darkdata.imgnums);
      sIqgetx(i).moncounts_dark = mean(darkdata.moncounts,1);
      sIqgetx(i).normconst_dark = total(darkdata.normconst)/length(darkdata.normconst);
      clear sIqgetxtmp
   end
   
   %  read the signals and integrate them
   for datatype=1:3
      if isfield(sIqgetx(i), 'bufnums'); 
         switch datatype
            case 1 % buf
               imgnums = sIqgetx(i).bufnums;
               prefix = sIqgetx(i).bufprefix;
            case 2 % sam
               imgnums = sIqgetx(i).samnums;
               prefix = sIqgetx(i).samprefix;
            case 3
               continue
         end
      else
         switch datatype
            case 1 % buf1
               imgnums = sIqgetx(i).buf1nums;
               prefix = sIqgetx(i).bufprefix;
            case 2 % sam
               imgnums = sIqgetx(i).samnums;
               prefix = sIqgetx(i).samprefix;
            case 3 % buf2
               imgnums = sIqgetx(i).buf2nums;
               prefix= sIqgetx(i).bufprefix;
         end
      end
      
      % ----- The difference in this specific routine here!!!!! ------
      
      if (sIqgetx(i).readraw == 0) % read corrected scans
         [sumdata, imgdata] = feval(slurp_saxsimg, prefix, imgnums, ...
                                    [], sIqgetx(i));
      else % have to read each scan one by one
         [sumdata, imgdata] = feval(slurp_saxsimg, prefix, imgnums(1), ...
                                    [], sIqgetx(i));
         for iimg=2:length(imgnums)
            [sumdatatmp, imgdatatmp] = feval(slurp_saxsimg, prefix, ...
                                             imgnums(iimg), [], sIqgetx(i));
            imgdata = [imgdata, imgdatatmp];
            sumdata.imgnums = [sumdata.imgnums, sumdatatmp.imgnums];
            sumdata.file = {sumdata.file{:}, sumdatatmp.file{:}};
            sumdata.im = sumdata.im + sumdatatmp.im;
            sumdata.mean = [sumdata.mean, sumdatatmp.mean];
            sumdata.expotime = [sumdata.expotime, sumdatatmp.expotime];
            sumdata.moncounts = [sumdata.moncounts; sumdatatmp.moncounts];
            sumdata.normconst = [sumdata.normconst, sumdatatmp.normconst];
         end
      end
      
      % ----- end of the difference -------
      
      % get I(q) -- integration
      sumdata.iq= integrater(sumdata.im, 'pixel');
      for k=1:length(imgdata) % individual ones are not dezingered
         imgdata(k).iq = integrater(imgdata(k).im, 'pixel');
      end
      
      has_error = size(sumdata.iq, 2) > 2;
      
      % normalization
      if (sumdata.normalize ~= 0) && (sum(sumdata.normconst) ~= 0.0)
         sumdata.iq(:,[2,4]) = 1.0/sum(sumdata.normconst)*sumdata.iq(:,[2,4]);
         if isfield(sumdata, 'monnames')
            showinfo(['normalized by ' sumdata.monnames{sumdata.normalize} ...
                   ' total = ' int2str(sum(sumdata.normconst))]);
         else
            showinfo(['normalized by total = ' int2str(sum(sumdata.normconst))]);
         end
         
         for k=1:length(imgdata)
            imgdata(k).iq(:,[2,4]) = 1.0/sum(imgdata(k).normconst) * ...
                imgdata(k).iq(:,[2,4]);
         end
      end
      
      % remove all im data
      if (sIqgetx(i).keep_im == 0)
         sumdata.im = [];
         [imgdata(:).im] = deal([]);
      end
      
      if isfield(sIqgetx(i), 'bufnums')
         switch datatype
            case 1 % buf
               sIqgetx(i).buf = sumdata; 
               sIqgetx(i).bufimgs = imgdata;
            case 2 % sam
               sIqgetx(i).sam = sumdata;
               sIqgetx(i).samimgs = imgdata;
         end
      else
         switch datatype
            case 1 % buf1
               sIqgetx(i).buf1 = sumdata; 
               sIqgetx(i).buf1imgs = imgdata;
            case 2 % sam
               sIqgetx(i).sam = sumdata;
               sIqgetx(i).samimgs = imgdata;
            case 3 % buf2
               sIqgetx(i).buf2 = sumdata;
               sIqgetx(i).buf2imgs = imgdata;
         end       
      end
   end
   
   % remove the dark image matrix
   if (sIqgetx(i).keep_im == 0) 
      sIqgetx(i).im_dark = sIqgetx(i).im_dark(1);
   end

   % get total buffer I(Q) if two buffers
   if ~isfield(sIqgetx(i), 'bufnums')
      sIqgetx(i).buf.dezinger = sIqgetx(i).buf1.dezinger;
      sIqgetx(i).buf.normalize = sIqgetx(i).buf1.normalize;
      sIqgetx(i).buf.datadir = sIqgetx(i).buf1.datadir;
      sIqgetx(i).buf.imgnums = [sIqgetx(i).buf1.imgnums, ...
                          sIqgetx(i).buf2.imgnums];  
      sIqgetx(i).buf.file = {sIqgetx(i).buf1.file{:}, sIqgetx(i).buf2.file{:}};
      if (sIqgetx(i).keep_im == 0)
         sIqgetx(i).buf.im = [];
      else
         sIqgetx(i).buf.im = sIqgetx(i).buf1.im + sIqgetx(i).buf2.im;
      end
      
      sIqgetx(i).buf.mean = [sIqgetx(i).buf1.mean, sIqgetx(i).buf2.mean];

      sIqgetx(i).buf.normconst = [sIqgetx(i).buf1.normconst, ...
                          sIqgetx(i).buf2.normconst];

      if isfield(sIqgetx(i).buf1, 'expotime')
         sIqgetx(i).buf.expotime = [sIqgetx(i).buf1.expotime, sIqgetx(i).buf2.expotime];
         sIqgetx(i).buf.monnames = sIqgetx(i).buf1.monnames;
         sIqgetx(i).buf.moncounts = [sIqgetx(i).buf1.moncounts; ...
                             sIqgetx(i).buf2.moncounts];
      end
      
      sIqgetx(i).buf.iq = sIqgetx(i).buf1.iq;
      
      if (sIqgetx(i).normalize ~= 0)
         sIqgetx(i).buf.iq(:,2) = (sIqgetx(i).buf1.iq(:,2)* ...
             sum(sIqgetx(i).buf1.normconst) + sIqgetx(i).buf2.iq(:,2)* ...
             sum(sIqgetx(i).buf2.normconst))/sum(sIqgetx(i).buf.normconst);
     
         if has_error
         sIqgetx(i).buf.iq(:,3:4) = sqrt( (sIqgetx(i).buf1.iq(:,3:4)* ...
            sum(sIqgetx(i).buf1.normconst)).^2 + (sIqgetx(i).buf2.iq(:,3:4)* ...
            sum(sIqgetx(i).buf2.normconst)).^2)/sum(sIqgetx(i).buf.normconst);
         end
      else
         sIqgetx(i).buf.iq(:,2) = sIqgetx(i).buf1.iq(:,2) + ...
             sIqgetx(i).buf2.iq(:,2);
         if has_error
            sIqgetx(i).buf.iq(:,3:4) = sqrt(sIqgetx(i).buf1.iq(:,3:4).^2 ...
                                            + sIqgetx(i).buf2.iq(:,3:4).^2);
         end
      end
   end
   
   % do the subtraction: sam.iq - buf.iq
   sIqgetx(i).iq = sIqgetx(i).sam.iq;
   sIqgetx(i).iq(:,2) = sIqgetx(i).sam.iq(:,2) - sIqgetx(i).buf.iq(:,2);
   if has_error
      sIqgetx(i).iq(:,3:4) = sqrt(sIqgetx(i).sam.iq(:,3:4).^2 + ...
                                  sIqgetx(i).buf.iq(:,3:4).^2);
   end
   
   % subtract each samimgs by the buf.iq as well
   for k=1:length(sIqgetx(i).samimgs)
      sIqgetx(i).samimgs(k).iq(:,2) = sIqgetx(i).samimgs(k).iq(:,2) ...
          - sIqgetx(i).buf.iq(:,2);
      if has_error
         sIqgetx(i).samimgs(k).iq(:,3:4) = ...
             sqrt(sIqgetx(i).samimgs(k).iq(:,3:4).^2 + sIqgetx(i).buf.iq(:,3:4).^2);
      end
   end
end
iq = sIqgetx(end).iq;
