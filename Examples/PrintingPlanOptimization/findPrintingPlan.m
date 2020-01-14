function [cuttingSurfaces,  splitedStructureEachFloor, anglesForEachFloor, printable, zGrids] = findPrintingPlan(structure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, reRunTurnedOn, knownAngleValue,floorSpacing)
    clf
    maximumTurnAngle = 0.6;
    nozzleMaxAngle = 0.809;
    symmetryInX = true;
    solverOptions.useCosAngleValue = false;
    solverOptions.useAngleTurnConstraint = true;
    printable = true;
    membersInEachFloor = splitSector3DInZ(structure, floorLineZ);

    anglesForEachFloor = cell(size(membersInEachFloor, 1), 1);

    [floorSurfaceX, floorSurfaceY] = meshgrid(splintLineX, splintLineY);

    floorGap = 0; 
    figure(1)
    hold on
    %tiledlayout(2,2);
    figure(2)
    t = tiledlayout(3, 3, 'TileSpacing','compact');
    cuttingSurfaces = cell(size(membersInEachFloor, 1), 1);
    splitedStructureEachFloor = cell(size(membersInEachFloor, 1), 1);
    zGrids = cell(size(membersInEachFloor, 1), 1);
    %
    for floorNum = 1 : size(membersInEachFloor, 1)  
        reRun = true;
        while reRun
            if floorNum==1
                figure(1)
                view([1 1 1])
                floorSurfaceZ=zeros(size(floorSurfaceX, 1), size(floorSurfaceX, 2))+ (floorNum - 1) * floorGap + floorGap/2;
                s = surf(floorSurfaceX,floorSurfaceY,floorSurfaceZ, 'FaceAlpha',0.2) ;
                s.EdgeColor = 'none';
                s.FaceColor = [0.6 0.6 0.6];
            end
            currentFloor = membersInEachFloor{floorNum, 1};
            currentFloor(:, 3) = currentFloor(:, 3) + (floorNum - 1) * floorGap;
            currentFloor(:, 6) = currentFloor(:, 6) + (floorNum - 1) * floorGap;
            floorSurfaceZ=floorLineZ(floorNum + 1)*ones(size(floorSurfaceX, 1), size(floorSurfaceX, 2))+ (floorNum - 1) * floorGap + floorGap/2;
            figure(1)
            s = surf(floorSurfaceX,floorSurfaceY,floorSurfaceZ, 'FaceAlpha',0.2) ;
            s.EdgeColor = 'none';
            s.FaceColor = [0.6 0.6 0.6];
            view([1 0.5 0.5])
%            textheight = floorLineZ(floorNum + 1) + (floorNum - 1) * floorGap - floorSpacing/2;
            %text(0, 150, textheight, sprintf('Level %i', floorNum),'Rotation',+15);
            plotStructure3D(currentFloor, 1);
%             figure(2)
%             nexttile(t)
            
            hold on
            
            plotStructure3D(currentFloor, floorNum+1);
            axis off
            %title(sprintf('Level %i', floorNum));
            members = splitSector3DInX(membersInEachFloor{floorNum, 1}, splintLineX);
            splitedStructures = cell(size(splintLineX, 2) - 1, 1);
            for i = 1:size(members, 1)
                splitedStructures{i, 1} = splitSector3DInY(members{i, 1}, splintLineY);
            end
            splitedStructureEachFloor{floorNum, 1} = splitedStructures;
            printPlanProblem = PPOptProblem3D;
            
            if ~isempty(knownAngleValue)
                printPlanProblem.createProblem(splitedStructures, nozzleMaxAngle, maximumTurnAngle, solverOptions, knownAngleValue{floorNum, 1});
            else
                printPlanProblem.createProblem(splitedStructures, nozzleMaxAngle, maximumTurnAngle, solverOptions, []);
            end
            [conNum, varNum, objVarNum] = printPlanProblem.getConAndVarNum();
            matrix = ProgMatrix(conNum, varNum, objVarNum);
            printPlanProblem.initializeProblem(matrix);
            result = mosekSolve(matrix, 0);
            matrix.feedBackResult(result);
            angles = printPlanProblem.outputPrintingAngles(splitedStructures, solverOptions);
            
            if symmetryInX
                angles = adjustAnglesToBeSymmetryInX(angles);
            end
%             if ~isempty(knownAngleValue)
%                 anglesForEachFloor{floorNum, 1} = getAnglesForFilledFacets(angles, splitedStructures, knownAngleValue{floorNum, 1});
%             else
%                 anglesForEachFloor{floorNum, 1} = getAnglesForFilledFacets(angles, splitedStructures, []);
%             end
            anglesForEachFloor{floorNum, 1} = angles;
            [printPlanGrid, normalVectors, surface] = plotPrintingSurface(angles, splintLineX, splintLineY, floorLineZ(floorNum), splitedStructures, floorNum+1);
            zGrids{floorNum, 1} = printPlanGrid;
            view([1 1 1])
            cuttingSurfaces{floorNum, 1} = surface;
            % check printability
            
            membersToBeChecked = [zeros(size(membersInEachFloor{floorNum, 1}, 1), 2), membersInEachFloor{floorNum, 1}]; 
            memberExist = deleteMembersViolatePrintingPlan3D(membersToBeChecked, splintLineX, splintLineY, angles, checkingMaxAngle);
            reRun = ~all(memberExist == 1); 

            unprintableMember = membersInEachFloor{floorNum, 1}(memberExist==0, :);
            if ~isempty(unprintableMember)
                printable = false;
            end
            plotStructure3D(unprintableMember, 1, [1 0 0])
            if reRunTurnedOn
                membersInEachFloor{floorNum, 1} = membersInEachFloor{floorNum, 1}(memberExist==1, :);
            else
                reRun = false;
            end
        end
    end 
end

function newAngles = getAnglesForFilledFacets(angles, structures, knownAngleValue)
    newAngles = angles;
    for i = 1:size(angles, 1)
        for j = 1:size(angles, 2)
            if ~isempty(knownAngleValue) && ~isempty(knownAngleValue{i, j})
                continue;
            end
            
            if isempty(structures{i, 1}{j, 1})
                newAngles{i, j} = [];
            end
        end
    end
end

