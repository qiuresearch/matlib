function [iq, sIqgetx] = iqgetx_getiq_1buf(sIqgetx, startnum, skipnums, sOpt)
% --- Usage:
%        [iq, sIqgetx] = iqgetx2_getiq(sIqgetx, startnum, skipnums, sOpt)
% --- Purpose:
%        read in the data images and process them to get I(Q). Now,
%        most data processing is done in this single step. 
% 
%        the difference here is that all buffers go to one field
%        sIqgetx.buf, thus the before and after buffers are not distinguished
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
% $Id: iqgetx_getiq_1buf.m,v 1.1 2008-03-04 16:42:57 xqiu Exp $
%

verbose = 1;
% 1) Simple check on input parameters
if nargin < 1
   help iqgetx2_getiq
   return
end

% 2) set default behaviors
if isstr(sIqgetx) % file prefix is passed
    prefix = sIqgetx;
    sIqgetx = iqgetx2_init();
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

   if (sIqgetx(i).runnums_autogen == 1)
      % compute the run numbers for dark, buf, sam,
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
      
   end
   
   if (sIqgetx(i).readraw == 1)
      % read the dark image and save it to the structure
      if ~isempty(sIqgetx(i).darknums)
         normalize = sIqgetx(i).normalize;
         sIqgetx(i).normalize = 0;
         sIqgetx(i).im_dark = 0;
         switch sIqgetx(i).dataformat
            case 'SG1KCCD'
               darkdata = slurp_sg1kccd_xq(sIqgetx(i).prefix, ...
                                           sIqgetx(i).darknums, [], ...
                                           sIqgetx(i));
            otherwise
         end
         sIqgetx(i).im_dark = darkdata.im/length(sIqgetx(i).darknums);
         sIqgetx(i).normalize = normalize;
      end
   end
   
    %  read the signals and integrate them
      for datatype=1:2
         switch datatype
           case 1 % buf
               imgnums = sIqgetx(i).bufnums;
               prefix = sIqgetx(i).bufprefix;
           case 2 % sam
               imgnums = sIqgetx(i).samnums;
               prefix = sIqgetx(i).samprefix;
         end
       
       % ----- The difference in ????? here!!!!! ------
       
       switch sIqgetx(i).dataformat % read in the data
           case 'SG1KCCD'
              [sumdata, imgdata] = slurp_sg1kccd_xq(prefix, ...
                                                    imgnums, [], sIqgetx(i));
           case 'ADSC'
              [sumdata, imgdata] = slurpadsc_xq(sIqgetx(i).prefix, ...
                                                imgnums, [], sIqgetx(i));
           case 'MarCCD'
              [sumdata, imgdata] = slurp_marccd_0802nsls(prefix, ...
                                                imgnums, [], sIqgetx(i));
           
           otherwise
       end

       % ----- end of the difference -------
       
       % get I(q) -- integration
       sumdata.iq= integrater(sumdata.im);
       for k=1:length(imgdata) % individual ones are not dezingered
           imgdata(k).iq = integrater(imgdata(k).im, 'pixel');
       end

       has_error = size(sumdata.iq, 2) > 2;

       % normalization
       if (sumdata.normalize ~= 0) && (sum(sumdata.normconst) ~= 0.0)
          sumdata.iq(:,2:end) = 1.0/sum(sumdata.normconst)*sumdata.iq(:,2:end);
          showinfo(['normalized by ' sumdata.monnames{sumdata.normalize} ...
                    ' total = ' int2str(sum(sumdata.normconst))])
          
          for k=1:length(imgdata)
             imgdata(k).iq(:,2:end) = 1.0/imgdata(k).normconst * ...
                 imgdata(k).iq(:,2:end);
          end
       end
       
       % remove all im data
       if (sIqgetx(i).keep_im == 0)
          sumdata.im = [];
          [imgdata(:).im] = deal([]);
       end
       
       switch datatype
           case 1 % buf
               sIqgetx(i).buf = sumdata; 
               sIqgetx(i).bufimgs = imgdata;
           case 2 % sam
               sIqgetx(i).sam = sumdata;
               sIqgetx(i).samimgs = imgdata;
       end       
   end

   % do the subtraction: sam.iq - buf.iq
   sIqgetx(i).iq = sIqgetx(i).sam.iq;
   sIqgetx(i).iq(:,2) = sIqgetx(i).sam.iq(:,2) - sIqgetx(i).buf.iq(:,2);
   if has_error
   sIqgetx(i).iq(:,4) = sqrt(sIqgetx(i).sam.iq(:,4).^2 + ...
                             sIqgetx(i).buf.iq(:,4).^2);
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
    
   % remove the dark image matrix
   if (sIqgetx(i).keep_im == 0) 
      sIqgetx(i).im_dark = 0;
   end
end
iq = sIqgetx(end).iq;
