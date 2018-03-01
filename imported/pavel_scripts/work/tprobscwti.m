function pout = tprobscwti( c )
% POUT = TPROBSCWTI( C )
% maximize the entropy of C(1)Sc, C(2)W, C(3)Ti cations on
% the tetrahedron sites, sum(C(1:3)) = 1
% POUT is a vector of probabilities of cation arrangements

c_o = optimset( 'TolX', 1e-6, 'TolFun', 1e-6 );
% sum of molar ratios must be 4
c = 4*c(:)./sum(c);
% tetrahedron configuration matrix:
M = [
%   Sc  W   Ti  #conf.
    4   0   0   1       % 1
    0   4   0   1       % 2
    0   0   4   1       % 3
    3   1   0   4       % 4
    0   3   1   4       % 5
    1   0   3   4       % 6
    1   3   0   4       % 7
    0   1   3   4       % 8
    3   0   1   4       % 9
    2   2   0   6       % 10
    0   2   2   6       % 11
    2   0   2   6       % 12
    2   1   1   12      % 13
    1   2   1   12      % 14
    1   1   2   12      % 15
];

% constraint matrix
Aeq = M(:,1:3)';
beq = [ c(:) ];

% minimization through linprog
f = -M(:,4);
p = linprog( f, [], [], Aeq, beq, zeros(15,1), ones(15,1), [] , c_o);


% pretty print
p( abs(p) < optimget(c_o, 'TolX') ) = 0;
[ignore, i] = sort(-p);
out = [M p]; out = out(i,:);
fprintf('\n' );
fprintf('  Sc   W  Ti  #c         p\n' );
fprintf('%4i%4i%4i%4i%10.6f\n', out');
fprintf('\nexp(S/k) = %.4f\n', -f'*p);

if nargout > 0
    pout = p;
end
