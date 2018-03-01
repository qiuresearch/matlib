function MaskI=automask_rmEdge(MaskI,n)
% --- Usage:
%        MaskI=mask_rm_edge(MaskI,n)
%
% --- Purpose:
%        Remove pixels from edge of image
%        
%
%--- Parameter(s):
%        MaskI should be the mask to modify
%        n is the number of pixels to remove
%
% --- Return(s): 
%        MaskI, the same size as input MaskI
%
% --- Example(s):
%        tmpMask = automask_rmEdge(tmpMask,2);
%        will return tmpMask with the outside 2 rows and columns
%        set to 0
%
% $Id: automask_rmEdge.m,v 1.3 2013/01/15 21:30:37 schowell Exp $
    
    
    if nargin < 1
        funcname = mfilename; % or use dbstack to get its caller if needed
        eval(['help ' funcname]);
        return
    end
    
    [row, col] = size(MaskI);
    if row ~= col
        printf(['error: MaskI not square \nnot yet supported\n']);
        return  %maybe break
    end
    
    MaskI([1:n,row+1-n:row],:)=0;
    MaskI(:,[1:n,col+1-n:col])=0;
    
    