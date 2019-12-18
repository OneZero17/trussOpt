clear
caseNo =3;
switch caseNo
    case 1
        groundStructure = GeoGroundStructure;
        x=0.8;y=0.8;
        xSpacing = x/10; ySpacing = y/10;
        spaceHeight = 0;

        groundStructure.createCustomizedNodeGrid(0, spaceHeight, x, y, xSpacing, ySpacing);
        groundStructure.createMemberListFromNodeGrid();
        groundStructure.createNodesFromGrid();
        groundStructure.memberList = deleteCollinearMembers([groundStructure.nodeGrid, zeros(size(groundStructure.nodeGrid, 1), 1)], [groundStructure.memberList(:, 1:4), zeros(size(groundStructure.memberList, 1), 1), groundStructure.memberList(:, 5:6), zeros(size(groundStructure.memberList, 1), 1)]);
        groundStructure.memberList = groundStructure.memberList(:, [1 2 3 4 6 7]);
        groundStructure.createGroundStructureFromMemberList();

        loadcase1 = PhyLoadCase();
        load1NodeIndex = groundStructure.findOrAppendNode(x/2, y/2);
        load1 = PhyLoad(load1NodeIndex, 0, 0, 1e5);
        loadcase1.loads = {load1};
        loadcases = {loadcase1};

        supportNodes = unique([groundStructure.findNodesInRange([0, x, 0, 0]); 
                           groundStructure.findNodesInRange([0, 0, 0, y]);
                           groundStructure.findNodesInRange([x, x, 0, y]);
                           groundStructure.findNodesInRange([0, x, y, y])]);
        supports = cell(size(supportNodes, 1), 1);
        for i = 1:size(supportNodes, 1)
            support = PhySupport(supportNodes(i, 1), 1, 1, 1);
            supports{i, 1} = support;
        end 
        preExistingMembers = [];
        
    case 2
        groundStructure = GeoGroundStructure;
        x=10;y=10;
        xSpacing = 1; ySpacing = 1;
        spaceHeight = 8;

        groundStructure.createCustomizedNodeGrid(0, spaceHeight, x, y, xSpacing, ySpacing);
        groundStructure.createMemberListFromNodeGrid();
        groundStructure.createNodesFromGrid();
        groundStructure.memberList = deleteCollinearMembers([groundStructure.nodeGrid, zeros(size(groundStructure.nodeGrid, 1), 1)], [groundStructure.memberList(:, 1:4), zeros(size(groundStructure.memberList, 1), 1), groundStructure.memberList(:, 5:6), zeros(size(groundStructure.memberList, 1), 1)]);
        groundStructure.memberList = groundStructure.memberList(:, [1 2 3 4 6 7]);
        point1Index = groundStructure.findOrAppendNode(0, spaceHeight);
        point2Index = groundStructure.findOrAppendNode(x, spaceHeight);
        nodeNum = size(groundStructure.nodes, 1);
        groundStructure.nodeGrid = [groundStructure.nodeGrid; 0, 0; x, 0];
        groundStructure.createNodesFromGrid();
        groundStructure.memberList = [groundStructure.memberList; nodeNum+1, point1Index, groundStructure.nodeGrid(nodeNum+1, :), groundStructure.nodeGrid(point1Index, :); nodeNum+2, point2Index, groundStructure.nodeGrid(nodeNum+2, :), groundStructure.nodeGrid(point2Index, :)];
        groundStructure.createGroundStructureFromMemberList();
        groundStructure.plotMembers('plotGroundStructure', true, 'figureNumber', 3);
        
        loadcase1 = PhyLoadCase();
        load1NodeIndex = groundStructure.findOrAppendNode(0, y);
        load1 = PhyLoad(load1NodeIndex, 4e5, 0, 0);
        load2NodeIndex = groundStructure.findOrAppendNode(x, y);
        load2 = PhyLoad(load2NodeIndex, 4e5, 0, 0);
        loadcase1.loads = {load1; load2};
        loadcases = {loadcase1};
                
        support1NodeIndex = groundStructure.findOrAppendNode(0, 0);
        support2NodeIndex = groundStructure.findOrAppendNode(x, 0);
        support1 = PhySupport(support1NodeIndex, 1, 1, 1);
        support2 = PhySupport(support2NodeIndex, 1, 1, 1);
        supports = {support1; support2};
        preExistingMembers = [];
        
    case 3
        groundStructure = GeoGroundStructure;
        x=5;y=5;
        xSpacing = 0.5; ySpacing = 0.5;
        spaceHeight = 0;

        groundStructure.createCustomizedNodeGrid(0, spaceHeight, x, y, xSpacing, ySpacing);
        groundStructure.createMemberListFromNodeGrid();
        groundStructure.createNodesFromGrid();
        groundStructure.memberList = deleteCollinearMembers([groundStructure.nodeGrid, zeros(size(groundStructure.nodeGrid, 1), 1)], [groundStructure.memberList(:, 1:4), zeros(size(groundStructure.memberList, 1), 1), groundStructure.memberList(:, 5:6), zeros(size(groundStructure.memberList, 1), 1)]);
        groundStructure.memberList = groundStructure.memberList(:, [1 2 3 4 6 7]);
        if spaceHeight~= 0 
            point1Index = groundStructure.findOrAppendNode(0, spaceHeight);
            point2Index = groundStructure.findOrAppendNode(x, spaceHeight);
            nodeNum = size(groundStructure.nodes, 1);
            groundStructure.nodeGrid = [groundStructure.nodeGrid; 0, 0; x, 0];
            groundStructure.createNodesFromGrid();
            groundStructure.memberList = [groundStructure.memberList; nodeNum+1, point1Index, groundStructure.nodeGrid(nodeNum+1, :), groundStructure.nodeGrid(point1Index, :); nodeNum+2, point2Index, groundStructure.nodeGrid(nodeNum+2, :), groundStructure.nodeGrid(point2Index, :)];
        end
        groundStructure.createGroundStructureFromMemberList();
        %groundStructure.plotMembers('plotGroundStructure', true, 'figureNumber', 3);
        
        cladingLoadNodes = groundStructure.findNodesInRange([0, x, y, y])';
        cladingLoads = cell(size(cladingLoadNodes, 1) + 2, 1);
        for i = 1:size(cladingLoadNodes, 1)
            cladingLoads{i, 1} = PhyLoad(cladingLoadNodes(i, 1), 0, -5e3, 0);
        end
        allLoads1 = cladingLoads;
        allLoads2 = cladingLoads;
        
        loadcase1 = PhyLoadCase();
        load1NodeIndex = groundStructure.findOrAppendNode(0, y);
        load2NodeIndex = groundStructure.findOrAppendNode(x, y);
        allLoads1{size(cladingLoadNodes, 1) + 1, 1} = PhyLoad(load1NodeIndex, 1e4, 0, 0);
        allLoads1{size(cladingLoadNodes, 1) + 2, 1} = PhyLoad(load2NodeIndex, 1e4, 0, 0);
        
        loadcase2 = PhyLoadCase();
        allLoads2{size(cladingLoadNodes, 1) + 1, 1} = PhyLoad(load1NodeIndex, -1e4, 0, 0);
        allLoads2{size(cladingLoadNodes, 1) + 2, 1} = PhyLoad(load2NodeIndex, -1e4, 0, 0);
        
        loadcase1.loads = allLoads1;      
        loadcase2.loads = allLoads2;   
        loadcases = {loadcase1; loadcase2};
        
        support1NodeIndex = groundStructure.findOrAppendNode(0, 0);
        support2NodeIndex = groundStructure.findOrAppendNode(x, 0);
        support1 = PhySupport(support1NodeIndex, 1, 1, 1);
        support2 = PhySupport(support2NodeIndex, 1, 1, 1);
        supports = {support1; support2};
        preExistingMembers = [0, x, y, y, 0];
end

solverOptions = OptOptions();
solverOptions.sigmaC = 350;
solverOptions.sigmaT = 350;
existingVolume = 0;
beamSolution = beamIterativeScheme(groundStructure, loadcases, supports, solverOptions, 0.1, existingVolume, preExistingMembers);
plotBeamStructure(groundStructure.memberList, beamSolution, 2, x, y, 1/1000, 1);

% trussSolution = truss2D(groundStructure, loadcases, supports, solverOptions);
% plotStructure(trussSolution, 1, x, y, true);
max(beamSolution(:, 1))
maximumSectionSize = sqrt(max(beamSolution(:, 1)/(0.19*pi)));
fprintf("maximum section length is %.4f mm* %.4f mm\n",maximumSectionSize, maximumSectionSize)