%  function  Ival = sintegrater( image, option)
%
%    Integration routine very similar to integrate, except that it supports
%  negative radii.  Type help integrate to get syntax.
%  sintegrater first figures out the direction of the bowtie, theta.
%  Then it splits the default mask, MaskI into two pieces, a negative piece and 
%  a radii positive piece.
%  Next, it integrates both bits and puts the answers together.  That's it.
%
%  Dependencies - integrater -> radial_integrater

function Ival = sintegrater(image, options)

global X_cen Y_cen; global MaskI;

% set integration mode
if (nargin<2)
   options='pixel';
end

% Figure out theta.
X_vals= zeros(size(image)); Y_vals = zeros(size(image));
for k=1:size(image,2)
X_vals(:,k) = ([1:size(image,1)] - (0.5 + X_cen))';
end
for k=1:size(image,1)
   Y_vals(k,:) = ([1:size(image,2)] - (0.5 + Y_cen));
end
yterm = sum(sum(2.0 * double(MaskI).* X_vals .* Y_vals));
xterm = sum(sum(double(MaskI) .* ( X_vals.* X_vals - Y_vals .*Y_vals) ));
theta = 0.5 * atan2(yterm,xterm);

% Split mask into two.
Mask_Save = MaskI;
% Positive half first.
Dist_Mask = sign(X_vals * cos(theta) + Y_vals * sin(theta));
MaskI = bitand( Mask_Save ,  uint8(Dist_Mask));
Ival1 = integrater(image,options);
% Negative half second.
MaskI = bitand(Mask_Save, uint8(-Dist_Mask));
Ival2 = integrater(image,options);
% Restore original mask.
MaskI = Mask_Save;

% Finally combine and return result.
Ival(:,1) = [Ival1(:,1); -Ival2(:,1)];
Ival(:,2) = [Ival1(:,2); Ival2(:,2)]; 
