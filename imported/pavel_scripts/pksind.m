function s1=pksind(s0,ind,verbose)
%PKSIND(S0, IND, VERBOSE)    select some peaks from pks structure
%S1=PKSIND(S0, 1:5)  returns peaks 1:5 of S0
%S1=PKSIND(S0, 1:5, 1) or
%S1=PKSIND(S0, 1:5, 'v')  returns all but 1:5 peaks of S0
%
%See also RPKS
if nargin<3
    verbose=0;
end
l=length(s0.th2);
if verbose
    i1=1:length(s0.th2);
    i1(ind)=[];
    ind=i1;
end
s1=s0;
n=fieldnames(s0);
for i=1:length(n)
    f=n{i};
    v=eval(['s0.' f ]);
    if isnumeric(v) & isequal(size(v), [l 1])
	eval(['s1.' f ' = s0.' f '(ind);'])
    end
end
