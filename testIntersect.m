groundStructure = GeoGroundStructure;
matlabMesh = createRectangularMeshMK2(2, 2, 1);
groundStructure.nodeGrid = matlabMesh.Nodes';
groundStructure.createMemberListFromNodeGrid();
matlabMesh2 = createRectangularMeshMK2(0.5, 0.5, 0.5);
tic
deleteOverlappingMembers(groundStructure, matlabMesh2);
toc
groundStructure.createNodesFromGrid();
groundStructure.createGroundStructureFromMemberList();
groundStructure.plotMembers('plotGroundStructure', true);

