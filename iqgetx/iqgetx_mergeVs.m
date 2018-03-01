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
% $Id: iqgetx_mergeVs.m,v 1.4 2013/08/19 03:02:25 xqiu Exp $
%

if nargin < 1
   help iqgetx_mergeVs
   return
end

parse_varargin(varargin);

num_data = length(sIqgetx);
result = sIqgetx(1);

% remove some fields if exists
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

% treat the case of normalization --> anti-normalize first
result.im(:) = result.im(:) * sum(result.normconst);
result.iq(:,[2,4]) = result.iq(:,[2,4])*sum(result.normconst);
if isfield(result, 'sam')
   result.sam.iq(:,[2,4]) = result.sam.iq(:,[2,4])*sum(result.sam.normconst);
   result.buf.iq(:,[2,4]) = result.buf.iq(:,[2,4])*sum(result.buf.normconst);
end

% merge the data one by one
for i=2:num_data
   result.im(:) = result.im(:) + sIqgetx(i).im(:);
   result.iq(:,2) = result.iq(:,2) + sIqgetx(i).iq(:,2)*sum(sIqgetx(i).normconst);
   result.iq(:,4) = sqrt(result.iq(:,4).^2 + sIqgetx(i).iq(:, 4).^2*sum(sIqgetx(i).normconst)^2);
   result.normconst = [result.normconst, sIqgetx(i).normconst];
   result.expotime = [result.expotime, sIqgetx(i).expotime];

   % use this to determine whether it has both buffer and sam fields
   if isfield(result, 'sam') 
      if (sIqgetx(i).sam.normalize > 0)
         normconst = sum(sIqgetx(i).sam.normconst);
      else 
         normconst = 1;
      end
      result.sam.iq(:,2) = result.sam.iq(:,2) + sIqgetx(i).sam.iq(:, 2)*normconst;
      result.sam.iq(:,4) = sqrt(result.sam.iq(:,4).^2 + ...
                                (sIqgetx(i).sam.iq(: ,4)*normconst).^2);
      result.sam.imgnums = [result.sam.imgnums, sIqgetx(i).sam.imgnums];
      result.sam.moncounts =  [result.sam.moncounts; sIqgetx(i).sam.moncounts];
      result.sam.normconst = [result.sam.normconst, sIqgetx(i).sam.normconst];
      result.sam.expotime = [result.sam.expotime, sIqgetx(i).sam.expotime];
      result.sam.mean = [result.sam.mean, sIqgetx(i).sam.mean];
      
      if (sIqgetx(i).buf.normalize > 0)
         normconst = sum(sIqgetx(i).buf.normconst);
      else 
         normconst = 1;
      end
      result.buf.iq(:,2) = result.buf.iq(:,2) + sIqgetx(i).buf.iq(:, 2)*normconst;
      result.buf.iq(:,4) = sqrt(result.buf.iq(:,4).^2 + ...
                                (sIqgetx(i).buf.iq(:,4)*normconst).^2);
      result.buf.imgnums = [result.buf.imgnums, sIqgetx(i).buf.imgnums];
      result.buf.moncounts =  [result.buf.moncounts; sIqgetx(i).buf.moncounts];
      result.buf.normconst = [result.buf.normconst, sIqgetx(i).buf.normconst];
      result.buf.expotime = [result.buf.expotime, sIqgetx(i).buf.expotime];
      result.buf.mean = [result.buf.mean, sIqgetx(i).buf.mean];
      
      if isfield(result, 'bufnums1')
         result.bufnums1 = [result.bufnums1, sIqgetx(i).bufnums1];
      end
      if isfield(result, 'bufnums2')
         result.bufnums2 = [result.bufnums2, sIqgetx(i).bufnums2];
      end
      if isfield(result, 'bufnums')
         result.bufnums = [result.bufnums, sIqgetx(i).bufnums];
      end
      result.startnum = [result.startnum, sIqgetx(i).startnum];
      result.darknums = [result.darknums, sIqgetx(i).darknums];
      result.samnums = [result.samnums, sIqgetx(i).samnums];
      result.skipnums = [result.skipnums, sIqgetx(i).skipnums];
      result.skipnums = unique(result.skipnums);
   end
end

% renormalize the data if necessary
if (result.normalize > 0)
   
   result.im(:) = result.im(:)/sum(result.normconst);
   result.iq(:,[2,4]) = result.iq(:,[2,4])/sum(result.normconst);
   
   if isfield(result, 'sam')
      result.sam.iq(:,[2,4]) = result.sam.iq(:,[2,4])/ sum(result.sam.normconst);
      result.buf.iq(:,[2,4]) = result.buf.iq(:,[2,4])/ sum(result.buf.normconst);
      % the I(Q) needs to be calculated again if normalization was applied.
      result.iq(:,2) = result.sam.iq(:,2) - result.buf.iq(:,2);
      result.iq(:,4) = sqrt(result.sam.iq(:,4).^2 + result.buf.iq(:,4).^2);
   end
end

result.title = [result.label ' merged'];
