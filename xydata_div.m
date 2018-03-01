function data_in = normalize(data_in, data_ref)
%        data_in = normalize(data_in, data_ref)
% normalize the "data_in" by "data_ref". Interpolation will be
% performed if necessary.

if nargin < 1
   help normalize
   return
end

data_in(:,2) = data_in(:,2) ./ spline(data_ref(:,1), data_ref(:,2), ...
                                      data_in(:,1));

