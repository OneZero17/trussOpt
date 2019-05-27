function res = mosekSolve(matrix, output)
    prob.c = matrix.getJacobian(ProgConstraintType.objectiveFunction)';
    variableBoundary = matrix.getVariableBoundary();
    prob.blx = variableBoundary(:,1);
    prob.bux = variableBoundary(:,2);
    prob.a = matrix.getJacobian(ProgConstraintType.constraint);
    constraintBoundary = matrix.getConstraintBoundary();
    prob.blc = constraintBoundary(:,1);
    prob.buc = constraintBoundary(:,2);

    if (output == 0)
        [r, res]=mosekopt('maximize echo(0)',prob);   
    else
       [r, res]=mosekopt('maximize',prob);    
end