function mylabel(selection)
% kratky,    
switch selection  
  case 'standard' % standard
    xlabel('Q(A)');
    ylabel('I(Q)');
  case 'guinier'  % guinier
    ylabel('log(I(Q))')
    xlabel('Q(A)^2')
  case 'guinier rod' % guinier rod
    ylabel('log(Q I(Q))')
    xlabel('Q(A)^2')
  case 'kratky' % kratky
    ylabel('I(Q)Q^2')
    xlabel('Q(A)')
  case 'standard A' % standard
    xlabel('Q(Å)');
    ylabel('I(Q)');
  case 'guinier A'  % guinier
    ylabel('log(I(Q))')
    xlabel('Q(Å)^2')
  case 'guinier rod A' % guinier rod
    ylabel('log(Q I(Q))')
    xlabel('Q(Å)^2')
  case 'kratky A' % kratky
    ylabel('I(Q)Q^2')
    xlabel('Q(Å)')
  otherwise
    disp('label option not supported yet')
end


    
    