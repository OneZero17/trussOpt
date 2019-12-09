function [vars, result, dualValues] = mosekSolve(matrix, output)
    matrix.deleteEmptyCells();
    matrix.initialize();
    prob.c = matrix.getJacobianObjective();
    variableBoundary = matrix.getVariableBoundary();
    prob.blx = variableBoundary(:,1);
    prob.bux = variableBoundary(:,2);
    prob.a = matrix.getJacobianConstraint();
    constraintBoundary = matrix.getConstraintBoundary();
    prob.blc = constraintBoundary(:,1);
    prob.buc = constraintBoundary(:,2);
    if size(prob.a, 1) == 0
       prob.a = zeros(1, size(prob.c, 1));
       prob.blc = 0;
       prob.buc = 0;
    end
    if size(prob.a, 2) ~= size(prob.c, 1)
       prob.a = [prob.a, zeros(size(prob.a, 1), size(prob.c, 1) - size(prob.a, 2))];
    end
    % All cones
    [FQ, gQ, cQ] = matrix.getCoefficientOfConicConstraints();
    
    [rcode, res] = mosekopt('symbcon echo(0)');
    cQ = [res.symbcon.MSK_CT_QUAD*ones(size(cQ, 1), 1), cQ];
    recQ = zeros(1, size(cQ, 1)*size(cQ, 2));
    for i = 1:size(cQ)
        recQ(i*2-1:i*2)=cQ(i,:);
    end
    if size(recQ, 2) > 0
        if size(FQ,2) ~= size(prob.a,2)
            prob.f = [FQ, zeros(size(FQ, 1), size(prob.a,2)-size(FQ,2))];
        else
            prob.f = FQ;
        end
        prob.g = gQ;
        prob.cones = recQ;
    end
    
    %prob = optimizeMatrix(prob);
    % Select interior-point optimizer... (integer parameter)
    
    param.MSK_IPAR_INFEAS_REPORT_AUTO  = 'MSK_OFF';
    % ... without basis identification (integer parameter)
    %param.MSK_IPAR_INTPNT_BASIS = 'MSK_BI_NEVER';
    %mosekopt('write(datafile.mps)',prob);
    if (output == 0)
        [r, res]=mosekopt('minimize echo(0)',prob, param);   
    else
        [r, res]=mosekopt('minimize',prob, param); 
    end
    if strcmp(res.sol.itr.solsta,'PRIMAL_INFEASIBLE')
        vars = -1;
        result = -1;
        return;
    end
    
    vars = res.sol.itr.xx;
    result = res.sol.itr.pobjval;
    dualValues = res.sol.itr.y;
end


function prob = optimizeMatrix(prob)

    linkconstraint = -1*ones(size(prob.blc));
    linkNum = 0;
    for i = 1:size(prob.blc,1)
        if (prob.blc(i) == 0 && prob.buc(i)==0)
            if (size(find(prob.a(i,:)>0), 2) == 1) && (size(find(prob.a(i,:)==1), 2) == 1)
                linkNum = linkNum + 1;
                linkconstraint(linkNum) = i;
            end
        end
    end

    size(linkconstraint)
    toBeDeletedVariables = [];
    for i = 1:size(linkconstraint, 1)      
        toBeDeletedVariable = find(prob.a(linkconstraint(i),:)==1);
        toBeDeletedVariables = [toBeDeletedVariables, toBeDeletedVariable];
        replacingVariable = find(prob.a(linkconstraint(i),:)<0);
        for j = 1:size(replacingVariable)
            prob.a(:,replacingVariable(j)) = prob.a(:,replacingVariable(j)) + prob.a(:,toBeDeletedVariable) * -prob.a(i,replacingVariable(j));
            prob.c(replacingVariable(j)) = prob.c(replacingVariable(j)) + prob.c(toBeDeletedVariable) * -prob.a(i,replacingVariable(j));
        end
    end
    prob.a(:,toBeDeletedVariables)=[];
    prob.c(:,toBeDeletedVariables)=[];
    prob.blx(:,toBeDeletedVariables)=[];
    prob.bux(:,toBeDeletedVariables)=[];
    prob.blc(:,toBeDeletedVariables)=[];
    prob.buc(:,toBeDeletedVariables)=[];
        
end