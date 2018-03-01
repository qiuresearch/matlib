function s2=pkscat(s0, s1, i0, i1)
%PKSCAT(S0, S1, I0, I1)    joins 2 pks structures
%S2=PKSCAT(S0, S1, 1:5, 3)  returns peaks 1:5 of S0 joined with
%   peak 3 of S1
%
%See also RPKS, PKSIND
if nargin>2
    s0=pksind(s0,i0);
end
if nargin>3
    s1=pksind(s1,i1);
end
l=length(s0.th2);
s2=s0;
n=fieldnames(s0);
for i=1:length(n)
    f=n{i};
    v=eval(['s0.' f ]);
    if isnumeric(v) & isequal(size(v), [l 1]) & isfield(s1,f)
	eval(['s2.' f ' = [s0.' f '; s1.' f '];' ])
    end
end
