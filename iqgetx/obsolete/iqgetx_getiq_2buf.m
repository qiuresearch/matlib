function [iq, sIqgetx] = iqgetx_getiq(sIqgetx, startnum, skipnums, sOpt)
% --- Usage:
%        [iq, sIqgetx] = iqgetx_getiq(sIqgetx, startnum, skipnums, sOpt)
% --- Purpose:
%        read in the data images and process them to get I(Q). Now,
%        most data processing is done in this single step
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
%        sIqgetx - the structure with processed data
%
% --- Example(s):
%
% $Id: iqgetx_getiq_2buf.m,v 1.1 2008-03-04 16:42:57 xqiu Exp $
%

verbose = 1;
% 1) Simple check on input parameters
if nargin < 1
   help iqgetx_getiq
   return
end

% 2) set default behaviors
if isstr(sIqgetx) % file prefix is passed as a string
    prefix = sIqgetx;
    sIqgetx = iqgetx_init();
    sIqgetx.prefix = prefix;
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
   
   
   % read the dark image and save it to the structure
   if ~isempty(sIqgetx(i).darknums) && (sIqgetx(i).darksub == 1)
       normalize = sIqgetx(i).normalize; % record current normalize
       sIqgetx(i).normalize = 0;
       sIqgetx(i).im_dark = 0;
       switch sIqgetx(i).dataformat
           case 'SG1KCCD'
              darkdata = slurp_sg1kccd_xq(sIqgetx(i).prefix, ...
                                          sIqgetx(i).darknums, [], ...
                                          sIqgetx(i));
          case 'FLICAM'
             sIqgetx(i).readraw = 0;
             darkdata = slurp_flicam_0511gline(sIqgetx(i).prefix, ...
                                               sIqgetx(i).darknums, [], ...
                                               sIqgetx(i));
          otherwise
       end
       sIqgetx(i).im_dark = darkdata.im/length(sIqgetx(i).darknums);
       sIqgetx(i).normalize = normalize; % assign it back
   end
   
   %  read the signals and integrate them
   for datatype=1:3
       switch datatype
           case 1 % buf1
               imgnums = sIqgetx(i).buf1nums;
           case 2 % sam
               imgnums = sIqgetx(i).samnums;
           case 3 % buf2
               imgnums = sIqgetx(i).buf2nums;
       end
       
       switch sIqgetx(i).dataformat % read in the data
           case 'SG1KCCD'
              [sumdata, imgdata] = slurp_sg1kccd_xq(sIqgetx(i).prefix, imgnums, [], sIqgetx(i));
          case 'FLICAM'
              [sumdata, imgdata] = slurp_flicam_xq(sIqgetx(i).prefix, imgnums, [], sIqgetx(i));
          case 'ADSC'
              [sumdata, imgdata] = slurpadsc_xq(sIqgetx(i).prefix, imgnums, [], sIqgetx(i));
           otherwise
       end
       
       % get I(q) -- integration
       sumdata.iq= integrater(sumdata.im);
       for k=1:length(imgdata)
           imgdata(k).iq = integrater(imgdata(k).im, 'pixel'); % individual
                                                      % ones are not
                                                      % dezingered
       end

       % normalization
       if (sumdata.normalize ~= 0) && (sum(sumdata.normconst) ~= 0.0)
          sumdata.iq(:,[2,4]) = 1.0/sum(sumdata.normconst)*sumdata.iq(:,[2,4]);
          showinfo(['normalized by ' sumdata.monnames{sumdata.normalize} ...
                    ' total = ' int2str(sum(sumdata.normconst))])
          
          for k=1:length(imgdata)
             imgdata(k).iq(:,[2,4]) = 1.0/imgdata(k).normconst * ...
                 imgdata(k).iq(:,[2,4]);
          end
       end
       
       % remove all im data
       if (sIqgetx(i).keep_im == 0)
          sumdata.im = [];
          [imgdata(:).im] = deal([]);
       end
       
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
   
   % remove the dark image matrix
   if (sIqgetx(i).keep_im == 0) 
      sIqgetx(i).im_dark = 0;
   end
   
   % get total buffer I(Q)
   sIqgetx(i).buf.dezinger = sIqgetx(i).buf1.dezinger;
   sIqgetx(i).buf.normalize = sIqgetx(i).buf1.normalize;
   sIqgetx(i).buf.datadir = sIqgetx(i).buf1.datadir;
   sIqgetx(i).buf.imgnums = [sIqgetx(i).buf1.imgnums, ...
                       sIqgetx(i).buf2.imgnums];  
   sIqgetx(i).buf.file = {sIqgetx(i).buf1.file{:}, sIqgetx(i).buf2.file{:}};
   if (sIqgetx(i).keep_im == 0)
      sIqgetx(i).buf.im = [];
   else
      sIqgetx(i).buf.im = sIqgetx(i).buf1.im + sIqgex(i).buf2.im;
   end

   sIqgetx(i).buf.mean = [sIqgetx(i).buf1.mean, sIqgetx(i).buf2.mean];
   sIqgetx(i).buf.time = [sIqgetx(i).buf1.time, sIqgetx(i).buf2.time];
   
   sIqgetx(i).buf.monnames = sIqgetx(i).buf1.monnames;
   sIqgetx(i).buf.moncounts = [sIqgetx(i).buf1.moncounts; ...
                       sIqgetx(i).buf2.moncounts];
   sIqgetx(i).buf.normconst = [sIqgetx(i).buf1.normconst, ...
                                  sIqgetx(i).buf2.normconst];
   
   sIqgetx(i).buf.iq = sIqgetx(i).buf1.iq;

   if (sIqgetx(i).normalize ~= 0)
      sIqgetx(i).buf.iq(:,2) = sIqgetx(i).buf1.iq(:,2)* ...
          sum(sIqgetx(i).buf1.normconst) + sIqgetx(i).buf2.iq(:,2)* ...
          sum(sIqgetx(i).buf2.normconst);
      sIqgetx(i).buf.iq(:,2) = sIqgetx(i).buf.iq(:,2)/ ...
          sum(sIqgetx(i).buf.normconst);
   
      sIqgetx(i).buf.iq(:,4) = sqrt( (sIqgetx(i).buf1.iq(:,4)* ...
          sum(sIqgetx(i).buf1.normconst)).^2 + (sIqgetx(i).buf2.iq(:,4)* ...
          sum(sIqgetx(i).buf2.normconst)).^2);
      sIqgetx(i).buf.iq(:,4) = sIqgetx(i).buf.iq(:,4)/ ...
          sum(sIqgetx(i).buf.normconst);
   else
      sIqgetx(i).buf.iq(:,2) = sIqgetx(i).buf1.iq(:,2) + ...
          sIqgetx(i).buf2.iq(:,2);
      sIqgetx(i).buf.iq(:,4) = sqrt(sIqgetx(i).buf1.iq(:,4).^2 + ...
          sIqgetx(i).buf2.iq(:,4).^2);
   end
   
   % do the subtraction: sam.iq - buf.iq
   sIqgetx(i).iq = sIqgetx(i).sam.iq;
   sIqgetx(i).iq(:,2) = sIqgetx(i).sam.iq(:,2) - sIqgetx(i).buf.iq(:,2);
   sIqgetx(i).iq(:,4) = sqrt(sIqgetx(i).sam.iq(:,4).^2 + ...
                             sIqgetx(i).buf.iq(:,4).^2);
end
iq = sIqgetx(1).iq;
