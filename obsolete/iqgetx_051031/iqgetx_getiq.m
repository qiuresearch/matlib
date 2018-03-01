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
% $Id: iqgetx_getiq.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

% 1) Simple check on input parameters
if nargin < 1
   help iqgetx_getiq
   return
end

% 2) set default behaviors
if isstr(sIqgetx) % file prefix is passed
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
           case 'ADSC'
              [sumdata, imgdata] = slurpadsc_xq(sIqgetx(i).prefix, imgnums, [], sIqgetx(i));
           otherwise
       end
       
       % get I(q) -- integration
       sumdata.iq= integrater(sumdata.im);
       for k=1:length(imgdata)
           imgdata(k).iq = integrater(imgdata(k).im); % individual
                                                      % ones are not
                                                      % dezingered
       end

       if (sIqgetx(i).keep_im == 0) % remove all im data
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
   if (sIqgetx(i).keep_im == 0) % remove the dark image matrix
      sIqgetx(i).im_dark = 0;
   end
   
   % get total buffer I(Q)
   sIqgetx(i).buf.dezinger = sIqgetx(i).buf1.dezinger;
   sIqgetx(i).buf.normalize = sIqgetx(i).buf1.normalize;
   sIqgetx(i).buf.datadir = sIqgetx(i).buf1.datadir;
   sIqgetx(i).buf.imgnums = [sIqgetx(i).buf1.imgnums, ...
                       sIqgetx(i).buf2.imgnums];  
   if (sIqgetx(i).keep_im == 0)
      sIqgetx(i).buf.im = [];
   else
      sIqgetx(i).buf.im = sIqgetx(i).buf1.im + sIqgex(i).buf2.im;
   end
   sIqgex(i).buf.cesr = [sIqgetx(i).buf1.cesr, sIqgetx(i).buf2.cesr];
   sIqgex(i).buf.i0 = [sIqgetx(i).buf1.i0, sIqgetx(i).buf2.i0];
   sIqgex(i).buf.i1 = [sIqgetx(i).buf1.i1, sIqgetx(i).buf2.i1];
   sIqgex(i).buf.normconst = [sIqgetx(i).buf1.normconst, ...
       sIqgetx(i).buf2.normconst];
   
   sIqgetx(i).buf.iq = sIqgetx(i).buf1.iq;
   if (sIqgetx(i).normalize == 1)
      sIqgetx(i).buf.iq(:,2) = sIqgetx(i).buf1.iq(:,2)* ...
          sum(sIqgetx(i).buf1.normconst) + sIqgetx(i).buf2.iq(:,2)* ...
          sum(sIqgetx(i).buf2.normconst);
      sIqgetx(i).buf.iq(:,2) = sIqgetx(i).buf.iq(:,2)/ ...
          sum(sIqgetx(i).buf.normconst);
   else
      sIqgetx(i).buf.iq(:,2) = sIqgetx(i).buf1.iq(:,2) + ...
          sIqgetx(i).buf2.iq(:,2);
   end
   
   % do the subtraction
   sIqgetx(i).iq = sIqgetx(i).sam.iq;
   sIqgetx(i).iq(:,2) = sIqgetx(i).sam.iq(:,2) - sIqgetx(i).buf.iq(:,2);
end
iq = sIqgetx(1).iq;

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Change History:
%
% $Log: iqgetx_getiq.m,v $
% Revision 1.1.1.1  2007-09-19 04:45:38  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.3  2005/06/09 01:52:37  xqiu
% Major changes to the designing!
%
% Revision 1.2  2005/06/03 04:14:06  xqiu
% a more or less working version ready
%
% Revision 1.1  2005/04/29 14:42:49  xqiu
% Initialize the iqgetx standalone package!
%
% Revision 1.1  2004/12/20 04:50:47  xqiu
% early development state now only!
%
% Revision 1.3  2004/11/19 05:04:26  xqiu
% Added comments
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
