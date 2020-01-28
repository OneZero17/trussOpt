clear
groundStructure = GeoGroundStructure3D;
x=100; y=100; z=250;
spacing = 25;
%nozzleMaxAngle = 0.9773884;
solverOptions = OptOptions();
solverOptions.nodalSpacing = spacing * 1.75;
groundStructure.createCustomizedNodeGrid([0,0,0], [x, y, z], [spacing, spacing, spacing]);
groundStructure.createMembersFromNodes();
groundStructure.members = deleteCollinearMembers(groundStructure.nodes, groundStructure.members);
groundStructure.deleteNearHorizontalMembers(0);

loadcase = PhyLoadCase();
load1NodeIndex = groundStructure.findNodeIndex([x/2, y, z]);
load1 = PhyLoad3D(load1NodeIndex, 0.0, 5.0, 0.0);
% %load2 = PhyLoad(load2NodeIndex, 0.1, 0);
loadcase.loads = {load1};
loadcases = {loadcase};
 
support1NodeIndex = groundStructure.findNodeIndex([0, 0, 0]);
support2NodeIndex = groundStructure.findNodeIndex([x, y, 0]);
support3NodeIndex = groundStructure.findNodeIndex([x, 0, 0]);
support4NodeIndex = groundStructure.findNodeIndex([0, y, 0]);
support1 = PhySupport3D(support1NodeIndex);
support2 = PhySupport3D(support2NodeIndex);
support3 = PhySupport3D(support3NodeIndex);
support4 = PhySupport3D(support4NodeIndex);
supports = {support1; support2; support3; support4};
 
[forceList, potentialMemberList] = memberAdding(groundStructure, loadcases, supports, solverOptions);
structure = groundStructure.createOptimizedStructureList(forceList);
plotStructure3D(structure, 10);
%groundStructure.plotMembers(forceList);

%% Building sectors
structure = groundStructure.createOptimizedStructureList(forceList);
structure(1:2, :) = [];
splineSpacing = 10;
splintLine = 0:splineSpacing:x;
members = splitSector3DInX(structure, splintLine);
splitedStructures = cell(x/splineSpacing, 1);
for i = 1:(x/splineSpacing)
    splitedStructures{i, 1} = splitSector3DInY(members{i, 1}, splintLine);
end

%% Do printing plan optimization
nozzleMaxAngle = 0.809;
printPlanProblem = PPOptProblem3D;
printPlanProblem.createProblem(splitedStructures, nozzleMaxAngle);
[conNum, varNum, objVarNum] = printPlanProblem.getConAndVarNum();
matrix = ProgMatrix(conNum, varNum, objVarNum);
printPlanProblem.initializeProblem(matrix);
result = mosekSolve(matrix, 1);
matrix.feedBackResult(result);
angles = printPlanProblem.outputPrintingAngles();
[printPlanGrid, normalVectors] = plotPrintingSurface(angles, splintLine, splintLine, 0);
groundStructure.plotMembers(forceList);

%% Delete violating members in potential member list
memberExist = deleteMembersViolatePrintingPlan3D(potentialMemberList, splintLine, splintLine, angles, nozzleMaxAngle);
newMembers = potentialMemberList(memberExist == 1, :);

%% Re-optimize structure with known printing curve
newGroundStructure = GeoGroundStructure3D;
newGroundStructure.nodes = groundStructure.nodes;
newGroundStructure.members = newMembers;
forceList = fullGroundStructure(newGroundStructure, loadcases, supports, solverOptions);
newGroundStructure.plotMembers(forceList, 'figureNumber', 1);

%% Generate printing plan
newStructure = newGroundStructure.createOptimizedStructureList(forceList);
newStructure([4; 11; 15; 16], :) = [];
allSlices = generateOptimizedPrintPlan3D(newStructure, angles, splintLine, splintLine, printPlanGrid, normalVectors, z, true);

%% Caculate Nozzle Angles
maximumOverhangAngle = 0.262;
angles = calculateRealNozzleAngles(allSlices, normalVectors, maximumOverhangAngle);

%% Write G Code
outputGCode(allSlices, angles, x/2, y/2);

%% check 
% allmembers = [];
% for i = 1:size(allSlices, 1)
%     members = allSlices{i, 1};
%     members = reshape(members, [], 1);
%     members = cell2mat(members);
%     allmembers = [allmembers; members];
% end
% plotStructure3D(allmembers, 5);