function b = eq(S1,S2)
% check S1 == S2

b = S1.id == S2.id && ...
  all(norm(S1.axes - S2.axes)./norm(S1.axes)<10^-2);