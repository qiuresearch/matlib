function ok = showcoord(xyz, sformat)
%        ok = showcoord(xyz, sformat)

if exist('sformat', 'var')
   text(xyz(1), xyz(2), sprintf(sformat, xyz));
else
   text(xyz(1), xyz(2), ['(' num2str(xyz(1)) ',' num2str(xyz(2)) ...
                       ')'], 'VerticalAlignment', 'Bottom', ...
        'HorizontalAlignment', 'Center');
end
