%  function [x, covar] = lin_reg(data,y, w)
%
%   Takes as input the N*M matrix data and N-column vector y.
%   Assumes a fit of the form 
%                       data * x = y 
%    where x = M column vector.
%
%   Optional parameter is W, a N-column vector of weights.
%
%   Performs a weighted least square fit.
%
%   Returns the mean values in x, a M element vector.
%   Returns < delta_x delta_x' > in covar, a M*M array

function [x,covar] = lin_reg(data,y,w)

% Equal weighting if none specified.
if (nargin<3)
    w = eye(length(data));
else
    w = diag(w);
end

% Compute x and covar
C = data'*w*data; 
S = inv(C)* data' * w;
x = S * y;
e_vec = y - data*x;
ers = (e_vec' * w * e_vec)/trace(w);
covar = ers * S * inv(w) * S';


