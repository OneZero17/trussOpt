 variables = [ProgVariable(0, inf); ProgVariable(0, 10); ProgVariable(0, inf); ProgVariable(0, inf)];
constraints = [ProgConstraint(30, 30); ProgConstraint(15, inf); ProgConstraint(-inf, 25)];

matrix = ProgMatrix();
matrix.constraints = constraints;
matrix.variables = variables;
[matrix, constraints, variables] = matrix.initialize();

%% 3*x0+x1+2*x2 = 30
constraints(1) = constraints(1).addVariable(variables(1), 3);
constraints(1) = constraints(1).addVariable(variables(2), 1);
constraints(1) = constraints(1).addVariable(variables(3), 2);

%% 2*x0+x1+3*x2 + x3 >= 15
constraints(2) = constraints(2).addVariable(variables(1), 2);
constraints(2) = constraints(2).addVariable(variables(2), 1);
constraints(2) = constraints(2).addVariable(variables(3), 3);
constraints(2) = constraints(2).addVariable(variables(4), 1);

%% 2*x1 + 3*x3 <=25
constraints(3) = constraints(3).addVariable(variables(2), 2);
constraints(3) = constraints(3).addVariable(variables(4), 3);

%% OBJ:  3*x0+x1+5*x2 + x3
obj = ProgConstraint();
obj = obj.addVariable(variables(1), 3);
obj = obj.addVariable(variables(2), 1);
obj = obj.addVariable(variables(3), 5);
obj = obj.addVariable(variables(4), 1);

matrix.constraints = constraints;
matrix.objectiveFunction = obj;
%% Solve
result = mosekSolve(matrix, 0);

%% Check result
difference = result.sol.bas.xx - [0, 0, 15.0000, 8.3333]';
if abs(sum(difference)) < 0.001
 testresult = "Pass"
else
 testresult = "Fail"
end
     
