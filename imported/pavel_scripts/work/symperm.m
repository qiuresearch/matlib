function B = symperm(A,p1,p2)
% B = symperm(A,P1,P2)  index permutation of matrix A from P1 to P2

B = A;
B(p2,:) = B(p1,:);
B(:,p2) = B(:,p1);
