%  get_noise_data - Statistical Zinger Noise Data Gatherer.
%  [Intensity, Variance] = get_noise_stats(images, exclude_width, 
%                                          exclude_height, sample_fraction)
%
%  Takes the images and compares them to get intensity and variance lists.
%  Excludes fraction exclude_width near vertical edges and exclude_height near
%  horizontal edges.  Only samples a fraction of points, sample_fraction.
%  Returns the Intensity and Variance of a set of points.
%  images - an array of uint16 M*N images
%			   ie. images(:,:,1), images(:,:,2) etc are each pictures
%				there must be at least two pictures present.
%  exclude_width - any pixel within 0.5*exclude_width of left or right edge
%                  is excluded.  Clearly exclude_width between 0 and 1.
%  exclude_height - any pixel within 0.5*exclude_height of top or bottom is
%		              is excluded.  again between 0 and 1.
%  sample_fraction -  fraction of pixels sampled.  between 0 and 1.
%  Intensity - the median intensity at each point sampled.
%  Variance - the variance at each point sampled.
