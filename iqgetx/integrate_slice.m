function [data, thetagrid] = integrate_slice(im, num_slices, anchor, varargin)
% --- Usage:
%        [data, thetagrid] = slice_integrate(im, num_slices, anchor, varargin)
%
% --- Purpose:
%
% --- Parameter(s):
%        anchor   - 
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: integrate_slice.m,v 1.2 2014/03/19 05:07:04 xqiu Exp $
%

global X_cen Y_cen MaskI Spec_to_Phos X_Lambda

verbose =1;
do_plot=0;
normalize = 1; % ['none', 'pixel'] default: normalization by pixel

% 0) flags for auto alignment and initialization
autoalign = 0;
beamcenteronly = 0;
tolerance = 0.01;
maxiter = 7;

parse_varargin(varargin);
if isempty(num_slices)
   num_slices = 6;
end
if isempty(anchor)
   anchor= 25;
end

% 1) convert to polar coordinates
im_size = size(im);
[xgrid, ygrid] = meshgrid(1:im_size(2), 1:im_size(1));
[theta, r] = cart2pol(xgrid-X_cen, ygrid-Y_cen);

inegative = find(theta < 0);
if ~isempty(inegative)
   theta(inegative) = theta(inegative)+2*pi;
end

% find the limit automatically, multiply 1.05 to avoid edge
switch length(anchor)
   case 1 % dspacing
      radius = 1.05*tan(2*asin(X_Lambda/2/anchor))*Spec_to_Phos;
      dspacing = anchor;
   case 2 % a point on the ring
      radius = sqrt((anchor(1)-X_cen)^2 + (anchor(2)-Y_cen)^2);
      dspacing = X_Lambda/2/sin(atan(radius/Spec_to_Phos)/2);
   otherwise
end
iselected= find((r >= radius) & (MaskI == 1));
thetagrid = linspace(min(theta(iselected)), max(theta(iselected(:))), ...
                     num_slices+1);

% 2) integrate each slice by slicing the MaskI

MaskI_orig = MaskI;
X(1)=Y_cen;
Y(1)=X_cen;
for i=1:num_slices
    X(2) = X_cen+im_size(1)*2*cos(thetagrid(i));
    Y(2) = Y_cen+im_size(1)*2*sin(thetagrid(i));
    X(3) = X_cen+im_size(1)*2*cos(thetagrid(i+1));
    Y(3) = Y_cen+im_size(1)*2*sin(thetagrid(i+1));
    MaskI = MaskI_orig.*uint8(roipoly(MaskI, X, Y));
   
    data(:,:,i) = integrater(im, normalize);
end
MaskI = MaskI_orig;
showinfo(['Beam center: X_cen: ' num2str(X_cen) ', Y_cen: ' ...
          num2str(Y_cen) ', Spec_to_Phos: ' num2str(Spec_to_Phos) ...
          ', autoalign: ' num2str(autoalign)]);

% 3) automatically align the beam center, Spec_to_Phos if requested
iteration = 1;
while (autoalign == 1)
   Q = 2*pi/dspacing;
   imin = locate(data(:,1,1), 0.85*Q);
   imax = locate(data(:,1,1), 1.15*Q);

   peakmethod = 1;
   % find the peak
   switch peakmethod
      case 1
         [peakint, peakpos] = max(data(imin:imax,2,:), [], 1);
         peakpos = data(imin-1+peakpos(:),1,1);
      case 2
         for i=1:num_slices
            fitres = fit_onepeak(data(imin:imax,:,i), [], [], 'display', 0);
            peakpos(i) = fitres.par_fit(1);
         end
   end

   % auto-adjust the Spec_to_Phos distance if anchor is the dspacing
   if (beamcenteronly == 0) && (length(anchor) == 1)
      qbragg = 2*pi/dspacing;
      dnew_old_ratio = sqrt(((4*pi/qbragg/X_Lambda)^2-1)/((4*pi/mean(peakpos)/X_Lambda)^2-1));
      Spec_to_Phos = Spec_to_Phos*dnew_old_ratio;
   end
   
   % align the beam center
   std_peakpos = std(peakpos(:));
   showinfo(['Peak position variation is : ' num2str(std_peakpos)]);
   if (std_peakpos < tolerance) || (iteration >= maxiter)
      if (iteration >= maxiter)
         showinfo(num2str(maxiter, ['Exceeding maximum iteration of ' ...
         '%i, abort!!!']), 'warning');
      end
      showinfo('Beam center alignment succeeded!');
      autoalign = 0;
   else
      peaktheta = (thetagrid(1:end-1) + thetagrid(2:end))/2;
      
      % change peak position to the unit of pixels
      peakpos = tan(2*asin(peakpos(:)*X_Lambda/4/pi))* Spec_to_Phos;
      
      [X_cen, Y_cen, radius] = circfit(X_cen+peakpos(:).*cos(peaktheta(:)), ...
                                       Y_cen+peakpos(:).*sin(peaktheta(:)));
%      showinfo(['NEW beam center: X_cen: ' num2str(X_cen) ', Y_cen: ' ...
%                          num2str(Y_cen) ', Spec_to_Phos: ' ...
%                          num2str(Spec_to_Phos) ]);
   end
   
   % recurse
   [data, thetagrid] = integrate_slice(im, num_slices, anchor, ...
                                       'autoalign', 0, 'do_plot', ...
                                       0, 'normalize', normalize);
   
   iteration = iteration + 1;
end


if (do_plot == 1)
   % plot the I(Q)s from the slices
   hold all;
   for i=1:num_slices
      plot(data(:,1,i), data(:,2,i));
      lege{i} = num2str(thetagrid([i,i+1])*180/pi, ['Angle: [%4.0f, ' ...
                          '%4.0f]']);
   end
   legend(lege); legend boxoff
   iqlabel; xlim(2*pi/dspacing*[0.45, 1.55]); ylim auto; zoom;
end
return
