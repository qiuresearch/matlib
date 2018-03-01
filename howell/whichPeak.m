function [n1,L,dif]=whichPeak(n,q1,q2,L0,lambda,d)
%    function [n1,p,dif]=whichPeak(n,q1,q2,L0,lambda,d)
%    n:   max n to try
%    q1:  q for peak 1
%    q2:  q for peak 2
%    L0:  L used to calculate q1 and q2
%    lambda: beam wavelength (for Cu k_\alpha: 1.54 A)
%    d:   spacing of calibrant (AgBeh: 58.38)
%    
%    for i=1:n                            
%        p1(i,1)=calcL(i,q1,L0,lambda,d);    
%        p2(i,1)=calcL(i+1,q2,L0,lambda,d);    
%    end
%    dif.val=abs(p1-p2);
%    
%    [dif.min,n1]=min(dif.val);
%    p=[p1,p2]

    if nargin<6
        help whichPeak
        return;
    end
    
    for i=1:n                            
        Lp1(i,1)=calcL(i,q1,L0,lambda,d);    
        Lp2(i,1)=calcL(i+1,q2,L0,lambda,d);    
    end
    dif.val=abs(Lp1-Lp2);
    
    [dif.min,n1]=min(dif.val);
    L=[Lp1,Lp2]