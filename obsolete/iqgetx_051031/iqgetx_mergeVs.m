function result = iqgetx_mergeVs(sIqgetx, varargin)
% --- Usage:
%        result = iqgetx_mergeVs(sIqgetx)
% --- Purpose:
%        do a general plot of the signal and buffer I(Q) data
%
% --- Parameter(s):
%        sIqgetx - an array of IqGetX structure
%
% --- Return(s): 
%        result - 
%
% --- Example(s):
%
% $Id: iqgetx_mergeVs.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if nargin < 1
   help iqgetx_mergeVs
   return
end
normtime = 0;
parse_varargin(varargin);

num_data = length(sIqgetx);
result = sIqgetx(1);
if isfield(result, 'samimgs')
   result = rmfield(result, 'samimgs');
end
if isfield(result, 'bufimgs')
   result = rmfield(result, 'bufimgs');
end
if isfield(result, 'buf1imgs')
   result = rmfield(result, 'buf1imgs');
end
if isfield(result, 'buf2imgs')
   result = rmfield(result, 'buf2imgs');
end
if isfield(result, 'buf1')
   result = rmfield(result, 'buf1');
end
if isfield(result, 'buf2')
   result = rmfield(result, 'buf2');
end

% treat the case of normalization
if (result.normalize > 0)
   result.sam.iq(:,2) = result.sam.iq(:,2)*sum(result.sam.normconst);
   result.buf.iq(:,2) = result.buf.iq(:,2)*sum(result.buf.normconst);
end

normconst = 1;
for i=2:num_data
   if (result.normalize > 0)
      normconst = sum(sIqgetx(i).sam.normconst);
   end
   result.sam.iq(:,2) = result.sam.iq(:,2) + sIqgetx(i).sam.iq(:,2)*normconst;
   result.sam.imgnums = [result.sam.imgnums, sIqgetx(i).sam.imgnums];
   result.sam.cesr = [result.sam.cesr, sIqgetx(i).sam.cesr];
   result.sam.i0 = [result.sam.i0, sIqgetx(i).sam.i0];
   result.sam.i1 = [result.sam.i1, sIqgetx(i).sam.i1];
   result.sam.xflash = [result.sam.xflash, sIqgetx(i).sam.xflash];
   result.sam.normconst = [result.sam.normconst, sIqgetx(i).sam.normconst];
   result.sam.time = [result.sam.time, sIqgetx(i).sam.time];
   result.sam.mean = [result.sam.mean, sIqgetx(i).sam.mean];
   
   if (result.normalize > 0)
      normconst = sum(sIqgetx(i).buf.normconst);
   end
   result.buf.iq(:,2) = result.buf.iq(:,2) + sIqgetx(i).buf.iq(:,2)*normconst;
   result.buf.imgnums = [result.buf.imgnums, sIqgetx(i).buf.imgnums];
   result.buf.cesr = [result.buf.cesr, sIqgetx(i).buf.cesr];
   result.buf.i0 = [result.buf.i0, sIqgetx(i).buf.i0];
   result.buf.i1 = [result.buf.i1, sIqgetx(i).buf.i1];
   result.buf.xflash = [result.buf.xflash, sIqgetx(i).buf.xflash];
   result.buf.normconst = [result.buf.normconst, sIqgetx(i).buf.normconst];
   result.buf.time = [result.buf.time, sIqgetx(i).buf.time];
   result.buf.mean = [result.buf.mean, sIqgetx(i).buf.mean];

   result.iq(:,2) = result.iq(:,2) + sIqgetx(i).iq(:,2);
   result.startnum = [result.startnum, sIqgetx(i).startnum];
   result.darknums = [result.darknums, sIqgetx(i).darknums];
   result.samnums = [result.samnums, sIqgetx(i).samnums];
   if isfield(result, 'bufnums1')
      result.bufnums1 = [result.bufnums1, sIqgetx(i).bufnums1];
   end
   if isfield(result, 'bufnums2')
      result.bufnums2 = [result.bufnums2, sIqgetx(i).bufnums2];
   end
   if isfield(result, 'bufnums')
      result.bufnums = [result.bufnums, sIqgetx(i).bufnums];
   end
   result.skipnums = [result.skipnums, sIqgetx(i).skipnums];
   result.time = [result.time, sIqgetx(i).time];
end
if (result.normalize > 0) % need to renormalize the data
   result.sam.iq(:,2) = result.sam.iq(:,2)/ sum(result.sam.normconst);
   result.buf.iq(:,2) = result.buf.iq(:,2)/ sum(result.buf.normconst);
   result.iq(:,2) = result.sam.iq(:,2) - result.buf.iq(:,2);
end
if (normtime > 0)   % normalize by time
   result.sam.iq(:,2) = result.sam.iq(:,2)/mean(result.time);
   result.buf.iq(:,2) = result.buf.iq(:,2)/mean(result.time);
   result.iq(:,2) = result.iq(:,2) / mean(result.time);
end

result.skipnums = unique(result.skipnums);
result.title = [result.label ' merged'];

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Change History:
%
% $Log: iqgetx_mergeVs.m,v $
% Revision 1.1.1.1  2007-09-19 04:45:38  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.4  2005/08/27 01:39:32  xqiu
% lots of small changes!
%
% Revision 1.3  2005/07/06 14:12:49  xqiu
% add more fields in the merged data
%
% Revision 1.2  2005/06/16 18:35:42  xqiu
% *** empty log message ***
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