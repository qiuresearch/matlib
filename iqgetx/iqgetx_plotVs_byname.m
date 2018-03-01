function hf = iqgetx_plotVs_byname(sData, dataname, varargin)

for i=1:length(dataname)
   sIqgetx(i)=sData.(dataname{i});
end

if ~isempty(varargin)
   hf=iqgetx_plotVs(sIqgetx, varargin{:});
else
   hf=iqgetx_plotVs(sIqgetx);
end

