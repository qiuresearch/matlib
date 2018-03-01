function [data, thetagrid] = slice_integrate(im, num_slices, anchor, varargin)

global X_cen Y_cen MaskI Spec_to_Phos X_Lambda

do_plot=0;
normalize = 1; % integration with normalization by pixel
autoalign = 0;
beamcenteronly = 0;
tolerance = 0.5;
maxiter = 7;
verbose =1;
parse_varargin(varargin);
if isempty(num_slices)
   num_slices = 7;
end
if isempty(anchor)
   anchor= 25;
end


% 1) convert to polar coordinates
im_size = size(im);
[xgrid, ygrid] = meshgrid(1:im_size(2), 1:im_size(1));
[theta, r] = cart2pol(xgrid-Y_cen, ygrid-X_cen);

inegative = find(theta < 0);
if ~isempty(inegative)
   theta(inegative) = theta(inegative)+2*pi;
end

% find the limit automatically
% multiply 1.05 to avoid edge
switch length(anchor)
   case 1 % dspacing
      radius = 1.05*tan(2*asin(X_Lambda/2/anchor))* Spec_to_Phos;
      dspacing = anchor;
   case 2 % a point on the ring
      radius = sqrt((anchor(1)-X_cen)^2 + (anchor(2)-Y_cen)^2);
      dspacing = X_Lambda/2/sin(atan(radius/Spec_to_Phos)/2);
   otherwise
end
iselected= find((r >= radius) & (MaskI == 1));
thetagrid = linspace(min(theta(iselected)), max(theta(iselected(:))), ...
                     num_slices+1);

% integrate each slice by moving the MaskI
showinfo(['Current beam center: X_cen: ' num2str(X_cen) [', ' ...
                    'Y_cen: '] num2str(Y_cen) ', Spec_to_Phos: ' ...
          num2str(Spec_to_Phos) ]);
MaskI_orig = MaskI;
X(1)=Y_cen;
Y(1)=X_cen;
for i=1:num_slices
    X(2) = Y_cen+im_size(1)*2*cos(thetagrid(i));
    Y(2) = X_cen+im_size(1)*2*sin(thetagrid(i));
    X(3) = Y_cen+im_size(1)*2*cos(thetagrid(i+1));
    Y(3) = X_cen+im_size(1)*2*sin(thetagrid(i+1));
    MaskI = MaskI_orig.*uint8(roipoly(MaskI, X, Y));
   
    data(:,:,i) = integrater(im, normalize);
end
MaskI = MaskI_orig;

% automatically align the beam center, Spec_to_Phos
iteration = 1;
while (autoalign == 1) && (iteration <= maxiter)
   Q = 2*pi/dspacing;
   imin = locate(data(:,1,1), 0.85*Q);
   imax = locate(data(:,1,1), 1.15*Q);
   % find the peak (peakpos are the INDEX)
   [peakint, peakpos] = max(data(imin:imax,2,:), [], 1);
   if (std(peakpos) > tolerance)
      showinfo(['peak position variation is : ' num2str(std(peakpos)), ...
                ', refining ...']);
      peaktheta = (thetagrid(1:end-1) + thetagrid(2:end))/2;
      % change peak position to unit of pixels
      peakpos = tan(2*asin(data(imin-1+peakpos(:),1,1)*X_Lambda/4/pi))* ...
                Spec_to_Phos;
      
      % auto-adjust the Spec_to_Phos distance
      if (beamcenteronly == 0) && (length(anchor) == 1) 
         Spec_to_Phos = mean(peakpos)/tan(2*asin(X_Lambda/2/anchor));
      end
      [Y_cen, X_cen, radius] = circfit(Y_cen+peakpos(:).*cos(peaktheta(:)), ...
                                       X_cen+peakpos(:).*sin(peaktheta(:)));
      showinfo(['NEW beam center: X_cen: ' num2str(X_cen) [', ' ...
                          'Y_cen: '] num2str(Y_cen) ', Spec_to_Phos: ' ...
                num2str(Spec_to_Phos) ]);
      % recurse
      [data, thetagrid] = slice_integrate(im, num_slices, anchor, ...
                                          'normalize', normalize, ...
                                          'autoalign', 0, 'do_plot', 0);
   else
      showinfo(['Peak position variation is : ' num2str(std(peakpos)) ...
                ', done!'])
      showinfo(['FINAL beam center: X_cen: ' num2str(X_cen) [', ' ...
                          'Y_cen: '] num2str(Y_cen) ', Spec_to_Phos: ' ...
                num2str(Spec_to_Phos) ]);
      break;
   end
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
