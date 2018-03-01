function ok = showinfo(userinfo, type)

try
   verbose = evalin('caller', 'verbose');
catch exception
   verbose = 1;
end

if (verbose == 1)
   if ~exist('type', 'var')
      type = 'info';
   end
   callstack=dbstack;
   callername = callstack(min(end,2)).name;
   %callername = evalin('caller', 'mfilename');

   switch upper(type)
      case 'WARNING'
         disp(['Warning (' upper(callername), '):: ', userinfo]);
      case 'ERROR'
         disp(['Error (' upper(callername), '):: ', userinfo]);
      otherwise
         disp([upper(callername), ':: ', userinfo]);
   end
end
