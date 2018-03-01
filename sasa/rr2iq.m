function [iq, rg] = rdf2iq(rdf, q)
% --- Usage:
%        [iq, rg] = rdf2iq(rdf, q)
%
% --- Purpose:
%        calculate I(q) and Rg from radial density function,
%        assuming spherical symmetry
%
% --- Parameter(s):
%        var   - 
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: rr2iq.m,v 1.1 2013/09/17 03:00:33 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

%
if ~exist('q', 'var')
   q = linspace(0.001, 1.0, 1001);
end

% calculate I(Q)
iq(:,1) = q;
rdf(:,2) = rdf(:,2).*rdf(:,1);
dummy = sinft(rdf, q, 'adhoc');
iq(:,2) = 4*pi./q.*dummy(:,2);
iq(:,2) = iq(:,2).^2;

% RDF to 4*pi*r^2*R(r)
rdf(:,2) = 4*pi*rdf(:,2).*rdf(:,1);
rg = integrate_numarr(rdf);
rdf(:,2) = rdf(:,2).*rdf(:,1).*rdf(:,1);
rg = sqrt(integrate_numarr(rdf)/rg);
