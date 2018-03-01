function [data, a, b] = linearcombo(dataa, datab, dataz, varargin);
% --- Usage:
%        [data, a, b] = linearcombo(dataa, datab, dataz, varargin);
% --- Purpose:
%        try linearly combine dataa and datab to match dataz. 
% --- Parameter(s):
%        dataa, datab, dataz - nxm matrix (m>=2)
%        varargin - 'match_range': all (default)
%                   'check_stability': 0 (default). This will vary the
%                   a & b systematically, and check how good the match
%                   depends on a & b.
% --- Return(s):
%        data - same dimension as dataz, with data(:,2) being the
%               linearcombo. If 'check_stability', data is the
%               difference from dataz as a function of a.
%
% --- Example(s):
%
% $Id: linearcombo.m,v 1.1 2013/08/17 17:00:50 xqiu Exp $
%

if (nargin < 1)
   help linearcombo
   return
end

match_range = dataa([1,end],1);
check_stability = 0;

verbose = 1;
parse_varargin(varargin);

% reduce the data
imin = locate(dataz(:,1), match_range(1));
imax = locate(dataz(:,1), match_range(2));
dataz = dataz(imin:imax, :);
dataa = [dataz(:,1), interp1(dataa(:,1), dataa(:,2), dataz(:,1))];
datab = [dataz(:,1), interp1(datab(:,1), datab(:,2), dataz(:,1))];

%
if (check_stability == 0)
   suma2 = sum(dataa(:,2).*dataa(:,2));
   sumab = sum(dataa(:,2).*datab(:,2));
   sumb2 = sum(datab(:,2).*datab(:,2));
   sumza = sum(dataz(:,2).*dataa(:,2));
   sumzb = sum(dataz(:,2).*datab(:,2));
   
   a = (sumza/sumab-sumzb/sumb2)/(suma2/sumab - sumab/sumb2);
   b = (sumza - a*suma2)/sumab;

   % return the result
   data = dataz;
   data(:,2) = a*dataa(:,2) + b*datab(:,2);
else
   a = linspace(0,1,101);
   dataab = dataa;
   for i=1:length(a)
      dataab(:,2) = a(i)*dataa(:,2) + (1-a(i))*datab(:,2);
      b(i) = sum(dataab(:,2).*dataz(:,2))/sum(dataab(:,2).*dataab(: ,2));
      data(i) = sqrt(mean((b(i)*dataab(:,2) - dataz(:,2)).^2));
   end
end
