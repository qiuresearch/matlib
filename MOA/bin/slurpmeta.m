% function result = slurpmeta(prefix,signal, background)
% 			prefix = starting part of the image file name.
% 			signal = vector of image numbers
%  		background = vector of image backgrounds
%			result = final image.
%
%    slurpmeta is adaptation of slurp to work with meta-optics detector
%    slurpmeta is like slurp, except for the following: 
%      adds leading zeros
%      adds trailing zeros after filenumber increment.
%      %<OLD>no intensity or distortion correction.
%      %<OLD>no call to average tag
%
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

function result = slurpmeta(prefix, signal,background)

%add preceding zeros to filenumbers
for i=1:length(signal)
    if signal(i)>99.5
        sigstring{i} = int2str(signal(i));
    elseif signal(i)>9.5
        sigstring{i} = strcat('0',int2str(signal(i)));
    else
        sigstring{i} = strcat('00',int2str(signal(i)));
    end %if 
end %for

if nargin>2
for i=1:length(background)
    if background(i)>99.5
        bkgdstring{i} = int2str(background(i));
    elseif background(i)>9.5
        bkgdstring{i} = strcat('0',int2str(background(i)));
    else
        bkgdstring{i} = strcat('00',int2str(background(i)));
    end %if 
end %for
end %if nargin

%setup the postfix (extra zeros after filenumber increment)
postfix='_000';

% load the signal, dezinger if more than one and distortion and intensity correct.
if (nargin>1.5)
%im_sigr = imread(sprintf('%s%d.tif',prefix,signal(1)),'tif');
    fname=[prefix, sigstring{1}, postfix, '.tif'];
    im_sigr=imread(fname, 'tif');
    %im_sigr = adsctake(strcat(prefix, sigstring{1}, '.dkc'));
else
    %im_sigr = imread(sprintf('%s.tif',prefix),'tif');
    %im_sigr = adsctake(prefix);
    fname=[prefix, '.tif'];
    im_sigr=imread(fname, 'tif');
    signal=[1];
end

for k=2:length(signal)
%   im_sigr(:,:,k) = imread(sprintf('%s%d.tif',prefix,signal(k)),'tif');
%    im_sigr(:,:,k) = adsctake(strcat(prefix, sigstring{k},'.imx_0'));
    fname=[prefix, sigstring{k}, postfix, '.tif'];
    im_sigr(:,:,k) = imread(fname, 'tif');
end
if (length(signal)<2)
   im_sig = double(im_sigr);
else
   im_sig = double(dezing(uint16(im_sigr))); 
%   im_sig = double(im_sigr);     %% TEMPORARY DISABLE DEZING 
end   
im_sig = correct(im_sig);
im_sig = im_sig / length(signal);

% if there is a background, load it, dezinger it and distortion adn intensity correct it.
if (nargin>2)
   %im_backr = imread(sprintf('%s%d.tif',prefix,background(1)),'tif');
   %im_backr = adsctake(strcat(prefix, bkgdstring{1},'.imx_0'));
   fname=[prefix, bkgdstring{1}, postfix, '.tif'];
   im_backr = imread(fname, 'tif');
   for k=2:length(background)
      %im_backr(:,:,k) = imread(sprintf('%s%d.tif',prefix,background(k)),'tif');
      %im_backr(:,:,k) = adsctake(strcat(prefix, bkgdstring{k},'.imx_0'));
      fname=[prefix, bkgdstring{k}, postfix, '.tif'];
      im_backr(:,:,k) = imread(fname, 'tif');
   end
   if (length(background)<2)
      im_back=double(im_backr);
   else
      im_back=dezing(uint16(im_backr));
      %im_back=double(im_backr);      %%TEMPORARY DISABLE DEZING
    
  end
   im_back=correct(im_back);
   im_back=im_back / length(background);   
end

% if there is no background, just return the average, else normalize flux.
if (nargin<3)
   result.im = im_sig;
   %if (nargin >1.5) result.tag = average_tag(prefix,signal);
   %else
   %    result.tag=average_tag(prefix);
   %end
else
   result.im = im_sig - im_back;
%%%   tag_val = average_tag(prefix,signal)-average_tag(prefix,background);
   %tag_val = average_tag(prefix,signal);
   %result.tag = tag_val;
%%%   result=result/tag_val;   
end

%set tag value to dummy value
result.tag=1;
