function uninstall()
%uninstall  remove the layout package from the MATLAB path
%
%   uninstall() removes the layout tools from the MATLAB path.
%
%   Examples:
%   >> uninstall()
%
%   See also: install

%   Copyright 2008-2010 The MathWorks Ltd.
%   $Revision: 1.1 $    
%   $Date: 2011-09-13 20:37:22 $

thisdir = fileparts( mfilename( 'fullpath' ) );

rmpath( thisdir );
rmpath( fullfile( thisdir, 'layoutHelp' ) );
rmpath( fullfile( thisdir, 'Patch' ) );
savepath();