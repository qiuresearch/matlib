function sconfig = sas_resolution_sigmaQ(sconfig, varargin)
% --- Usage:
%        sconfig = sas_resolution_sigmaQ(sconfig, varargin)
%
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%        var   - 
%
% --- Example(s):
%
% $Id: sas_resolution_sigmaQ.m,v 1.1 2012/06/30 22:08:37 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

% The formula is based on "the SANS toolbox" by Hammouda

% length is in mm; R1 and R2 are radius; pixelsize is the diameter
sconfig = struct('lambda', 1.5417, 'd_lambda', 0.001, 'L1', 1500, 'R1', ...
               1, 'L2', 220, 'R2', 0.5, 'pixelsize', 0.150);

% values used by the book on page 158
%sconfig = struct('lambda', 6, 'd_lambda', 6*0.13, 'L1', 16140, 'R1', ...
%               7.15, 'L2', 13190, 'R2', 6.35, 'pixelsize', 5);


sconfig.sigmaQ2 = 2*(2*pi/(sconfig.lambda*sconfig.L2))^2*((sconfig.L2/ ...
                                                  sconfig.L1)^2* ...
                                                  sconfig.R1^2/4+ ...
                                                  ((sconfig.L1+ ...
                                                  sconfig.L2)/ ...
                                                  sconfig.L1)^2* ...
                                                  sconfig.R2^2/4+ ...
                                                  sconfig.pixelsize^2/12);
sconfig.sigmaQ2_qdep = 1/6*(sconfig.d_lambda/sconfig.lambda)^2;

sconfig.sigmaQ = sqrt(sconfig.sigmaQ2);
