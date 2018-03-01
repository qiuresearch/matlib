function I = rmclay(th2, i0);
%RMCLAY    removes clay background from XRD data
%   I = RMCLAY(TH2, I0)
%   RMCLAY(H)   removes on line object with handle H

%   1999 by Pavol

claydata='\PAVOL\DATA\VARIOUS\z11243.raw';
tol=0.5;                                %angle toleration
if nargin==1
    h=findobj(th2(:), 'flat', 'type', 'line');
    for i=1:length(h)
        t0=get(h(i), 'xdata');
        i0=get(h(i), 'ydata');
        i1=rmclay(t0,i0);
        set(h(i), 'ydata', i1);
    end
    return;
end

[th2cl,icl]=rraw(claydata);
[clmax,n]=max(icl);
tclmax=th2cl(n);
I=i0;
j=( th2>=tclmax-tol & th2<=tclmax+tol );
tpclmax=th2(j);
[pclmax,m]=max(i0(j));
tpclmax=tpclmax(m);
K=pclmax/clmax;                    %scaling factor
th2cl=th2cl+tpclmax-tclmax;        %shift peak to peak...
i=find(th2>=th2cl(1) & th2<=th2cl(length(th2cl)));
I(i)=I(i)-K*interp1(th2cl, icl, th2(i));
i=find(I(2:length(I)-1)<0)+1;
I(i)=5*rand(size(i));
