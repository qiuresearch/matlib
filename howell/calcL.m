function [L,r] = calcL(n,q0,L0,lambda,d)
%  function [L,r] = calcL(n,q0,L0,lambda,d)
%
%  d for AgBeh is 58.38 A
%
%  Make sure q0 is in inverse ANSTROMS, not inverse NANOMETERS (divide by 10)!
if nargin<5
    help calcL
    return;
end

%clc
disp('Make sure q0 is in inverse ANSTROMS, not inverse NANOMETERS (divide by 10)!');
theta0=asin(q0*lambda/(n*4*pi));
r=L0*tan(2*theta0);
L=r/tan(2*asin(lambda/(2*d)));
