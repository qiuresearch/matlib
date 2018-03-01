function S1=smted(s0, p, isshow)
%SMTED     smooth ted data, 
%S=SMTED(S0, P), where S0 is ted structure or filename
%   P is smoothing parameter, P==0 does lsq line fit, 
%   P==1 results in the same curve
%   P=[P1 P2] uses different parameters for K and D smoothing
%S=SMTED(S0, P, 1) or SMTED(S0,P) without output argument plots
%   the original and smoothened curves

if ~isstruct(s0)
    s0=rted(s0);
end
if isstr(p)
    p=eval(p);
end
if length(p)<2
    p(2)=p(1);
end
if nargin<3
    if nargout==0
	isshow=1;
    else
	isshow=0;
    end
end

s=s0;
for a=1:length(s0.f)
    s.k(:,a)=csaps(s0.t, s0.k(:,a), p(1), s0.t);
    s.d(:,a)=csaps(s0.t, s0.d(:,a), p(2), s0.t);
end
if isshow
    figure(clf);
    h0=shted(s0, 'sk.');
    set(h0,'markersize',3)
    holdall on;
    shted(s);
end
if nargout>0
    S1=s;
end
