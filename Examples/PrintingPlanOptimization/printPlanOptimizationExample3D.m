clear
groundStructure = GeoGroundStructure3D;
x=50; y=50; z=200;
spacing = 25;
solverOptions = OptOptions();
solverOptions.nodalSpacing = spacing * 1.75;
groundStructure.createCustomizedNodeGrid([0,0,0], [x, y, z], [spacing, spacing, spacing]);

loadcase1 = PhyLoadCase();
load1NodeIndex1 = groundStructure.findNodeIndex([x/2, 0, z]);
load1 = PhyLoad3D(load1NodeIndex1, 0.0, 0.5, 0.0);
loadcase1.loads = {load1};
%loadcase2 = PhyLoadCase();
%load2 = PhyLoad3D(load1NodeIndex, -0.0, 0.5, 0.0);
%loadcase2.loads = {load2};
loadcases = {loadcase1};
 
support1NodeIndex = groundStructure.findNodeIndex([0, 0, 0]);
support2NodeIndex = groundStructure.findNodeIndex([50, 0, 0]);
support3NodeIndex = groundStructure.findNodeIndex([0, 50, 0]);
support4NodeIndex = groundStructure.findNodeIndex([50, 50, 0]);
support1 = PhySupport3D(support1NodeIndex);
support2 = PhySupport3D(support2NodeIndex);
support3 = PhySupport3D(support3NodeIndex);
support4 = PhySupport3D(support4NodeIndex);
supports = {support1; support2; support3; support4};
 
groundStructure.createMembersFromNodes();

[forceList, potentialMemberList] = memberAdding(groundStructure, loadcases, supports, solverOptions);
groundStructure.plotMembers(forceList);


%% Building sectors
structure = groundStructure.createOptimizedStructureList(forceList);
splineSpacing = 5;
splintLineX = 0:splineSpacing:x;
splintLineY = 0:splineSpacing:y;
members = splitSector3DInX(structure, splintLineX);
splitedStructures = cell(x/splineSpacing, 1);
for i = 1:(x/splineSpacing)
    splitedStructures{i, 1} = splitSector3DInY(members{i, 1}, splintLineY);
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
[printPlanGrid, normalVectors] = plotPrintingSurface(angles, splintLineX, splintLineY, 0);
groundStructure.plotMembers(forceList);

%% Delete violating members in potential member list
memberExist = deleteMembersViolatePrintingPlan3D(potentialMemberList, splintLineX, splintLineY, angles, nozzleMaxAngle);
newMembers = potentialMemberList(memberExist == 1, :);

%% Re-optimize structure with known printing curve
newGroundStructure = GeoGroundStructure3D;
newGroundStructure.nodes = groundStructure.nodes;
newGroundStructure.members = newMembers;
forceList = fullGroundStructure(newGroundStructure, loadcases, supports, solverOptions);
newGroundStructure.plotMembers(forceList, 'figureNumber', 2);

%% Generate printing plan
newStructure = newGroundStructure.createOptimizedStructureList(forceList);
allSlices = generateOptimizedPrintPlan3D(structure, angles, splintLineX, splintLineY, printPlanGrid, normalVectors, z, false);

%% Caculate Nozzle Angles
maximumOverhangAngle = 0.262;
angles = calculateRealNozzleAngles(allSlices, normalVectors, maximumOverhangAngle);

%% Write G Code
outputGCode(allSlices, angles, x/2, y/2);