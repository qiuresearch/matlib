function sIqgetx = iqgetx_init()
% --- Usage:
%        sIqgetx = iqgetx_init(setupfile)
% --- Purpose:
%        read a setupfile to compile the IqGetX structure array
%
% --- Parameter(s):
%     
% --- Return(s): 
%        sIqgetx - 
%
% --- Example(s):
%
% $Id: iqgetx_init.m,v 1.2 2012/02/07 00:09:52 xqiu Exp $
%

%if nargin < 1
%  help iqgetx_init
%   return
%end

sIqgetx = struct('x', [], 'label', '', 'title', '', 'expt_type', ...
                 'SAXS', 'dataformat', 'SG1KCCD', 'datadir', '', ...
                 'prefix', '', 'suffix', '.tif', 'run_config', ...
                 [2,2,4,2], 'startnum', [], 'darknums', [], 'buf1nums', ...
                 [], 'samnums', [], 'buf2nums', [], 'skipnums', [], ...
                 'dezinger', 1, 'normalize', 1, 'im_dark', 0, ...
                 'keep_im', 0, 'sam', [], 'samimgs', [], 'buf1', ...
                 [], 'buf1imgs', [], 'buf2', [], 'buf2imgs', [], ...
                 'buf', [], 'iq', []);

% expt_type: 'SAXS', 'ASAXS', 'TRSAXS'
% num_config: [dark, buf1, sam, buf2]
                 