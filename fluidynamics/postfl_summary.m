function ok = postfl_summary(postfl, filename)
% --- Usage:
%        ok = postfl_summary(fem, filename)
% --- Purpose:
%        summarize the postfl structure to a file
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: postfl_summary.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%
if nargin < 1
   help postfl_summary
   return
end

disp(['POSTFL_SUMMARY::summarize the results to ', filename])

for i=1:length(postfl)
   clear summary
   summary{1} = ['***** FEMLAB results of model No. ' num2str(i)  ...
                       ' ***** ' datestr(now)];

   if isfield(postfl, 'jetwidth')
      jetwidth = postfl.jetwidth;
      jetwidth_theory = postfl.jetwidth_theory;
   else
      jetwidth = postfl.sldata.jetwidth;
      jetwidth_theory = postfl.sldata.jetwidth_theory;
   end
   summary={summary{:},['      Jet width: ', num2str(jetwidth), '(', ...
                       num2str(jetwidth_theory), ':theory)']};

   summary={summary{:},[' Channel widths: ', ...
                       num2str(postfl(i).const.width_inlet), '(inlet), ', ...
                       num2str(postfl(i).const.width_side), '(side), ', ...
                       num2str(postfl(i).const.width_outlet), '(outlet)']};

   summary={summary{:},['Channel lengths: ', ...
                       num2str(postfl(i).const.length_inlet), '(inlet), ', ...
                       num2str(postfl(i).const.length_side), '(side), ' ...
                       num2str(postfl(i).const.length_outlet), '(outlet)']};
   
   summary={summary{:},['Flow velocities: ', ...
                       num2str(postfl(i).const.v_sam), '(inlet), ', ...
                       num2str(postfl(i).const.v_buf), '(side), ', ...
                       num2str(postfl(i).const.flow_ratio), '(flux ratio)']};

   summary={summary{:},['  Cross section: [', num2str(postfl(i).p1(1)), ...
                       ',', num2str(postfl(i).p1(2)), '](p1), [', ...
                       num2str(postfl(i).p2(1)), ',', ...
                       num2str(postfl(i).p2(2)), '](p2), [', ...
                       num2str(postfl(i).p3(1)), ',', ...
                       num2str(postfl(i).p3(2)), '](p3)']};

   summary={summary{:},['                 number of points: ', ...
                       num2str(postfl(i).num_points(1)), ' by ', ...
                       num2str(postfl(i).num_points(2))]};
   

   if (length(postfl(i).sldata) == 1)
      [num_sls, num_points] = size(postfl(i).sldata.x);
      
      summary={summary{:},['    Streamlines: (', ...
                          num2str(postfl(i).sldata.x(1,1)), ',', ...
                          num2str(postfl(i).sldata.y(1,1)), ') -> (', ...
                          num2str(postfl(i).sldata.x(1, num_points)), ...
                          ',', num2str(postfl(i).sldata.y(1,num_points)), ')']};
      summary={summary{:},['                 (', ...
                          num2str(postfl(i).sldata.x(num_sls,1)), ',', ...
                          num2str(postfl(i).sldata.y(num_sls,1)), ') -> (', ...
                          num2str(postfl(i).sldata.x(num_sls, num_points)), ',', ...
                          num2str(postfl(i).sldata.y(num_sls, num_points)), ...
                          ')']};
   else
      num_sls = length(postfl(i).sldata);
      num_points = length(postfl(i).x_sl);
      
      summary={summary{:},['    Streamlines: (', ...
                          num2str(postfl(i).sldata(1).x(1,1)), ',', ...
                          num2str(postfl(i).sldata(1).y(1,1)), ') -> (', ...
                          num2str(postfl(i).sldata(1).x(1, end)), ...
                          ',', num2str(postfl(i).sldata(1).y(1,end)), ')']};
      summary={summary{:},['                 (', ...
                          num2str(postfl(i).sldata(end).x(1,1)), ',', ...
                          num2str(postfl(i).sldata(end).y(1,1)), ') -> (', ...
                          num2str(postfl(i).sldata(end).x(1,end)), ',', ...
                          num2str(postfl(i).sldata(end).y(1,end)), ...
                          ')']};
   
   end      
   
   summary={summary{:},['                 total number: ', ...
                       num2str(num_sls), ',  length: ', num2str(num_points)]};
   
   summary={summary{:}, 'Critical Concen.     Dead Time     Position'};
   for ic0=1:length(postfl.c0)
      summary={summary{:},sprintf('%12.2f %18.4e %13.4e', ...
                                  postfl(i).c0(ic0), ...
                                  postfl(i).mtdata.t0(ic0), ...
                                  postfl(i).mtdata.x0(ic0))}; 
   end

   summary={summary{:},''};

   if (i == 1)
      fid = fopen(filename, 'w');
   else
      fid = fopen(filename, 'a');
   end
   fprintf(fid, '%s\n', summary{:});
   fclose(fid);
end

return
