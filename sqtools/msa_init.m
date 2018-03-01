function msa = msa_init(varargin)
%        msa = msa_init(varargin)
% --- Purpose:
%    initialize the msa structure for Hayter-Penfold method calculation
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
% $Id: msa_init.m,v 1.3 2011-04-14 00:23:22 xqiu Exp $
%

% 1) some constants

msa.note0 = '*** some constants ***';
msa.epsilon_0 = 8.8542e-12; % (F/m in MKS unit) permittivity of the free space
msa.k_B = 1.3806503e-23; % the Boltzman constants
 	 	 	 
% 2) User input parameters 
msa.note1 = '*** user parameters ***';
msa.T = 298.0;       % current temperature

% the macromolecule
msa.note2 = '*** the macromolecule ***';
msa.sigma = 50.0;    % diameter of the macromolecule
msa.n = 7.61;        % the concentration (mM)
msa.z_m = 20;        % effective charge
msa.z = 25.0;        % the net charge
msa.z_m2 = 10;       % the "attractive charge" for second Yukawa potential
msa.I2 = 1000;       % the inverse screen length of attractive
                     % force in terms of ionic strength

% the solvent
msa.note3 = '*** the solvent ***';
msa.I=14.77;   % ionic strengh (calculated from mM)
msa.epsilon = 78.3;  % Dielectric constant of the solvent

msa.method = 2; % 1:  OCM method by Hayter and Penfold 2: Chen 's
                % GOCM method
msa.scale = 1.0;

% fitting parameters. those are only for record keeping, the
% fitting setup should always be passed.
msa.note4 = '*** fit setttings ***';

msa.scale_delta = 0;
msa.scale_fit = 0;
msa.scale_limit = 1;
msa.scale_ll = 0.1;
msa.scale_ul = 10.0;

msa.z_m_delta = 1;
msa.z_m_fit = 1;
msa.z_m_limit = 1;
msa.z_m_ll = 0.1;
msa.z_m_ul = 125.0;

msa.n_delta = 0;
msa.n_fit = 0;
msa.n_limit = 1;
msa.n_ll = 0.001;
msa.n_ul = 5.0;

msa.I_delta = 0;
msa.I_fit = 0;
msa.I_limit = 1;
msa.I_ll = 0.02;
msa.I_ul = 1000.0;

msa.sigma_delta = 0;
msa.sigma_fit = 0;
msa.sigma_limit = 1;
msa.sigma_ll = 30.0;
msa.sigma_ul = 230.0;

msa.z_m2_delta = 0;
msa.z_m2_fit = 0;
msa.z_m2_limit = 1;
msa.z_m2_ll = 0.1;
msa.z_m2_ul = 100.0;

msa.I2_delta = 0;
msa.I2_fit = 0;
msa.I2_limit = 1;
msa.I2_ll = 0.02;
msa.I2_ul = 10000.0;
