% function result = slurp(prefix,signal, background)
% 			prefix = starting part of the image file name.
% 			signal = vector of image numbers
%  		background = vector of image backgrounds
%			result = final image.
%  If you call slurp with only prefix and signal, it will load the signal,
% dezinger/distortion/intensity correct and average it and return it as result.
% It will not scale for the X-ray flux as it has no background.
%  If you give it a background, it will load the signal, dezinger/distortion/intensity
% correct, subtract the background, average and then scale for the x-ray flux.  Note, it 
% must be a background and not a buffer!
%  Either way, result is will be a M*N image.
%  Examples
%			x1=slurp('Mochrie',1);  ->  Loads image Mochrie1.tif into variable x1.
%					no dezingering or flux correction but distortion/intensity corrected.
%        x2=slurp('Mochrie',[3,6:8]); -> Gives the average of images 
%					Mochrie3.tif, Mochrie6.tif, Mochrie7.tif and Mochrie8.tif
%					dezingered/distortion/intensity corrected but no flux correction.
%        x3=slurp('Kwok',[3,5],[7:8]); -> Gives average of Kwok3.tif and Kwok4.tif minus
%				   the background of Kwok7.tif and Kwok8.tif
%					dezingered/distortion/intensity/background subtracted and flux corrected.
%
% Dependencies - dezing(), correct(), averge_tag()


function result = slurp(prefix, signal,background)

% load the signal, dezinger if more than one and distortion and intensity correct.
im_sigr = imread(sprintf('%s%d.tif',prefix,signal(1)),'tif');
for k=2:length(signal)
   im_sigr(:,:,k) = imread(sprintf('%s%d.tif',prefix,signal(k)),'tif');
end
if (length(signal)<2)
   im_sig = double(im_sigr);
else
   im_sig = dezing(im_sigr); 
end   
im_sig = correct(im_sig);
im_sig = im_sig / length(signal);

% if there is a background, load it, dezinger it and distortion adn intensity correct it.
if (nargin>2)
   im_backr = imread(sprintf('%s%d.tif',prefix,background(1)),'tif');
   for k=2:length(background)
      im_backr(:,:,k) = imread(sprintf('%s%d.tif',prefix,background(k)),'tif');
   end
   if (length(background)<2)
      im_back=double(im_backr);
   else
      im_back=dezing(im_backr);
   end
   im_back=correct(im_back);
   im_back=im_back / length(background);   
end

% if there is no background, just return the average, else normalize flux.
if (nargin<3)
   result = im_sig;
else
   result = im_sig - im_back;
   tag_val = average_tag(prefix,signal)-average_tag(prefix,background);
   %result=result/tag_val;   
end

