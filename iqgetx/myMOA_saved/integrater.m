%  function Result = integrater(imag,mode)
%
%  Integrate image about the global variables X_cen, Y_cen.
%  Excludes all points in imag excluded by global variable MaskI.
%  Uses global variables Spec_to_Phos and X_Lambda to calculate q.
%  Result(:,1) are the q values
%  Result(:,2) are the intensities.
%
%  Mode can be 	- no normalization  - 'none'
%  		- per pixel	    - 'pixel'
%		- radial	    - 'radial'
%  If no mode is given defaults to per pixel.
%
%  Uses radial_integral()
%  Uses pixel_to_q() if conversion to recip Angstroms possible.

function Result = integrater(imag, mode)

global X_cen Y_cen; global X_Lambda Spec_to_Phos;
global MaskI;

% Select integration mode.
if (nargin<2)  
   mode='pixel';
end

%  Get the centre
if ((length(X_cen)<1)|(length(Y_cen)<1))
   X_cen = size(imag,1)*0.5;
   Y_cen = size(imag,2)*0.5;
   fprintf(1,'\nX_cen and Y_cen not initialized.\n');
   fprintf(1,'Integrating about image centre');
end

% Find the range.
[x,y]=size(imag);
rmax=norm([ max( abs(X_cen),abs(X_cen-x) ), ...
            max( abs(Y_cen),abs(Y_cen-y) ) ]);
rmin=0; Num_Bins=fix((rmax-rmin)/2);

% Do the integral
[q,I,num_pixels, dI]=radial_integral(imag,MaskI,[X_cen,Y_cen],rmin, ...
                                     rmax,Num_Bins,mode);

% Work on the error bar (assuming returned dI is the standard
% deviation of the averaged pixels)
num_pixels(find(num_pixels == 0)) = 1;
dI = dI./sqrt(num_pixels); % from discussions with Jessica. The
                           % error bar is different from the std.

% If possible, convert q to reciprocal angstroms.  
% Otherwise, complain and return q in pixels.
if ((length(X_Lambda)<1)|(length(Spec_to_Phos)<1))
   fprintf(1,'\n\n X_Lambda and Spec_to_Phos not initialized.\n');
   fprintf(1,'q values are in pixels, rather than reciprocal Angstrom.\n');
else
   q=pixel_to_q(q,Spec_to_Phos,X_Lambda);	
end

Result = [q',I', num_pixels', dI'];
