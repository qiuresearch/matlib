function [es, p] = fpsct( p234 )
% es = fpsct( p234 )
% maximize the entropy of 1/3Sc 2/3W on tetrahedron sites
% p234 is 3vector of probabilities of having 2,3,4 Sc in T

%constraints:
p2 = p234(1);
p3 = p234(2);
p4 = p234(3);
p0 = p2 + 2*p3 + 3*p4 - 1/3;
p1 = -2*p2 - 3*p3 - 4*p4 + 4/3;

es = -1 * ( p0 + 4*p1 + 6*p2 + 4*p3 + p4 );
% penalty for out of boundary...
p = [ p0 p1 p2 p3 p4 ];
es = es + 100*sum( p(p>1) - 1 ) + 100*sum( -p(p<0) );
