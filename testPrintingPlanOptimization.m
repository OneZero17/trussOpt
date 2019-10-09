clear
groundStructure = GeoGroundStructure;
x=10;y=10;
xSpacing = 0.5; ySpacing = 0.5;
groundStructure.createCustomizedNodeGrid(0, 0, x, y, xSpacing, ySpacing);
groundStructure.createMemberListFromNodeGrid();
groundStructure.createNodesFromGrid();
loadcase = PhyLoadCase();
load1NodeIndex = groundStructure.findOrAppendNode(x/2, y);
%load2NodeIndex = groundStructure.findOrAppendNode(x, y);
load1 = PhyLoad(load1NodeIndex, 0.2, -0.0);
%load2 = PhyLoad(load2NodeIndex, 0.1, 0);
loadcase.loads = {load1};
loadcases = {loadcase};

% supports = cell(11, 1);
% for i = 1:11
%     supportNodeIndex = groundStructure.findOrAppendNode((i-1)*1, 0);
%     support = PhySupport(supportNodeIndex);
%     supports{i, 1} = support;
% end
support1NodeIndex = groundStructure.findOrAppendNode(0, 0);
support2NodeIndex = groundStructure.findOrAppendNode(10, 0);
support1 = PhySupport(support1NodeIndex, 1, 1);
support2 = PhySupport(support2NodeIndex, 1, 1);
supports = {support1; support2};

% existList = intersectionWithHorizontalLine(groundStructure.memberList(:, 3:end));
% groundStructure.memberList = groundStructure.memberList(existList ==1, :);

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
groundStructure.plotMembers();
structure = groundStructure.createOptimizedStructureList();

splitedZones = 0:0.1:10;
splitedStructures = splitSector(structure, splitedZones);
printPlanProblem = PPOptProblem;
printPlanProblem.createProblem(splitedStructures, splitedZones);

[conNum, varNum, objVarNum] = printPlanProblem.getConAndVarNum();
matrix = ProgMatrix(conNum, varNum, objVarNum);
printPlanProblem.initializeProblem(matrix);
result = mosekSolve(matrix, 1);
matrix.feedBackResult(result);
angles = printPlanProblem.outputPrintingAngles();
plotPrintPlans(splitedZones, angles, 1);

newMemberList = deleteMembersViolatePrintingPlan(groundStructure.memberList, splitedZones, angles);
groundStructure = GeoGroundStructure;
groundStructure.createCustomizedNodeGrid(0, 0, x, y, xSpacing, ySpacing);
groundStructure.memberList = newMemberList;
groundStructure.createNodesFromGrid();
groundStructure.createGroundStructureFromMemberList();

loadcase = PhyLoadCase();
load1NodeIndex = groundStructure.findOrAppendNode(x/2, y);
load1 = PhyLoad(load1NodeIndex, 0.2, -0.0);
loadcase.loads = {load1};
loadcases = {loadcase};

support1NodeIndex = groundStructure.findOrAppendNode(0, 0);
support2NodeIndex = groundStructure.findOrAppendNode(10, 0);
support1 = PhySupport(support1NodeIndex, 1, 1);
support2 = PhySupport(support2NodeIndex, 1, 1);
supports = {support1; support2};

trussProblem.createProblem(groundStructure, loadcases, supports, solverOptions);

[conNum, varNum, objVarNum] = trussProblem.getConAndVarNum();
matrix = ProgMatrix(conNum, varNum, objVarNum);
trussProblem.initializeProblem(matrix);
result = mosekSolve(matrix, 1);
matrix.feedBackResult(result);
trussProblem.feedBackResult(1);
groundStructure.plotMembers('figureNumber', 2);


function existList = intersectionWithHorizontalLine(members)
    memebrNum = size(members, 1);
    slope = (members(:, 4) - members(:, 2))./(members(:, 3) - members(:, 1));
    
    existList = ones(memebrNum, 1);
    existList(slope>-0.674 & slope<0.674) = 0;
end