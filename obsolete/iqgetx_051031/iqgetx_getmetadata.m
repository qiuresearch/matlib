function data = iqgetx_getmetadata(sIqgetx, varargin)
% --- Usage:
%        data = iqgetx_getmetadata(sIqgetx, varargin)
% --- Purpose:
%        get the meta data for each V
%
% --- Parameter(s):
%        sIqgetx - an array of IqGetX structure
%
% --- Return(s): 
%        data - 
%
% --- Example(s):
%
% $Id: iqgetx_getmetadata.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if nargin < 1
   help iqgetx_getmetadata
   return
end

sortdata = 1; % sort according to image number
normalize = 1;
parse_varargin(varargin);

num_data = length(sIqgetx);
idata=1;
for i=1:num_data
   if isfield(sIqgetx(i), 'buf')
      for k=1:length(sIqgetx(i).buf.imgnums)
         data(idata,:) = [sIqgetx(i).buf.imgnums(k) ...
                          sIqgetx(i).buf.normconst(k), ...
                          sIqgetx(i).buf.xflash(k), ...
                          sIqgetx(i).buf.i1(k), ...
                          sIqgetx(i).buf.i0(k), ...
                          sIqgetx(i).buf.cesr(k), ...
                          sIqgetx(i).buf.mean(k), ...
                          sIqgetx(i).buf.time(k)];
         idata = idata + 1;
      end
   end
   
   if isfield(sIqgetx(i), 'sam')
      for k=1:length(sIqgetx(i).sam.imgnums)
         data(idata,:) = [sIqgetx(i).sam.imgnums(k) ...
                          sIqgetx(i).sam.normconst(k), ...
                          sIqgetx(i).sam.xflash(k), ...
                          sIqgetx(i).sam.i1(k), ...
                          sIqgetx(i).sam.i0(k), ...
                          sIqgetx(i).sam.cesr(k), ...
                          sIqgetx(i).sam.mean(k), ...
                          sIqgetx(i).sam.time(k)];
         idata = idata + 1;
      end
   end
end

if (sortdata == 1)
   [dummy, iorder] = sort(data(:,1));
   data = data(iorder,:);
end
if (normalize == 1);
   for k=2:6
      data(:,k) = data(:,k)/data(1,k);
   end
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Change History:
%
% $Log: iqgetx_getmetadata.m,v $
% Revision 1.1.1.1  2007-09-19 04:45:38  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.2  2005/08/27 01:39:32  xqiu
% lots of small changes!
%
% Revision 1.1  2005/06/27 02:31:49  xqiu
% fix figure postion and getdata to getmetadata
%
% Revision 1.1  2005/06/09 01:54:35  xqiu
% new members!
%
% Revision 1.2  2005/06/03 04:14:06  xqiu
% a more or less working version ready
%
% Revision 1.1  2005/04/29 14:42:49  xqiu
% Initialize the iqgetx standalone package!
%
% Revision 1.4  2004/12/20 04:47:53  xqiu
% IQgetX small improvements
%
% Revision 1.3  2004/11/19 05:04:26  xqiu
% Added comments
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%