% function range = show(x, intensity_range, image_range)
%
% The important features of a given display are masking and range.
%
% 				show(x) 
% displays the image x, masking off the regions for which 
% the global variable, MaskD are zero.  The range is set automatically.
%
%			   show(x,[0.1,0.5]);
% displays image x so that the highest colour is asigned to all points for
% which x > 0.5 and the lowest colour is asigned to all points for which x<0.1
% In essence, the range has been set.  Masking is still on.
%
%              show(x,[-0.1,0.5],[20, 100, 40, 60])
% displays image x so the darkest colour is -0.1 and the brightest 0.5.
% Only the portion of the image within the range 20<=x<=100, 40<=y<=60 are shown.
%
% When show runs, it returns the brightest and darkest points in the image.
% The user can then adjust this range at their leisure.
% The user can adjust the colormap in show.
%
% Note MaskD is same size as X but consists of a uint8 array of integers.

function range= show(x, urange, data_range)
global MaskD;

% Set the intensity range.  If none given, automatically scale.
range(1)=double(min(min(x))); range(2)=double(max(max(x)));
if (nargin==1) urange = range; end;
if (urange(2)==urange(1)) urange(2)=urange(1)*1.0001+1e-10; end 

% Set the data display range.  If none given, display whole image.
if (nargin<3) data_range = [0, size(x,2), 0, size(x,1)]; end

   cla;
   colormap(jet);
   imagesc(double(x).* double(MaskD) + urange(1)*(1.0-double(MaskD)),urange);
   axis image; axis(data_range); hold on;
  