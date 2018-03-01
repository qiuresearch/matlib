function iq = integrater(imag, norm_mode, ismooth)
% --- Usage:
%        iq = integrater(imag, norm_mode, ismooth)
%
% --- Purpose:
%
%        Integrate image about the global variables X_cen, Y_cen.
%  Excludes all points in imag excluded by global variable MaskI.
%  Uses global variables Spec_to_Phos and X_Lambda to calculate q.
%
% --- Parameter(s):
%
%  norm_mode: 	- no normalization  - 'none' or 0
%  		- per pixel	    - 'pixel' or 1
%  If no mode is given defaults to per pixel.
%
% --- Return(s): 
%        iq   - [q, I, num_pixels, dI]
%
% --- Example(s):
%
% $Id: integrater.m,v 1.12 2015/09/25 19:02:59 schowell Exp $

global X_cen Y_cen X_Lambda Spec_to_Phos MaskI
% X_cen is the center of columns, Y_cen is the center of rows. They
% are opposite from the c code radial_integral

%  Get the center if not set already
if isempty(X_cen) || isempty(Y_cen)
   X_cen = size(imag,2)*0.5;
   Y_cen = size(imag,1)*0.5;
   showinfo('X_cen and Y_cen not initialized!!!');
   showinfo('Integrating about image center...');
end

% Find the range to integrate
[rows,cols]=size(imag);
rmax=norm([ max( abs(X_cen),abs(X_cen-cols) ), ...
            max( abs(Y_cen),abs(Y_cen-rows) ) ]);
rmin=0; 
qmax = 4*pi/X_Lambda*(rmax-rmin)/Spec_to_Phos;
Num_Bins=fix((rmax-rmin)); % 1 bin per pixel
% Num_Bins=fix((rmax-rmin))/2; % 1 bin per 2 pixel
% Num_Bins=fix((rmax-rmin))/3; % 1 bin per 3 pixel
% Num_Bins = 25;

% Do the integral always with "pixel normalization"
[q,I,num_pixels, dI]=radial_integral(imag,uint8(MaskI),[Y_cen,X_cen],rmin, ...
                                     rmax,Num_Bins, 'pixel');

% If possible, convert q to reciprocal angstroms.  
% Otherwise, complain and return q in pixels.
if ((length(X_Lambda)<1)||(length(Spec_to_Phos)<1))
   fprintf(1,'\n\n X_Lambda and Spec_to_Phos not initialized.\n');
   fprintf(1,'q values are in pixels, rather than reciprocal Angstrom.\n');
else
   q=pixel_to_q(q,Spec_to_Phos,X_Lambda);
end

% Correct for solid angle effects (assume the same area for each
% pixel and the detector perpendicular to the incident beam)
twotheta = 2*asin(q*X_Lambda/4/pi);
I = I./cos(twotheta).^3;

% Standard error is: (standard deviation)/sqrt(N) (dI is the standard deviation
% of the averaged pixels normalized by the number of pixels)
num_pixels(num_pixels == 0) = 1;
dI = dI./sqrt(num_pixels); 

% de-normalize if necessary
if exist('norm_mode', 'var')
   if (isnumeric(norm_mode) && (norm_mode ~= 1)) || strcmpi(norm_mode, 'none')
      showinfo('Integration is not normalized by pixels!!!');
      I = I.*num_pixels;
      dI = dI.*num_pixels;
   end
end

% ismooth
if exist('ismooth', 'var') && (ismooth > 1)
   showinfo(['smoothening data with smooth = ' num2str(ismooth)]);
   I = smooth(q, I, ismooth, 'sgolay')';
end

iq = [q',I', num_pixels', dI'];
