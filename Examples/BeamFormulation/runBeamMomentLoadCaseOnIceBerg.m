function  runBeamMomentLoadCaseOnIceBerg(sideLength, spacingNumber, momentLoad)
        groundStructure = GeoGroundStructure;
        x = sideLength; y = sideLength;
        xSpacing = x/spacingNumber; ySpacing = y/spacingNumber;

        groundStructure.createCustomizedNodeGrid(0, 0, x, y, xSpacing, ySpacing);
        groundStructure.createMemberListFromNodeGrid();
        groundStructure.createNodesFromGrid();
        groundStructure.memberList = deleteCollinearMembers([groundStructure.nodeGrid, zeros(size(groundStructure.nodeGrid, 1), 1)], [groundStructure.memberList(:, 1:4), zeros(size(groundStructure.memberList, 1), 1), groundStructure.memberList(:, 5:6), zeros(size(groundStructure.memberList, 1), 1)]);
        groundStructure.memberList = groundStructure.memberList(:, [1 2 3 4 6 7]);
        groundStructure.createGroundStructureFromMemberList();

        loadcase1 = PhyLoadCase();
        load1NodeIndex = groundStructure.findOrAppendNode(x/2, y/2);
        load1 = PhyLoad(load1NodeIndex, 0, 0, momentLoad*1e4);
        loadcase1.loads = {load1};
        loadcases = {loadcase1};

        supportNodes = unique([groundStructure.findNodesInRange([0, x, 0, 0]);groundStructure.findNodesInRange([0, 0, 0, y]);groundStructure.findNodesInRange([x, x, 0, y]);groundStructure.findNodesInRange([0, x, y, y])]);
        supports = cell(size(supportNodes, 1), 1);
        for i = 1:size(supportNodes, 1)
            support = PhySupport(supportNodes(i, 1), 1, 1, 1);
            supports{i, 1} = support;
        end 
        preExistingMembers = [];
        solverOptions = OptOptions();
        solverOptions.sigmaC = 350;
        solverOptions.sigmaT = 350;
        existingVolume = 0;
        beamSolution = beamIterativeScheme(groundStructure, loadcases, supports, solverOptions, 0.1, existingVolume, preExistingMembers);
        fileName = sprintf('Size_%i_Spacing_%i_Load_%i',sideLength, spacingNumber, momentLoad);
        plotBeamStructure(groundStructure.memberList, beamSolution, 2, x, y, 1/1000, 1, fileName);
        save(fileName, beamSolution);
        max(beamSolution(:, 1))
        maximumSectionSize = sqrt(max(beamSolution(:, 1)/(0.19*pi)));
        sprintf('maximum section length is %.4f mm* %.4f mm\n',maximumSectionSize, maximumSectionSize)
end

