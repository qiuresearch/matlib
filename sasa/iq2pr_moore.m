function [pr, rms_error] = pcf_moore(data_in, q_range, D)
%        [pr, rms_error] = pcf_moore(data_in, q_range, D)
%
%   Generate a Pair Correlation Function using Moore's method (Moore, PB.
%   Meth. of Exper. Phys. (1982) Vol 20 p337-390)
%
%       Inputs -
%                   I versus q -->   data(:,1)= q; data(:,2) = I;
%                   q_range    -->  Restrict q_range(1)<=q<=q_range(2)
%                   D       --->  Maximum correlation length.
%
%       Outputs - 
%                   Pair Correlation function p(r) --> r(j) and p(j)
%                   RMS_Error --> Root Mean square error difference between
%                       theoretical I versus Q and measured I versus q.
%
%   Moore's method assumes that the correlation function goes to zero for
%   r>D.   Thus, D must be larger than the size of the object.
%   Moore's method decomposes p(r) into a sum of sine waves - 
%               p(r) = Sum (n_min, n_max) An * sin(n* pi * r/D);
%
%  It takes whatever value of D you care to give it, figures out what harmonics
%  of n it is allowed to fit (from the measured q-range) and then goes off 
%  and attempts a least square's fit of the An co-efficients to the data.

if (nargin < 1)
   help pcf_moore
   return
end

% Cut the data just to the allowed q_range;
temp = length(data_in); jmin = 1;
while ((jmin<temp)&(data_in(jmin,1)<q_range(1)))
    jmin=jmin+1;
end
jmax=jmin;
while ((jmax<temp)&(data_in(jmax,1)<q_range(2)) )
    jmax = jmax+1;
end
data = data_in([jmin:jmax],[1,2]);

% Determine the allowed harmonics
n_min = ceil(D * min(data(:,1))/ pi * 0.5) ;
n_max = floor(D * max(data(:,1))/ pi) ;

% Now do the least squares fit.
N = size(data,1);

% Compute what each term in the pcf looks like in I versus q space.
for j=n_min:n_max
   temp1 = j*pi*(-1.0)^(j+1)/D ;
   for i=1:N
      A(i,j-n_min+1) = sin(data(i,1)*D)/( (j*pi/D)^2.0 - data(i,1)^2 );
      A(i,j-n_min+1) = temp1 * A(i,j-n_min+1) / data(i,1);
   end
end

% Set up and do the least squares fit.
C = data(:,2); w = zeros(N,1);
for j=1:N
   w(j) = data(j,1); 
end
[b , correl_b, e] = wlin(A,C,w);

% Evaluate the fit in I versus q space.
F = A*b; diff = C - F; rms_error = sqrt(sum(diff.*diff)/length(diff));

% What the fit looks like in r-space
p(200) = 0.0;
r(200) = 0.0 ;
sine(n_max-n_min+1) = 0.0;
for i=1:200
   r(i) = (i-0.5)/200.0*D ;
   p(i) = 0.0 ;     
   for j=1:(n_max-n_min+1)
      sine(j) = sin((j+n_min-1)*r(i)*pi/D);
      p(i) = p(i) + b(j)*sine(j);
   end
end
p = p.*r ;

% Finally Normalize p
p = p / (sum(p) * (r(2)-r(1) ));

% return
pr(:,1) = r;
pr(:,2) = p;
