function sIqgetx = iqgetx_slurpimg(sIqgetx)
% --- Usage:
%        sIqgetx = iqgetx_slurpimg(sIqgetx)
% --- Purpose:
%        read in the data images and process them. Right now,
%        everything is done in this single step
%
% --- Parameter(s):
%     
% --- Return(s): 
%        results - 
%
% --- Example(s):
%
% $Id: iqgetx_slurpimg.m,v 1.2 2012/02/07 00:09:52 xqiu Exp $
%

% 1) Simple check on input parameters
if nargin < 1
   help iqgetx_slurpimg
   return
end

% 2) set default behaviors
if nargin < 2
   sOpt.dezinger_isa = 1;
   sOpt.normalize_isa = 1;
end

qmin_smooth = 0.03;
qmax_smooth = 0.325;

% 3) action
num_data = length(sIqgetx);
for i=1:num_data
   if isempty(sIqgetx(i).signums); continue; end
   
   %  read the signals and integrate them
   sOpt.suffix = sIqgetx(i).suffix;
   [sIqgetx(i).sigdata, sIqgetx(i).sigs] = slurpadsc_xq(sIqgetx(i).prefix, ...
                                                     sIqgetx(i).signums, sOpt);
   sIqgetx(i).sigdata.iq = integrater(sIqgetx(i).sigdata.im);
   imin_smooth = locate(sIqgetx(i).sigdata.iq(:,1), qmin_smooth);
   imax_smooth = locate(sIqgetx(i).sigdata.iq(:,1), qmax_smooth);
   
   for k=1:length(sIqgetx(i).sigs)
      sIqgetx(i).sigs(k).iq = integrater(sIqgetx(i).sigs(k).im);
      sIqgetx(i).sigs(k).iq(imin_smooth:imax_smooth,:) = deglitch_poly( ...
          sIqgetx(i).sigs(k).iq(imin_smooth:imax_smooth,:), 5, 6);
      if (sIqgetx(i).sigs(k).gdoor ~=0) && (sIqgetx(i).sigs(k).gdoor ~=1)
         sIqgetx(i).sigs(k).iq(:,2) = 1.0/sIqgetx(i).sigs(k).gdoor* ...
             sIqgetx(i).sigs(k).iq(:,2);
      end
   end
   
   % handle the buffers
   bufdata.im = 0;  % two buffers (before and after) will be averaged
   bufdata.gdoor = 0.0;
   if ~isempty(sIqgetx(i).bufnums1)
      [sIqgetx(i).bufdata1, sIqgetx(i).bufs1] = ...
          slurpadsc_xq(sIqgetx(i).prefix, sIqgetx(i).bufnums1, sOpt);
      sIqgetx(i).bufdata1.iq = integrater(sIqgetx(i).bufdata1.im);
      for k=1:length(sIqgetx(i).bufs1)
         sIqgetx(i).bufs1(k).iq = integrater(sIqgetx(i).bufs1(k).im);
         sIqgetx(i).bufs1(k).iq(imin_smooth:imax_smooth,:) = ...
             deglitch_poly( sIqgetx(i).bufs1(k).iq(imin_smooth: ...
                                                   imax_smooth,:), 5, 6);
         if (sIqgetx(i).bufs1(k).gdoor ~=0) && (sIqgetx(i).bufs1(k).gdoor ~=1)
            sIqgetx(i).bufs1(k).iq(:,2) = 1.0/sIqgetx(i).bufs1(k).gdoor* ...
                sIqgetx(i).bufs1(k).iq(:,2);
         end
      end
      
      bufdata.im = sIqgetx(i).bufdata1.im;
      bufdata.gdoor = sIqgetx(i).bufdata1.gdoor;
   end
   
   if ~isempty(sIqgetx(i).bufnums2)  % after buffer
      [sIqgetx(i).bufdata2, sIqgetx(i).bufs2] = ...
          slurpadsc_xq(sIqgetx(i).prefix, sIqgetx(i).bufnums2, sOpt);
      sIqgetx(i).bufdata2.iq = integrater(sIqgetx(i).bufdata2.im);
      for k=1:length(sIqgetx(i).bufs2)
         sIqgetx(i).bufs2(k).iq = integrater(sIqgetx(i).bufs2(k).im);
         sIqgetx(i).bufs2(k).iq(imin_smooth:imax_smooth,:) = ...
             deglitch_poly( sIqgetx(i).bufs2(k).iq(imin_smooth: ...
                                                   imax_smooth,:), 5, 6);
         if (sIqgetx(i).bufs2(k).gdoor ~=0) && (sIqgetx(i).bufs2(k).gdoor ~=1)
            sIqgetx(i).bufs2(k).iq(:,2) = 1.0/sIqgetx(i).bufs2(k).gdoor* ...
                sIqgetx(i).bufs2(k).iq(:,2);
         end
      end
      
      % add to the total buffer and normalize
      bufdata.im = bufdata.im*bufdata.gdoor + ...
          sIqgetx(i).bufdata2.im*sIqgetx(i).bufdata2.gdoor;
      bufdata.gdoor = bufdata.gdoor + sIqgetx(i).bufdata2.gdoor;
      if (bufdata.gdoor ~= 0.0) && (bufdata.gdoor ~= 1.0)
         bufdata.im = 1.0/bufdata.gdoor*bufdata.im;
      end
   end
   
   % get total buffer I(Q)
   if (length(bufdata.im) ~= 1)
      bufdata.iq = integrater(bufdata.im);
   else
      bufdata.iq = [0,0];
   end
   sIqgetx(i).bufdata = bufdata;
   
   % do the subtraction
   sIqgetx(i).iq = sIqgetx(i).sigdata.iq;
   sIqgetx(i).iq(:,2) = sIqgetx(i).iq(:,2) - sIqgetx(i).bufdata.iq(:,2);
   saveascii(sIqgetx(i).iq, [sIqgetx(i).title '.iq']);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Change History:
%
% $Log: iqgetx_slurpimg.m,v $
% Revision 1.2  2012/02/07 00:09:52  xqiu
% *** empty log message ***
%
% Revision 1.1.1.1  2007-09-19 04:45:39  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.2  2005/06/03 04:14:06  xqiu
% a more or less working version ready
%
% Revision 1.1  2005/04/29 14:42:49  xqiu
% Initialize the iqgetx standalone package!
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
