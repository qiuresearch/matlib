function data = myConv(data1, data2)  %, varargin)
% --- Usage:
%        data = myConv(data1, data2)  %, varargin)
%
% --- Purpose:
%        Convolute data1 with data2
%        
%
%--- Parameter(s):
%        data1 should have 3 parameters (Q, I(Q), sigmaQ)
%        data2 should have 2 parameters (Q, I(Q))
%
% --- Return(s): 
%        data the same size as data1
%
% --- Example(s):
%
% $Id: myConv.m,v 1.4 2012/12/07 19:38:48 schowell Exp $

    
    if 0==exist('data1')
        help myConv
        return
    end
    
    i1=size(data1,1);
    i2=size(data2,1);
    I1=data1(:,2);
    I2=data2(:,2);
    Q1=data1(:,1);
    Q2=data2(:,1);
    sigma=data1(:,3);
    
    %    [i3,mData]=min(i1,i2)
    data=data1;
    data(:,2)=0;
    rhs=zeros(i1,i2);
    
    for i=1:i1
      rhs(i,:)=I2/sqrt(2*sigma(i)^2*pi).*exp(-(Q1(i)-Q2).^2/(2*sigma(i)^2));
      % data(i,2)=sum(rhs(i,:))
      data(i,2) = trapz(Q2,rhs(i,:));
    end
%    figure
%    plot(data1(:,1),data1(:,2),data2(:,1),data2(:,2)/(4.6*10^8));
%    figure
%    plot(data(:,1),data(:,2));%/(7.2298*10^10));
%    set(gca, 'Xscale', 'log')
    %    set(gca, 'Yscale', 'log')
    
