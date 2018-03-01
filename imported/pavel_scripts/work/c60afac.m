function c60afac
% calculate 9 Cromer-Mann coefficients of f(Q) for C60 molecule

% CM coefficients for C from gsas/data/atmdata.dat
%       a1     b1      a2     b2      a3      b3     a4    b4       c
cmC = [ 2.3100 20.8439 1.0200 10.2075 1.5886  .5687  .8650 51.6512  .2156 ];
% R parameter comes from PRL, vol. 66 (22), 1991, p2912
RC60 = 3.52; % A

% just check the plot
q = linspace(0, 8);
fC = f0asf(cmC, q);
fC60 = fC .* besselj(0, q*RC60);
plot(q, fC, q, fC60, q, sqrt(fC60.^2))


function f0 = f0asf(cmc, Q)
% f0asf(CMC,Q)   calculate f0(Q) using CMC Cromer-Mann coefficients
%   CMC = [a1 b1  a2 b2  a3 b3  a4 b4  c]

cmc = cmc(:).';
a = cmc(1:2:8);
b = cmc(2:2:8);
c = cmc(9);
% sthlam is sin(theta)/lambda, make sure sthlam is a column vector
sthlam = Q(:)./(4*pi);
% allow Q and f0 to have arbitrary shape
f0 = zeros(size(Q));
% using matrix multiplications
f0(:) = exp(sthlam.^2 * (-b)) * a.' + c;
