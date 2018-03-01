%  get_noise_stats - Statistical Zinger Noise Modeller.
%  [bkg, sigma, gain, concerns] = get_noise_stats(images)
%
%  Takes the images and compares them to get intensity and variance histograms.
%  Returns the bkg, sigma, gain and any concerns it had in doing the estimate.
%  images - an array of uint16 M*N images
%			   ie. images(:,:,1), images(:,:,2) etc are each pictures
%				there must be at least two pictures present.
%  bkg 	 - the average "black-level" background in each image 
%         - ie.  with no X-rays each pixel should be at bkg.
%			 -  usually between 300-1300, but depends on detector.
%  sigma  - the average standard deviation of readout with no X-ray sig.
%			 -  usually around 3, but again depends on detector and exp length.
%  gain   - the response of detector to a given number of X-rays.
%         -  usually around 1, but also dicey.
%  concerns - a string containing any warnings from get_noise_stats.