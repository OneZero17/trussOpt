clear
groundStructure = GeoGroundStructure;
x=5;y=10;
xSpacing = 1; ySpacing = 1;

groundStructure.createCustomizedNodeGrid(0, 0, x, y, xSpacing, ySpacing);
groundStructure.createMemberListFromNodeGrid();
% memberLengthList = vecnorm((groundStructure.memberList(:, 5:6) - groundStructure.memberList(:, 3:4))')';
% groundStructure.memberList = groundStructure.memberList(memberLengthList<2, :);

groundStructure.createNodesFromGrid();

loadcase = PhyLoadCase();
load1NodeIndex = groundStructure.findOrAppendNode(3, y);
load1 = PhyLoad(load1NodeIndex, 1, 0.0, 0.0);
loadcase.loads = {load1};
loadcases = {loadcase};

support1NodeIndex = groundStructure.findOrAppendNode(0, 0);
support2NodeIndex = groundStructure.findOrAppendNode(x, 0);
support1 = PhySupport(support1NodeIndex, 1, 1, 1);
support2 = PhySupport(support2NodeIndex, 1, 1, 1);
supports = {support1; support2};

solverOptions = OptOptions();

%%
solverOptions.sectionModulus = [0, 0, 0.4];
solverOptions.allowExistingBeamVolume = 0.4 * 35.759;
beamProblem = OptBeamProblem();
beamProblem.createProblem(groundStructure, loadcases, supports, solverOptions);

[conNum, varNum, objVarNum] = beamProblem.getConAndVarNum();
matrix = ProgMatrix(conNum, varNum, objVarNum);
beamProblem.initializeProblem(matrix);

if solverOptions.allowExistingBeamVolume~= 0 
    beamProblem.addBeamVolumeConstraint(matrix, solverOptions.allowExistingBeamVolume);
end
result = mosekSolve(matrix, 1);
matrix.feedBackResult(result);
areaAndForceList = beamProblem.outputResult(1);

plotBeamStructure(groundStructure.memberList, areaAndForceList,6, 10, 10, 1/1000, 1/10);