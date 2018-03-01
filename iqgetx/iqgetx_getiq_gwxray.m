function [iq, sIqgetx] = iqgetx_getiq_gwxray(sIqgetx, samnums, sOpt)
% --- Usage:
%        [iq, sIqgetx] = iqgetx_getiq_gwxray(sIqgetx, samnums, sOpt)
% --- Purpose:
%        read in the data images and process them to get I(Q). 
%        Two variations are possible: 
%             1) one buffer; and 2) two buffer (before and after)
%
% --- Parameter(s):
%        sIqgetx  - the structure as defined in iqgetx_init()
%        samnums - the starting image number 
%        sOpt     - a structure to pass on options, e.g., dezinger,
%        normalize, etc..
%     
% --- Return(s): 
%        iq      - the final I(Q) of sIqgetx(1) only
%        sIqgetx - the full structure with processed data
%
% --- Example(s):
%
% $Id: iqgetx_getiq_gwxray.m,v 1.9 2013/10/20 04:06:06 xqiu Exp $
%

verbose = 1;
% 1) Simple check on input parameters
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   error('at least one parameter is required, please see the usage! ')
   return
end

% 2) set default behaviors
if isstr(sIqgetx) % file prefix is passed
    prefix = sIqgetx;
    sIqgetx = iqgetx_init('onebuf');
    sIqgetx.samprefix = prefix;
    sIqgetx.bufprefix = prefix;
end

if (nargin > 3)
    sIqgetx = struct_assign(sOpt, sIqgetx);
end

% 3) action
num_data = length(sIqgetx);
for i=1:num_data
   
   %  read the signals and integrate them
   for datatype=1:3
      if isfield(sIqgetx(i), 'bufnums'); 
         switch datatype
            case 1 % buf
               imgnums = sIqgetx(i).bufnums;
               prefix = sIqgetx(i).bufprefix;
               if isempty(imgnums)
                  showinfo('No image files given for buffer, skip!');
                  continue;
               end
            case 2 % sam
               imgnums = sIqgetx(i).samnums;
               prefix = sIqgetx(i).samprefix;
               if isempty(imgnums)
                  showinfo('No image files given for sample, skip!');
                  continue;
               end
            case 3
               continue
         end
      else
         switch datatype
            case 1 % buf1
               imgnums = sIqgetx(i).buf1nums;
            case 2 % sam
               imgnums = sIqgetx(i).samnums;
            case 3 % buf2
               imgnums = sIqgetx(i).buf2nums;
         end
      end
      
      % ----- The difference in ????? here!!!!! ------
       
       switch sIqgetx(i).dataformat % read in the data
           case 'MAR345'
              [sumdata, imgdata] = slurp_imageplate_gwxray(prefix, ...
                                                    imgnums, [], sIqgetx(i));
            otherwise
       end
       
       % ----- end of the difference -------
       
       % get I(q) -- integration
       sumdata.iq= integrater(sumdata.im);
       for k=1:length(imgdata) % individual ones are not dezingered
           imgdata(k).iq = integrater(imgdata(k).im, 'pixel');
       end

       % check if sumdata has error bar
       has_error = size(sumdata.iq, 2) > 2;

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
       
       % calculate anisotropic scattering azimuthal profiles
       if (sumdata.aniso_calc == 1);
          showinfo(['calculating anisotropic scattering ' 'profiles...']);
          %          sumdata
          if isempty(sumdata.aniso_qpos) || (sumdata.aniso_qpos == 0) % if not yet, use peak position
             imin = locate(sumdata.iq(:,1), sumdata.aniso_qmin);
             imax = locate(sumdata.iq(:,1), sumdata.aniso_qmax);
             [iqmax, imax_d] = max(sumdata.iq(imin:imax,2));
             sumdata.aniso_qpos = sumdata.iq(imin+imax_d-1);
          end
          % background calculation method #1 for the anisotropic profile
          fitres = fit_onepeak(sumdata.iq, sumdata.aniso_qmin, ...
                               sumdata.aniso_qmax);
          qbkg = [sumdata.aniso_qmin; fitres.par_fit(1); sumdata.aniso_qmax];
          sumdata.aniso_ibkg = [qbkg, (fitres.par_fit(4)+ ...
                                       fitres.par_fit(5)*qbkg)* ...
                              fitres.scalefactor];
          sumdata.aniso_qpos = fitres.par_fit(1);
          % background calculation method #2
          % imin = locate(sumdata.iq(:,1), sumdata.aniso_qmin);
          % imax = locate(sumdata.iq(:,1), sumdata.aniso_qmax);
          % ipeak = locate(sumdata.iq(:,1), sumdata.aniso_qpos);
          % sumdata.aniso_ibkg = sumdata.iq([imin,ipeak,imax],1:2);
          % sumdata.aniso_ibkg(2,2) = (sumdata.aniso_ibkg(1,2)* ...
          %                           (sumdata.aniso_ibkg(3,1)- ...
          %                            sumdata.aniso_ibkg(2,1))+ ...
          %                           sumdata.aniso_ibkg(3,2)* ...
          %                           (sumdata.aniso_ibkg(2,1)- ...
          %                            sumdata.aniso_ibkg(1,1)))/ ...
          %    (sumdata.aniso_ibkg(3,1)- sumdata.aniso_ibkg(1,1));
          
          % circ intergrate & background removal
          [sumdata.aniso_prof, sumdata.aniso_circ] = ...
              integrate_azimuthal(sumdata.im, sumdata.aniso_qpos, ...
                             sumdata.aniso_qwid);
          sumdata.aniso_prof(:,2) = sumdata.aniso_prof(:,2) - sumdata.aniso_ibkg(2,2);
          
          % calculate the anisotropic scattering properties
          sumdata.aniso_orderparam = order_parameter_iphi(sumdata.aniso_prof);
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
      sIqgetx(i).im_dark = 0;
   end

   % do the subtraction: sam.iq - buf.iq
   sIqgetx(i).iq = sIqgetx(i).sam.iq;
   if ~isempty(sIqgetx(i).buf)
      if isfield(sIqgetx(i), 'buf_polyfit') && ~isempty(sIqgetx(i).buf_polyfit);
         if (length(sIqgetx(i).buf_polyfit) > 2)
            showinfo(sprintf('Apply polynomial fit of order <%0d> between %0.2f and %0.2f /A', sIqgetx(i).buf_polyfit));
            imin = locate(sIqgetx(i).buf.iq(:,1), sIqgetx(i).buf_polyfit(2));
            imax = locate(sIqgetx(i).buf.iq(:,1), sIqgetx(i).buf_polyfit(3));
            P= polyfit(sIqgetx(i).buf.iq(imin:imax,1), sIqgetx(i).buf.iq(imin:imax,2), sIqgetx(i).buf_polyfit(1));
            sIqgetx(i).buf.iq(imin:imax,2) = polyval(P, sIqgetx(i).buf.iq(imin:imax,1));
            sIqgetx(i).buf.iq(imin:imax,4) = 0;
         else
            showinfo(sprintf('Apply sgolay smoothing to buffer I(Q) with span <%0d>', sIqgetx(i).buf_polyfit(1)));
            sIqgetx(i).buf.iq(:,2) = smooth(sIqgetx(i).buf.iq(:,1), sIqgetx(i).buf.iq(:,2), sIqgetx(i).buf_polyfit(1), 'sgolay');
         end
      end
      
      % the goal is to match the buffer to get average zero in
      % selected range
      if ~isempty(sIqgetx(i).sambuf_scalerange)
         [dummy, scale] = match(sIqgetx(i).buf.iq, sIqgetx(i).sam.iq, ...
                                sIqgetx(i).sambuf_scalerange, 'scale',1);
         if (length(sIqgetx(i).sambuf_scalerange) == 3)
            scale = scale*sIqgetx(i).sambuf_scalerange(3);
         end
         % the goal is to scale the bkg so that subtracted data is flat
      elseif ~isempty(sIqgetx(i).sambuf_peakrange)
         [dummy, scale] = bkg1d_subpeak(sIqgetx(i).sam.iq, sIqgetx(i).buf.iq, ...
                                        'peakrange', sIqgetx(i).sambuf_peakrange, ...
                                        'Display', 'off');
      else
         scale = 1;
      end
      sIqgetx(i).sambuf_scale = scale;
      
      sIqgetx(i).iq(:,2) = sIqgetx(i).sam.iq(:,2) - sIqgetx(i).buf.iq(:,2)*scale;
      if has_error
         sIqgetx(i).iq(:,4) = sqrt(sIqgetx(i).sam.iq(:,4).^2 + ...
                                   sIqgetx(i).buf.iq(:,4).^2*scale^2);
      end
      if ~isempty(sIqgetx(i).q4dep_range)
         [sIqgetx(i).iq, sIqgetx(i).iq_q4offset] = ...
             iqcorr_powerlaw(sIqgetx(i).iq, -4, sIqgetx(i).q4dep_range);
      end
      
      % subtract each samimgs by the buf.iq as well
      for k=1:length(sIqgetx(i).samimgs)
         if ~isempty(sIqgetx(i).sambuf_scalerange)
            [dummy, scale] = match(sIqgetx(i).buf.iq, sIqgetx(i).samimgs(k).iq, ...
                                   sIqgetx(i).sambuf_scalerange, 'scale',1);
            if (length(sIqgetx(i).sambuf_scalerange) == 3)
               scale = scale*sIqgetx(i).sambuf_scalerange(3);
            end
         elseif ~isempty(sIqgetx(i).sambuf_peakrange)
            [dummy, scale] = bkg1d_subpeak(sIqgetx(i).samimgs(k).iq, sIqgetx(i).buf.iq, ...
                                           'peakrange', sIqgetx(i).sambuf_peakrange, ...
                                           'Display', 'off');
         else
           scale = 1;
         end
         sIqgetx(i).samimgs(k).iq(:,2) = sIqgetx(i).samimgs(k).iq(:,2) ...
             - sIqgetx(i).buf.iq(:,2)*scale;
         if has_error
            sIqgetx(i).samimgs(k).iq(:,3:4) = ...
                sqrt(sIqgetx(i).samimgs(k).iq(:,3:4).^2 + sIqgetx(i).buf.iq(:,3:4).^2*scale^2);
         end
         if ~isempty(sIqgetx(i).q4dep_range)
            sIqgetx(i).samimgs(k).iq = iqcorr_powerlaw(sIqgetx(i).samimgs(k).iq, -4, ...
                                                       sIqgetx(i).q4dep_range);
         end
         
      end
   end
   
end
iq = sIqgetx(end).iq;
