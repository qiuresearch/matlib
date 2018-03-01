function [l,q]=d2l(d,lambda,r)
%    function [l,q]=d2l(d,lambda,r)
%
%    q=2*pi/d;
%    theta=asin(q*lambda/(4*pi));
%    l=r/tan(2*theta);

    if nargin < 3
        help d2l
        return;
    end
    
    q=2*pi/d;
    theta=asin(q*lambda/(4*pi));
    l=r/tan(2*theta);

    