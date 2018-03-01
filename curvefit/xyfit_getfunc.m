function hf = xyfit_getfunc(func_type)
   hf = eval(['@' func_type '_xyfit']);
