function value = findArg( argname, varargin )
%findArg  Find a specific property value from a property-value pairs list
%
%   value = findParentArg(propname,varargin) parses the inputs as property-value
%   pairs looking for the named property. If found, the corresponding
%   value is returned. If not found an empty array is returned.
%
%   Examples:
%   >> uiextras.findArg('Parent','Padding',5,'Parent',1,'Visible','on')
%   ans =
%     1

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1 $
%   $Date: 2011-09-13 20:37:24 $

error( nargchk( 1, inf, nargin, 'struct' ) );

value = [];
if nargin>1
    props = varargin(1:2:end);
    values = varargin(2:2:end);
    if ( numel( props ) ~= numel( values ) ) || any( ~cellfun( @ischar, props ) )
        error( 'GUILayout:InvalidSyntax', 'Arguments must be supplied as property-value pairs.' );
    end
    myArg = find( strcmpi( props, argname ), 1, 'last' );
    if ~isempty( myArg )
        value = values{myArg};
    end
end
