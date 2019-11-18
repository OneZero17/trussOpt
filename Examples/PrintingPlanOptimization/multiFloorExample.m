clear
groundStructure = GeoGroundStructure;
x=10;y=10;
xSpacing = 1; ySpacing = 1;
nozzleMaxAngle = 0.9773884;
%nozzleMaxAngle = 0.80;
groundStructure.createCustomizedNodeGrid(0, 0, x, y, xSpacing, ySpacing);
groundStructure.createMemberListFromNodeGrid();
groundStructure.createNodesFromGrid();
loadcase = PhyLoadCase();
load1NodeIndex = groundStructure.findOrAppendNode(x/2, 0);
load1 = PhyLoad(load1NodeIndex, 0.0, -0.2);
loadcase.loads = {load1};
loadcases = {loadcase};

support1NodeIndex = groundStructure.findOrAppendNode(0, 0);
support2NodeIndex = groundStructure.findOrAppendNode(10, 0);
support1 = PhySupport(support1NodeIndex, 1, 1);
support2 = PhySupport(support2NodeIndex, 0, 1);
supports = {support1; support2};

groundStructure.createGroundStructureFromMemberList();
solverOptions = OptOptions();

trussProblem = OptProblem();
trussProblem.createProblem(groundStructure, loadcases, supports, solverOptions);

[conNum, varNum, objVarNum] = trussProblem.getConAndVarNum();
matrix = ProgMatrix(conNum, varNum, objVarNum);
trussProblem.initializeProblem(matrix);
result = mosekSolve(matrix, 1);
matrix.feedBackResult(result);
trussProblem.feedBackResult(1);
groundStructure.plotMembers('blackAndWhite', true);

%% Print Plan optimization
structure = groundStructure.createOptimizedStructureList();
maxTurnAngle = 0.6;
splitedFloors = 0:2:y;
splitedMembers = splitFloors(structure, splitedFloors);
floorAngles = cell(size(splitedFloors, 2)-1, 1);
splitedZones = 0:xSpacing:x;

for i = 1:size(splitedFloors, 2) - 1
    if isempty(splitedMembers{i, 1})
        floorAngles{i, 1} = floorAngles{i - 1, 1};
    else
        splitedStructures = splitSector(splitedMembers{i, 1}, splitedZones);
        printPlanProblem = PPOptProblem;
        printPlanProblem.createProblem(splitedStructures, nozzleMaxAngle, maxTurnAngle);

        [conNum, varNum, objVarNum] = printPlanProblem.getConAndVarNum();
        matrix = ProgMatrix(conNum, varNum, objVarNum);
        printPlanProblem.initializeProblem(matrix);
        result = mosekSolve(matrix, 0);
        matrix.feedBackResult(result);
        angles = printPlanProblem.outputPrintingAngles();
        floorAngles{i, 1} = angles;
    end
    
    zoneEndYs = getPrintPlans(splitedZones, angles, splitedStructures);
    %plot2DPrintingPattern(splitedZones, zoneEndYs, 0.2, splitedFloors(i), splitedFloors(i+1), 1);
    plot2DPrintingPattern(splitedZones, zoneEndYs, 0.2, splitedFloors(i), splitedFloors(i+1), 2);
    plot([0, x], [splitedFloors(i), splitedFloors(i)]);
    plot([0, x], [splitedFloors(i+1), splitedFloors(i+1)]);
    axis equal
end

%% Delete violating members in potential member list
potentialMemberList = [groundStructure.memberList(:, 3:6), (1:size(groundStructure.memberList, 1))'];
splitedPotentialMemberList = splitFloors(potentialMemberList, splitedFloors);
memberExistList = ones(size(potentialMemberList, 1), 1);
memberNumList = (1:size(potentialMemberList, 1))';
for i = 1:size(splitedFloors, 2) - 1
    currentList = splitedPotentialMemberList{i, 1}(:, end);
    tempList = zeros(size(potentialMemberList, 1), 1);
    tempList(currentList, :) = 1;
    checkList = memberExistList==1 & tempList==1;
    tempMemberNumList = memberNumList(checkList);
    [~, toBeDeletedMembers] = deleteMembersViolatePrintingPlan([groundStructure.memberList(checkList, :), tempMemberNumList], splitedZones, floorAngles{i, 1}, nozzleMaxAngle);
    memberExistList(toBeDeletedMembers, :) = 0;
end

%% Re-Optimization
existingMember = groundStructure.memberList(memberExistList==1, :);
newGroundStructure = GeoGroundStructure;
newGroundStructure.createCustomizedNodeGrid(0, 0, x, y, xSpacing, ySpacing);
newGroundStructure.memberList = existingMember;
newGroundStructure.createNodesFromGrid();
newGroundStructure.createGroundStructureFromMemberList();

newTrussProblem = OptProblem();
newTrussProblem.createProblem(newGroundStructure, loadcases, supports, solverOptions);
[conNum, varNum, objVarNum] = newTrussProblem.getConAndVarNum();
newMatrix = ProgMatrix(conNum, varNum, objVarNum);
newTrussProblem.initializeProblem(newMatrix);
result = mosekSolve(newMatrix, 1);
newMatrix.feedBackResult(result);
newTrussProblem.feedBackResult(1);
newGroundStructure.plotMembers('figureNumber', 2, 'blackAndWhite', true);

