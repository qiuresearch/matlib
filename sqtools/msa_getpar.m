function msa = msa_getpar(msa)
%        msa = msa_getpar(msa)
% --- Purpose:
%    compute the parameters required to carry out the MSA model calculations
%
% --- Parameter(s):
%     
%
% --- Return(s): 
%        results - 
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: msa_getpar.m,v 1.2 2008-01-05 19:31:40 xqiu Exp $
%

% 1) simple check on input parameter

if (nargin < 1)
  error('should be called with one parameter');
  return
end

% 2) update and copy values from msa
msa.note5 = '*** calculated parameters ***';
msa.beta = 1.0/msa.T/msa.k_B; % 1/(K_BT) 
msa.eta = pi*msa.n*(6.022e-7)*msa.sigma^3/6.0; % volume fraction
msa.mu = 3.0 *msa.eta /(1.0-msa.eta);

% the relative screening power (optimally less than 6)

   % the existance of 4*pi*msa.epsilon is from the SI formula of
   % Coulumb energy (last checked on 11/29/2004).
msa.l_bjerrum = 1.0e10*(1.6022e-19)^2 * msa.beta /(4.0*pi*msa.epsilon_0 ...
                                                  * msa.epsilon); % in
                                                                  % (A)

% the 6.02e-7 is used to adjust the units (last checked on 11/29/2004)
% the Debye-Huckel screening length
msa.kappa = sqrt(6.02e-7*8.0*pi*msa.I*msa.l_bjerrum); 

msa.psi0=0;
msa.k = msa.kappa * msa.sigma; % the unitless quantity

% the surface potential 
msa.psi0 = (1.6022e-9)*msa.z_m/(pi*msa.epsilon*msa.epsilon_0* ...
                                 msa.sigma*(2.0 + msa.kappa* msa.sigma));

% the contact potential in the unit of K_B*T
msa.gamma = exp(msa.k) * msa.beta * pi * msa.epsilon_0 * msa.epsilon ...
    * msa.sigma*(1.0e-10)*msa.psi0^2;
      

% 3) Compute the parameters

if (msa.method == 1) || (msa.method == 2)
   eta = msa.eta;
   k = msa.k;
   
   switch msa.method
      case 1  % the OCM method from Hayter and Penfold
         gamma = msa.gamma;
      case 2  % the GOCM method from Chen S.-H
         
         t02 = msa.beta * 24.0 * (msa.z_m*1.6e-19)^2 * msa.eta/(4*pi* ...
                         msa.epsilon_0*msa.epsilon*msa.sigma*1e-10);
         mu = msa.mu;
         coef_poly = [0.25, 1+mu, (1+mu)^2-msa.k^2/4, -(1+mu)*msa.k^2, ...
                      -msa.k^2*(1+mu)^2-t02];
         G = roots(coef_poly);
         G = min(G((imag(G) == 0) & (real(G) > 0))); % use the mininum
                                                     % G value (See Yun
                                                     % Liu's routine)
         
         gamma = (G/2 + mu) ./ (1+G/2+mu);
         U = mu*(msa.k/2)^(-3) - gamma*(2/msa.k);
         msa.Y = cosh(msa.k/2) + U * (msa.k/2*cosh(msa.k/2) - sinh(msa.k/2));

         gamma = msa.gamma;
         msa.gamma = msa.Y.^2*(msa.z_m*1.6e-19)^2/msa.epsilon/ ...
             msa.epsilon_0/msa.sigma*1e10*msa.beta/4/pi;
         %disp(['OCM gamma=' num2str(gamma) ' GOCM gamma=' num2str(msa.gamma)])         
         %
         gamma = msa.gamma;
      otherwise
         disp('ERROR:: fatal error, this should never happen!')
   end
   % the calculation from Hayter and Penfold paper
   % the formulas in the appendix
   delta = 1.0 - eta;
   alpha(1) = -1.0*(2.0*eta + 1.0)*delta/k;
   alpha(2) = (14.0*eta^2 - 4.0*eta -1.0)/k^2;
   alpha(3) = 36.0*eta^2/k^4;
   beta(1) = -1.0*(eta^2 + 7.0*eta + 1.0)*delta/k;
   beta(2) = 9.0*eta*(eta^2 + 4.0*eta -2.0)/k^2;
   beta(3) = 12.0*eta*(2.0*eta^2 + 8.0*eta -1.0)/k^4;
   nu(1) = -1.0*(eta^3 + 3.0*eta^2 + 45.0*eta + 5.0)*delta/k;
   nu(2) = (2.0*eta^3 + 3.0*eta^2 + 42.0*eta - 20.0)/ k^2;
   nu(3) = (2.0*eta^3 + 30.0*eta - 5.0)/k^4;
   nu(4) = nu(1) + 24.0*eta*k*nu(3);
   nu(5) = 6.0*eta*(nu(2) + 4.0*nu(3));
   
   phi(1) = 6.0*eta/k;
   phi(2) = delta - 12.0*eta/k^2;
   
   tao(1) = (eta + 5.0)/5.0/k;
   tao(2) = (eta + 2.0)/k^2;
   tao(3) = -12.0*eta*gamma*exp(-1.0*k)*(tao(1) + tao(2));
   tao(4) = 3.0*eta*k^2*(tao(1)^2 - tao(2)^2);
   tao(5) = 3.0*eta*(eta + 8.0)/10.0 - 2.0*(2.0*eta + 1.0)^2/k^2;
   
   a(1) = (24.0*eta*gamma*exp(-1.0*k)*(alpha(1) + alpha(2) + ...
                                       (1+k)*alpha(3)) - (2.0*eta + ...
                                                     1.0)^2)/delta^4;
   a(2) = 24.0*eta*(alpha(3)*(sinh(k) - k*cosh(k)) + alpha(2)*sinh(k)- ...
                    alpha(1)*cosh(k))/delta^4;
   a(3) = 24.0*eta*((2.0*eta + 1.0)^2/k^2 - delta^2/2.0 + alpha(3)*(cosh(k) ...
                                                     - 1.0 - k*sinh(k)) ...
                    - alpha(1)*sinh(k) + alpha(2)*cosh(k))/delta^4;
   
   b(1) = (3.0*eta*(eta + 2.0)^2/2.0 - 12.0*eta*gamma*exp(-1.0* ...
                                                     k)*(beta(1) + ...
                                                     beta(2) + (1 + ...
                                                     k)*beta(3)))/delta^4;
   b(2) = 12.0*eta*(beta(3)*(k*cosh(k) - sinh(k)) - beta(2)*sinh(k) ...
                    + beta(1)*cosh(k))/delta^4;
   b(3) = 12.0*eta*(delta^2*(eta + 2.0)/2.0 - 3.0*eta*(eta + 2.0)^2/k^2 ...
                    - beta(3)*(cosh(k) -1.0 -k*sinh(k)) + beta(1)*sinh(k) ...
                    - beta(2)*cosh(k))/delta^4;
   
   v(1) = ((2.0*eta+1)*(eta^2 - 2.0*eta + 10.0)/4.0 - gamma* ...
           exp(-1.0*k)*(nu(4) + nu(5)))/5.0/ delta^4;
   v(2) = (nu(4)*cosh(k) - nu(5)*sinh(k))/5.0/delta^4;
   v(3) = ((eta^3 - 6.0*eta^2 + 5.0)*delta - 6.0*eta*(2.0*eta^3 - ...
                                                     3.0*eta^2 + ...
                                                     18.0*eta + ...
                                                     10.0)/k^2 + ...
           24.0*eta*nu(3) + nu(4)*sinh(k) - nu(5)*cosh(k))/5.0/delta^4;
   
   p(1) = (gamma*exp(-1.0*k)*(phi(1) - phi(2))^2 - (eta + 2.0)/2.0)/ delta^2;
   p(2) = ((phi(1)^2 + phi(2)^2)*sinh(k) + 2.0*phi(1)*phi(2)*cosh(k))/ delta^2;
   p(3) = ((phi(1)^2 + phi(2)^2)*cosh(k) + 2.0*phi(1)*phi(2)*sinh(k) ...
           + phi(1)^2 - phi(2)^2)/delta^2;
   
   t(1) = tao(3) + tao(4)*a(1) + tao(5)*b(1);
   t(2) = tao(4)*a(2) + tao(5)*b(2) + 12.0*eta*(tao(1)*cosh(k) - ...
                                                tao(2)* sinh(k));
   t(3) = tao(4)*a(3) + tao(5)*b(3) + 12.0*eta*(tao(1)*sinh(k) - ...
                                                tao(2)*(cosh(k) - ...
                                                     1.0)) - 2.0* ...
          eta*(eta + 10.0)/5.0 -1.0;
   
   mu(1) = t(2)*a(2) - 12.0*eta*v(2)^2;
   mu(2) = t(1)*a(2) + t(2)*a(1) - 24.0*eta*v(1)*v(2);
   mu(3) = t(2)*a(3) + t(3)*a(2) - 24.0*eta*v(2)*v(3);
   mu(4) = t(1)*a(1) - 12.0*eta*v(1)^2;
   mu(5) = t(1)*a(3) + t(3)*a(1) - 24.0*eta*v(1)*v(3);
   mu(6) = t(3)*a(3) - 12.0*eta*v(3)^2;
   
   lambda(1) = 12.0*eta*p(2)^2;
   lambda(2) = 24.0*eta*p(1)*p(2) - 2.0*b(2);
   lambda(3) = 24.0*eta*p(2)*p(3);
   lambda(4) = 12.0*eta*p(1)^2 - 2.0*b(1);
   lambda(5) = 24.0*eta*p(1)*p(3) - 2.0*b(3) - k^2;
   lambda(6) = 12.0*eta*p(3)^2;
   
   omega_2d = zeros(6);
   for i=1:6
      for j=1:6
         omega_2d(i,j) = mu(i)*lambda(j) - mu(j)*lambda(i);
      end
   end
   
   omega(4) = omega_2d(1,6)^2 - omega_2d(1,3)*omega_2d(3,6);
   omega(3) = 2.0*omega_2d(1,6)*omega_2d(1,5) - omega_2d(1,3)* ...
       (omega_2d(3,5) + omega_2d(2,6)) - omega_2d(1,2)*omega_2d(3,6);
   omega(2) = omega_2d(1,5)^2 + 2.0*omega_2d(1,6)*omega_2d(1,4) - ...
       omega_2d(1,3)*(omega_2d(3,4) + omega_2d(2,5)) - omega_2d(1,2)* ...
       (omega_2d(3,5) + omega_2d(2,6));
   omega(1) = 2.0*omega_2d(1,5)*omega_2d(1,4) - omega_2d(1,3)* ...
       omega_2d(2,4) - omega_2d(1,2)*(omega_2d(3,4) + omega_2d(2,5));
   omega(5) = omega_2d(1,4)^2 - omega_2d(1,2)*omega_2d(2,4);
   
   % 4) Solve the equation for F (only real values should be returned)
   
   F_complex = roots([omega(4:-1:1), omega(5)]);
   F = real(F_complex(abs(F_complex)*0.99 < abs(real(F_complex))));
   
   if isempty(F)
      disp('No real roots were found!')
      return
   end
   
   F = unique(F);
   
   % 5) Compute parameters: A, B, C
   
   C = -1.0*(omega_2d(1,6)*F.^2 + omega_2d(1,5)*F + omega_2d(1,4))./ ...
       (omega_2d(1,3)*F + omega_2d(1,2));
   
   B = b(1) + b(2)*C + b(3)*F;
   
   A = a(1) + a(2)*C + a(3)*F;
   
   msa.note6 = '*** Parameters for OCM model calculation ***';
   msa.omega = omega;
   msa.A = A;
   msa.B = B;
   msa.C = C;
   msa.F = F;
   
   msa.K = -msa.gamma*exp(-msa.k);
   msa.K2 = 0;
   msa.k2 = 0;
   msa.kappa2 = 0;
   msa.psi02 = 0;
   msa.gamma2 = 0;
end

if (msa.method == 3) % two Yukawa potential method
   % just to calculate the msa.gamma2
   msa_tmp = msa;
   % change the ionic strength
   msa_tmp.I = msa_tmp.I2;
   msa_tmp.z_m = msa_tmp.z_m2;
   msa_tmp.method = 2;
   msa_tmp = msa_getpar(msa_tmp);
   % assign back
   msa.psi02 = msa_tmp.psi0;
   msa.kappa2 = msa_tmp.kappa;
   msa.k2 = msa_tmp.k;
   msa.gamma2 = msa_tmp.gamma;
   msa.K2=msa.gamma2*exp(-msa.k2);   % Attraction 
   msa.K=-msa.gamma*exp(-msa.k);     % Repulsion

end
   
if (msa.method == 4)
   % the GOCM method from Wu and Chen
   msa.note7 = '*** Parameters for GOCM model calculation ***';
   msa.Y = [];
   msa.a = [];
   msa.b = [];
   msa.v = [];
   msa.y0 = [];
   msa.K = [];
   
   % the following equations I am not sure about the correctness
   
   t02 = msa.beta * 24.0 * (msa.z_m*1.6e-19)^2 * msa.eta/(4*pi* ...
                         msa.epsilon_0*msa.epsilon*msa.sigma*1e-10);
   mu = msa.mu;
   coef_poly = [0.25, 1+mu, (1+mu)^2-msa.k^2/4, -(1+mu)*msa.k^2, ...
                -msa.k^2*(1+mu)^2-t02];
   G = roots(coef_poly);
   G = min(G((imag(G) == 0) & (real(G) > 0))); % use the mininum
                                               % G value (See Yun
                                               % Liu's routine)
   
   gamma = (G/2 + mu) ./ (1+G/2+mu);
   U = mu*(msa.k/2)^(-3) - gamma*(2/msa.k);
   msa.Y = cosh(msa.k/2) + U * (msa.k/2*cosh(msa.k/2) - sinh(msa.k/2));
      
   msa.gamma = msa.Y.^2*(msa.z_m*1.6e-19)^2/msa.epsilon/ ...
       msa.epsilon_0/msa.sigma*1e10*msa.beta/4/pi;
   
   num_roots = length(msa.Y);
   for i=1:num_roots % get the a, b, and v for C(x) x<1
      if ~isreal(msa.Y(i))
         disp(sprintf('The %ith root %c is complex, skip it!', i, msa.Y(i)))
         continue
      end
      Y = msa.Y(i);
      z=msa.k;
      xi = msa.eta;
      K = -1*msa.beta*msa.z_m^2*(1.6e-19)^2/4.0/pi/ ...
          msa.epsilon_0/msa.epsilon/ msa.sigma*(1e10)*Y^2*exp(-z);
      
      % DEBUG: the parameters to reproduce the vaules in the paper by
      % E. Waisman, Molecular Physics, 1973, Vol. 25, No.1, 45-48
      %         xi=0.49
      %         K=1.336
      %         z=28.751
      %  should give:
      %         a = 51.85
      %         b = -60.278
      %         v = 2.432
      %         y0 = 5.69
      % This was checked to be right on 12/19/2004 11:32pm
      
      % equation #1
      str_equ1 = sprintf('%f*y0^2=%f*b%+f*v%+f*v^2', 24*xi, -4, ...
                         2*z, -1/K/exp(z));
      % equation #2
      str_equ2 = sprintf('%f*y1^2%+f*y0*y2=%f*a%+f*v%+f*v^2', ...
                         24*xi, -48*xi, 24*xi, -2*z^3, z^2/K/ ...
                         exp(z));
      % equation #3
      str_equ3 = sprintf('%f*a%+f*b%+f*v%+f*v^2%+f=0', 8*xi+2*xi^2-1, ...
                         6*xi, 24*xi*(0.5/z-(1-exp(-z)-z*exp(-z))/z^3), ...
                         12*xi/K/z^2*exp(-z)*(sinh(z)/z-2/ ...
                                              z^2*(cosh(z)-sinh(z)/z)) ...
                         - 4*xi/K/z^2*exp(-z), -24*xi*K/z^2*(z+1)+1);
      % equation #4
      str_equ4 = sprintf('%f*a+b%+f*v%+f*v^2-y0%+f=0', 1+0.5*xi, ...
                         (1-exp(-z))/z, (cosh(z)-1)/(2*K*z^2*exp(z)), ...
                         K);
      % equation #5
      str_equ5 = sprintf('%f*a+2*b%+f*v%+f*v^2-y1%+f=0', 1+2*xi, ...
                         exp(-z), (cosh(z)-1+z*sinh(z))/(2*K* ...
                                                        z^2*exp(z)), -K*z);
      % equation #6
      str_equ6 = sprintf('%f*a+2*b%+f*v%+f*v^2-y2%+f=0', 6*xi, ...
                         -exp(-z)/z, sinh(z)/(K*z*exp(z))+ ...
                         cosh(z)/(2*K*exp(z)), K*z^2);
      % solve it                   
      result = solve(str_equ1, str_equ2, str_equ3, str_equ4, ...
                     str_equ5, str_equ6, 'a', 'b', 'v', 'y0', 'y1', 'y2');
      
      % check the result (all numbers should be positive)
      a = eval(result.a);
      b = eval(result.b);
      v = eval(result.v);
      y0 = eval(result.y0);
      y1 = eval(result.y1);
      y2 = eval(result.y2);
      
      for i2 = 1:length(a)
         if isreal(result.a(i2)) && isreal(result.b(i2)) && ...
                isreal(result.v(i2)) && isreal(result.y0(i2)) && ...
                isreal(result.y1(i2)) && isreal(result.y2(i2))
            % save the real solutions only!!!
            msa.a = [msa.a, a(i2)];
            msa.b = [msa.b, b(i2)];
            msa.v = [msa.v, v(i2)];
            msa.y0 = [msa.y0, y0(i2)];
            msa.K = [msa.K, K];
         end
      end
   end
end
