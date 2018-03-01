function [data, names] = iqgetx_getmetadata(sIqgetx, varargin)
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
% $Id: iqgetx_getmetadata.m,v 1.7 2013/08/19 03:02:25 xqiu Exp $
%

if nargin < 1
   help iqgetx_getmetadata
   return
end

sortdata = 1; % sort according to image number
normalize = 0;
parse_varargin(varargin);

num_data = length(sIqgetx);
names = {'imgnums', 'normconst'};
if isfield(sIqgetx(1).sam, 'monnames')
   names = {names{:}, sIqgetx(1).sam.monnames{:}};
end
idata=1;
for i=1:num_data
   if isfield(sIqgetx(i), 'buf') && ~isempty(sIqgetx(i).buf)
      for k=1:length(sIqgetx(i).buf.imgnums)
	if isfield(sIqgetx(i).buf, 'moncounts')
         data(idata,:) = [sIqgetx(i).buf.imgnums(k), ...
                          sIqgetx(i).buf.normconst(k), ...
                          sIqgetx(i).buf.moncounts(k,:)];
         else
         data(idata,:) = [sIqgetx(i).buf.imgnums(k), ...
                          sIqgetx(i).buf.normconst(k)];
         end
         idata = idata + 1;
      end
   end
   if isfield(sIqgetx(i), 'sam')
      for k=1:length(sIqgetx(i).sam.imgnums)
         if isfield(sIqgetx(i).sam, 'moncounts')
         data(idata,:) = [sIqgetx(i).sam.imgnums(k), ...
                          sIqgetx(i).sam.normconst(k), ...
                          sIqgetx(i).sam.moncounts(k,:)];
         else
         data(idata,:) = [sIqgetx(i).sam.imgnums(k), ...
                          sIqgetx(i).sam.normconst(k)];
         end
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
