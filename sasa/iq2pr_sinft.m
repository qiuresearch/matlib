function pcf = iq2pr_sinft(iq, q_range, r, mode)
%        pcf = pcf_sinftiq(iq, q_range, r, mode)
%
%   Generate a Pair Correlation Function by Brute Force
%       Inputs -
%                   I versus q -->   data(:,1)= q; data(:,2) = I;
%                   q_range    -->  Restrict q_range(1)<=q<=q_range(2)
%                   r          -->  r grids (the complete points)
%                   mode       -->  "forward" iq-->pcf or "inverse"
%       Outputs - 
%                   Pair Correlation function p(r) --> r(j) and p(j)
%
%   Simply attempts direct inverse FFT of data.
% 
%   $Id: iq2pr_sinft.m,v 1.2 2013/10/22 17:45:41 schowell Exp $
%

% 1) Simple check on input parameters
if (nargin < 1)
   help pcf_sinftiq
   return
end
num_qpoints = length(iq(:,1));

if (nargin < 2)
   q_range=[iq(1,1), iq(num_qpoints,1)];
end

if (nargin < 3)
   r = 0.0:1.0:230.0;
end
num_rpoints = length(r);

if (nargin < 4)
   mode = 'forward';
end

% 2) Initialize some parameters

[qmin, iqmin] = min(abs(iq(:,1)-q_range(1)));
[qmax, iqmax] = min(abs(iq(:,1)-q_range(2)));
qmin = iq(iqmin,1);
qmax = iq(iqmax,1);

disp(sprintf(['PCF_SINFTIQ:: data range to use: Minimum: %0.2f(i=%0d), ' ...
              'Maximum: %0.2f(i=%0d)'], qmin, iqmin, qmax, iqmax));

if (iqmin >= iqmax)
   error('Error: specified q range is invalid!')
   return
end

switch mode
   case 'forward'     % Iq to PCF
      iq(iqmin:iqmax,2) = iq(iqmin:iqmax,2) .* iq(iqmin:iqmax,1);
      pcf = sinft(iq(iqmin:iqmax,:), r, 'adhoc');
      pcf(:,2) = 2.0/pi*pcf(:,2).*pcf(:,1);
   case 'inverse'     % PCF to Iq (here iq is pcf, pcf is iq)
      if (iq(iqmin,1) == 0.0); iqmin = iqmin + 1; end % p(r=0) = 0
                                                      % (excluded!)
      % intensity at Q=0.0
      I0 =  mean(iq(iqmin:iqmax,2)) * (iq(iqmax,1)-iq(iqmin,1));
      iq(iqmin:iqmax,2) = iq(iqmin:iqmax,2) ./ iq(iqmin:iqmax,1);
      pcf = sinft(iq(iqmin:iqmax,:), r, 'adhoc');
      if (pcf(1,1) == 0.0)
         pcf(1,2) = I0;
         pcf(2:end,2) = pcf(2:end,2) ./ pcf(2:end,1);
      else
         pcf(:,2) = pcf(:,2) ./ pcf(:,1);
      end % I(q) is in the right scale already!
   otherwise
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Change History
%
%  $Log: iq2pr_sinft.m,v $
%  Revision 1.2  2013/10/22 17:45:41  schowell
%  updated to use iq2pr_sinft which replaced pcf_sinftiq
%
%  Revision 1.1  2013/09/17 02:54:44  xqiu
%  *** empty log message ***
%
%  Revision 1.1.1.1  2007-09-19 04:45:38  xqiu
%  A new start of my matlab library with new directory structure.
%
%  Revision 1.8  2005/08/06 22:52:32  xqiu
%  *** empty log message ***
%
%  Revision 1.7  2005/07/22 19:23:55  xqiu
%  corresponding changes due to APBS package
%
%  Revision 1.6  2005/01/17 22:26:00  xqiu
%  minor changes
%
%  Revision 1.5  2004/11/20 02:11:45  xqiu
%  minor improvements done!
%
%  Revision 1.4  2004/11/19 05:04:27  xqiu
%  Added comments
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
