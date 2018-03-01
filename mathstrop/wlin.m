%  wlin.m takes on the general weighted linear least squares fitting problem.
%  The basic situation is that A * b = <C> where A is a (N*m) set of m fitting
%  curves, b is a m vector of fitting weights for the respective curves and C 
%  is a N vector of variables with white noise.  The white noise on C is such
%  that even though we don't know the absolute strength, we can take the 
%  variance of each to be given by var(C(j)) = phi / w(j).  
%  wlin finds the best values of b, and their uncertainties.

function [b, correl_b, phi] = wlin(A,C,w)  

[N,m] = size(A);  % Figure out the size of the data

% Figure out the D and E matrices
D = zeros(m,m) ;
for i=1:m 
       for j=i:m
                  for k=1:N
                  D(i,j) = D(i,j)+w(k)*A(k,i)*A(k,j);
                  end
       D(j,i) = D(i,j);
       end
end
E = A*inv(D);

% Find b 
b = zeros(m,1);
for i =1:m 
         for j=1:N
          b(i) = b(i) + E(j,i)*w(j)*C(j);
         end
end

%Find phi
F = C- A*b ;
epsilon = 0.0 ;
for i=1:N
      epsilon = epsilon + F(i)*F(i)*w(i);
end
phi = epsilon / (N-m);

% Find the errors in b
G = zeros(m,m);
for i=1:m
for k=1:m
          for j=1:N
              G(i,k) = G(i,k) + A(j,k)*A(j,i)*w(j) ;
          end
end
end
correl_b = phi * inv(D)*G*inv(D);




