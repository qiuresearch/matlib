function sIqgetx = iqgetx_init_imageplate()
% --- Usage:
%        sIqgetx = iqgetx_init_imageplate()
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
% $Id: iqgetx_init_imageplate.m,v 1.5 2014/04/05 19:37:47 xqiu Exp $
%

%if nargin < 1
%  help iqgetx_init
%   return
%end

sIqgetx = struct('i', [], 'x', [], 'label', '', 'title', '', ...
                 'expt_type', 'SAXS', 'dataformat', 'ImagePlate', ...
                 'invertim', 0, 'datadir', '', 'prefix', '', 'suffix', ...
                 '.tif', 'imgnums', 0, 'file', [], 'time', 0, ...
                 'Spec_to_Phos', 1000.0, 'X_cen', 0, 'Y_cen', 0, ...
                 'dspacing', 24.23, 'X_ring', 0, 'Y_ring', 0, ...
                 'autoalign_isa', 1, 'autoalign_tolerance', 0.48, ...
                 'autoalign_maxiter', 23, 'autoalign_do_plot', ...
                 1,'readraw', 1, 'darksub', 1, 'dezinger', 1, ...
                 'normalize', 1, 'normconst', 1, 'correct', 0, ...
                 'lblcorrect', 0, 'setzero', 0, 'im_dark', 0, ...
                 'keep_im', 0, 'im', [], 'mean', 0, 'iq', []);

% darksub: set to 1 when buf and sam share the common dark images
%          to avoid redundant loading of the dark images. 
% expt_type: 'SAXS', 'ASAXS', 'TRSAXS'
% num_config: [dark, buf1, sam, buf2]
