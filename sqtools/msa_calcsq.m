function [sq, gr, ur, cr] = msa_calcsq(msa, Q, r, varargin)
%        [sq, gr, ur, cr] = msa_calcsq(msa, Q, r, varargin)
% --- Purpose:
%    compute the MSA model's predictions
%
% --- Parameter(s):
%     msa - a structure of MSA parameters, see msa_getpar()
%       Q - the Q vector for calculation (not recommended, defaults
%       work better as wide Q range is necessary for successful
%       S(Q)<->G(r) conversion.
%
% --- Return(s): 
%        sq - S(Q)
%        gr - G(r)
%        cr - C(r), the direct correlation function
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: msa_calcsq.m,v 1.2 2011-04-27 18:05:26 xqiu Exp $
%

% 1) simple check on input parameters

verbose = 1;
parse_varargin(varargin);

% 2) Q, r space data 
if (nargin > 1)
   Q_orig = Q;
else
   Q_orig = linspace(0, 0.6, 251);
end
if (nargin > 2)
   r_orig = r;
else
   r_orig = linspace(msa.sigma/100, msa.sigma*5, 201);
end

% use fixed Q to do the calculation
if (msa.method == 3)  % Two Yukawa Potential needs more points
   Q = linspace(0.0,1200/msa.sigma, fix(32001));
else
   Q = linspace(0.001,0.6,251);
end
K = Q*msa.sigma;  % unitless number
num_Ks = length(K);
K = reshape(K, 1, num_Ks);

sq = zeros(num_Ks, 2);
sq(:,1) = K(:);

r = linspace(msa.sigma/100, max(msa.sigma*5, r_orig(end)), 201);
x = r/msa.sigma; % normalized distance
num_xs = length(x);
x = reshape(x, 1, num_xs);

gr = zeros(num_xs, 2);
gr(:,1) = x;

% 3) Compute the S(K) for all Fs

switch msa.method
   case {1,2}   % the Hayter & Penfold method or Chen's GOCM 
      num_roots = length(msa.F);
      if (num_roots < 1)
         disp(['ERROR:: no parameters available, maybe you should ' ...
               'run msa_getpar() first!']);
         return
      end
      
      a_K = zeros(1, num_Ks);
      s_K = zeros(num_roots, num_Ks);
      g_x = zeros(num_roots, num_xs);

      % initialize some constants
      eta = msa.eta;
      k = msa.k;
      gamma = msa.gamma;
      
      for i_F =1:num_roots
         A = msa.A(i_F);
         B = msa.B(i_F);
         C = msa.C(i_F);
         F = msa.F(i_F);
         
         a_K(:) = A*(sin(K) - K.*cos(K))./(K.^3) + B * ((2.0./(K.^2)- ...
                                                         1.0).*K.*cos(K) ...
                                                        + 2.0*sin(K) ...
                                                        -2.0./K)./ ...
                  (K.^3) + eta*A*(24.0./(K.^3) + 4.0*(1.0 - ...
                                                      6.0./(K.^2)).*sin(K) ...
                                  - (1.0 - 12.0./(K.^2) + 24.0./ ...
                                     (K.^4)).*K.* cos(K))/2.0./(K.^3) ...
                  + C*(k*cosh(k)*sin(K) - K*sinh(k).*cos(K))./ ...
                  K./(K.^2+k^2) + F*(k*sinh(k)*sin(K) - K.*(cosh(k)*cos(K) ...
                                                           -1.0))./ ...
                  K./(K.^2 + k^2) + F*(cos(K) - 1.0)./(K.^2) - ...
                  gamma*exp(-1.0*k)*(k*sin(K) + K.*cos(K))./K./(K.^2 + k^2);
         
         s_K(i_F,:) = 1.0./(1.0 - 24.0*eta*a_K);
         sq(:,2) = (s_K(i_F,:)-1.0) .* K;
         gr(:,:) = sinft(sq, x);
         g_x(i_F,:) = 1.0 + 1.0/12.0/pi/eta./x.*(gr(:,2)');
      end
   case 3   % two Yukawa potential
      Z1=msa.k2;   % z is simply the inverse debye huckel screening length
      Z2=msa.k;
      K1=msa.K2;   % Attraction (positive)
      K2=msa.K;    % Repulsion (negative)
      volF = msa.eta;
      if (max(Z1, Z2) > 20) && (Z1 < Z2) % switch the order of Z1,Z2
         dummy = Z1; Z1 = Z2; Z2 = dummy;
         dummy = K1; K1 = K2; K2 = dummy;
      end
      [calSk,rootCounter,calr,calGr,errorCode]=CalTYSk(Z1,Z2,K1,K2,volF,K);
      
      num_roots = 1;
      s_K = calSk;
      g_x = interp1(calr, calGr, x);
   case 4   % the Wu & Chen method using my numerical solution
      num_roots = length(msa.a);
      if (num_roots < 1)
         disp(['ERROR:: no parameters available, maybe you should ' ...
               'run msa_getpar() first!']);
         return
      end

      c_x = zeros(num_roots, num_xs);
      c_K = zeros(num_roots, num_Ks);
      s_K = zeros(num_roots, num_Ks);
      g_x = zeros(num_roots, num_xs);

      % initialize some constants
      xi = msa.eta;
      z = msa.k;
      i_x1 = locate(x,1);

      for i1 = 1:num_roots
         c_x(i1, i_x1:end) = msa.K(i1)*exp(-z*(x(i_x1:end)-1))./x(i_x1:end);
         c_x(i1, 1:i_x1-1) = -1*(msa.a(i1)+msa.b(i1)*x(1:i_x1-1)+0.5*xi* ...
                                 msa.a(i1)*x(1:i_x1-1).^3 + ...
                                 msa.v(i1)/z*(1- exp(-z* x(1: i_x1-1))) ...
                                 ./x(1:i_x1-1) + msa.v(i1)^2*(cosh(z*x(1: ...
                                                           i_x1-1))- ...
                                                           1)/(2* ...
                                                           msa ...
                                                           .K(i1)*z* ...
                                                           z* exp(z)));
         gr(:,2) = 4*pi*x.*c_x(i1,:);
         sq(:,:) = sinft(gr, K);
         c_K(i1,:) = sq(:,2)./K(:);
         s_K(i1,:) = 1./(1-6*xi/pi*c_K(i1,:));
         sq(:,2) = (s_K(i1,:)-1) .* K;
         gr(:,:) = sinft(sq, x);
         g_x(i1,:) = 1.0 + 1.0/12.0/pi/xi./x.*(gr(:,2)');
      end
end

% 4) select the "good" one and set it to the sq, gr
if (num_roots > 1)
   i_end = locate(x, 0.98);
   [g_min, i_min] = min(sum(abs(g_x(:,1:i_end)), 2));
else 
   i_min = 1;
end

sq(:,1) = Q;
sq(:,2) = s_K(i_min, :);
gr(:,1) = r;
gr(:,2) = g_x(i_min, :);

% 5) get the Q in the passed range
sq_new(:,1) = Q_orig;
sq_new(:,2) = interp1(sq(:,1), sq(:,2), sq_new(:,1));
if (msa.method ~= 3) && (sq_new(1,1) == 0)
   sq_new(1,2) = -1.0/msa.A(i_min);
end
sq=sq_new;
gr_new(:,1) = r_orig;
gr_new(:,2) = interp1(gr(:,1), gr(:,2), gr_new(:,1));
gr=gr_new;

% 6) direct correlation function cr
if (nargout > 2)
   ur(:,1) = gr(:,1); % linspace(msa.sigma, max(msa.sigma*5, r_orig(end)),251);;
   cr = gr;
   i_b = locate(cr(:,1), msa.sigma);
   switch msa.method
      case {1,2}
         ur(:,2) = msa.gamma*exp(-1.0*msa.kappa*ur(:,1))./ur(:,1)*msa.sigma;
         A = msa.A(i_min);
         B = msa.B(i_min);
         C = msa.C(i_min);
         F = msa.F(i_min);
         x=cr(1:i_b,1)/msa.sigma;
         cr(1:i_b,2) = A + B*x + 0.5*eta*A*x.^3 + C*sinh(k*x)./x + ...
             F*(cosh(k*x)- 1.0)./x;
         x=cr(i_b:end,1)/msa.sigma;
         cr(i_b:end,2) = -1.0*msa.gamma*exp(-1.0*msa.k*x)./x;
      case {3,4}
         ur(:,2) = (msa.gamma*exp(-1.0*msa.kappa*ur(:,1)) - ...
                    msa.gamma2*exp(-1.0*msa.kappa2*ur(:,1))) ...
                   ./ur(:,1)*msa.sigma;
         cr(1:i_b,2) = 0;
         x=cr(i_b:end,1);
         cr(i_b:end,2) = -(msa.gamma*exp(-1.0*msa.kappa*x) - ...
                           msa.gamma2*exp(-1.0*msa.kappa2*x))./x*msa.sigma;
      otherwise
         warning('Unknown method of msa_calcsq, calculation aborted!');
   end   
end
