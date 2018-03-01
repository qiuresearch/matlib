function [iq, sIqgetx]=iqgetx_getiq_imageplate(sIqgetx, sOpt)
% --- Usage:
%        [iq, sIqgetx] = iqgetx_getiq(sIqgetx, startnum, skipnums, sOpt)
% --- Purpose:
%        read in the data images and process them to get I(Q). Now,
%        most data processing is done in this single step
%
% --- Parameter(s):
%        sIqgetx  - the structure as defined in iqgetx_init()
%        sOpt     - a structure to pass on options, e.g., dezinger,
%        normalize, etc..
%     
% --- Return(s): 
%        iq      - the final I(Q) of sIqgetx(1) only
%        sIqgetx - the structure with processed data
%
% --- Example(s):
%
% $Id: iqgetx_getiq_imageplate.m,v 1.7 2012/06/16 16:43:25 xqiu Exp $
%

global MaskI X_cen Y_cen X_Lambda Spec_to_Phos

verbose = 1;
if (nargin < 1)
   help iqgetx_getiq_imageplate
   return
end

% 1) Simple check on input parameters
if isstr(sIqgetx) % file prefix is passed as a string
   datafile = sIqgetx;
   sIqgetx = iqgetx_init_imageplate();
else
   datafile = [sIqgetx.datadir sIqgetx.prefix sIqgetx.suffix];
end

if (nargin > 1)
   sIqgetx = struct_assign(sOpt, sIqgetx);
end

% 2) read in the data and apply integration settings for this image

% always pass the file directly
sIqgetx = slurp_imageplate(datafile, [], [], sIqgetx);
if total(abs(size(sIqgetx.im)-size(MaskI))) ~= 0 
   MaskI = uint8(ones(size(sIqgetx.im)));
end
Spec_to_Phos = sIqgetx.Spec_to_Phos;

% 3) try to optimize the center if requested
if (sIqgetx.autoalign_isa ~= 0)
   % start with predefined beam center or a guess
   if (sIqgetx.X_cen == 0) && (sIqgetx.Y_cen == 0)
      [Y_cen, X_cen] = imageplate_guess_center(sIqgetx.im);
   else
      X_cen = sIqgetx.X_cen;
      Y_cen = sIqgetx.Y_cen;
   end
   
   % whether there is a ring or dspacing to use
   if (sIqgetx.dspacing == 0) && (sIqgetx.X_ring == 0) && (sIqgetx.Y_ring == 0)
      showinfo(['can not search for beam center without a predefined ' ...
                'dspacing or point on a ring!']);
   else % do the auto align
      if (sIqgetx.X_ring == 0) && (sIqgetx.Y_ring == 0)
         showinfo('use dspacing to autoalign beam center ...');
         anchor = sIqgetx.dspacing;
      else
         showinfo('use ring coordinate to autoalign beam center ...');
         anchor = [sIqgetx.X_ring, sIqgetx.Y_ring];
      end
      
      dummy = slice_integrate(sIqgetx.im, 6, anchor, 'normalize', ...
                              sIqgetx.autoalign_isa, 'beamcenteronly', ...
                              1, 'autoalign', 1, 'do_plot', ...
                              sIqgetx.autoalign_do_plot, 'tolerance', ...
                              sIqgetx.autoalign_tolerance, 'maxiter', ...
                              sIqgetx.autoalign_maxiter);
      
      % Calculate Spec_to_Phos if both X_ring Y_ring and dspacing are given.
      if (length(anchor) == 2) && (sIqgetx.dspacing > 0)
         showinfo(['Adjust "Spec_to_Phos" based on dspacing of ' ...
                   num2str(sIqgetx.dspacing)]);
         iq = integrater(sIqgetx.im, sIqgetx.normalize);
         radius = sqrt((sIqgetx.X_ring-X_cen)^2 + (sIqgetx.Y_ring- Y_cen)^2);
         q_ring = 4*pi/X_Lambda*sin(atan(radius/Spec_to_Phos)/2);
         Spec_to_Phos = sam2det_iqpeak(iq, sIqgetx.dspacing, ...
                                       q_ring-0.04, q_ring+0.04);
      end
         
      sIqgetx.X_cen = X_cen;
      sIqgetx.Y_cen = Y_cen;
      sIqgetx.Spec_to_Phos = Spec_to_Phos;
   end
end

% 3) final integration
if (sIqgetx.X_cen ~= 0) && (sIqgetx.Y_cen ~= 0)
   X_cen = sIqgetx.X_cen;
   Y_cen = sIqgetx.Y_cen;
end
% recalculate the d spacing if the X_ring, Y_ring is given
if (sIqgetx.X_ring ~= 0) || (sIqgetx.Y_ring ~= 0)
   radius = sqrt((sIqgetx.X_ring-X_cen)^2 + (sIqgetx.Y_ring-Y_cen)^2);
   sIqgetx.dspacing = X_Lambda/2/sin(atan(radius/Spec_to_Phos)/2);
end

sIqgetx.iq = integrater(sIqgetx.im, sIqgetx.normalize);
if (sIqgetx.keep_im == 0)
   sIqgetx.im = [];
end

% 4) remove dark and bkg data
if isfield(sIqgetx, 'dark_iq') && (numel(sIqgetx.dark_iq) > 1)
   sIqgetx.iq = iq_subtract(sIqgetx.iq, sIqgetx.dark_iq);
end
if isfield(sIqgetx, 'bkg_iq') && (numel(sIqgetx.bkg_iq) > 1)
   [sIqgetx.iq, scale] = bkg1d_subpeak(sIqgetx.iq, sIqgetx.bkg_iq, ...
                                       'peakrange', sIqgetx.bkg_peakrange, ...
                                       'Display', 'off');
   sIqgetx.title = [sIqgetx.title num2str(scale, '(bkgx%0.2f)')];
end

iq = sIqgetx.iq;
