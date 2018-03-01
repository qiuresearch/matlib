%  remove_zingers - Statistical Dezingering Image Enhancer
%  [result, Nzing] = remove_zingers(images, bkg, sigma, sigma_cut, gain)
%
%  Takes the images and using bkg, sigma, sigma_cut, gain sums them together
% but excludes from summing those pixels affected by zingers.
%  Thus result = image(:,:,1) + ... + image(:,:,p) - zinger effect.
%
%  images - an array of uint16 M*N images
%			   ie. images(:,:,1), images(:,:,2) etc are each pictures
%				there must be at least two pictures present.
%
%  bkg 	 - the average "black-level" background in each image 
%         - ie.  with no X-rays each pixel should be at bkg.
%			 -  usually between 300-1300, but depends on detector.
%  sigma  - the average standard deviation of readout with no X-ray sig.
%			 -  usually around 5, but again depends on detector and exp length.
%  gain   - the response of detector to a given number of X-rays.
%         -  usually around 1, but also dicey.
%  sigma_cut - the number of standard deviations of noise before we 
%				 - conclude the point was zingers.  
%				 - ie. if sigma_cut=5 and a pixel is 6 std. devs above median,
%				 - we'd conclude it was a zinger.