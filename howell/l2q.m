function [q,d]=l2q(l,r,lambda)
%    function [q,d]=l2q(l,r,lambda)
%
%    twoTheta=atan(r/l);
%    q=4*pi/lambda*sin(twoTheta/2);
%    d=2*pi/q;
    
    if nargin <2
        help l2q
        return;
    end 
    
    twoTheta=atan(r/l);
    q=4*pi/lambda*sin(twoTheta/2);
    d=2*pi/q;
    