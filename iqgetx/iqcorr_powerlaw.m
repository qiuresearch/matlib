function [iq, offset] = iqcorr_powerlaw(iq, pow, qrange, varargin)
% --- Usage:
%        iq = iqcorr_powerlaw(iq, pow, qrange, varargin)
%
% --- Purpose:
%
% --- Parameter(s):
%        iq   - nx4 column data
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: iqcorr_powerlaw.m,v 1.1 2013/09/17 03:02:58 xqiu Exp $
%

verbose = 1;
parse_varargin(varargin);

imin = locate(iq(:,1), qrange(1));
imax = locate(iq(:,1), qrange(2));

iqpow = iq;
iqpow(:,2) = iqpow(:,1).^pow;
iqpow(:,2) = iqpow(:,2)/total(iqpow(imin:imax,2))*total(abs(iq(imin:imax,2)));

[num_rows, num_cols] = size(iq);
if (num_cols > 2)
   [iqdummy, scale, offset] = match(iq, iqpow, qrange, 'dy', ...
                                    iq(:,num_cols), 'all', 1);
else
      [iqdummy, scale, offset] = match(iq, iqpow, qrange);
end

iq(:,2) = iq(:,2)-offset;
