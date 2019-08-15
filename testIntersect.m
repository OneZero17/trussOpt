groundStructure = GeoGroundStructure;
matlabMesh = createRectangularMeshMK2(10, 10, 1);
groundStructure.nodeGrid = matlabMesh.Nodes';
groundStructure.createMemberListFromNodeGrid();
matlabMesh2 = createRectangularMeshMK2(5, 5, 0.5);
tic
deleteOverlappingMembers(groundStructure, matlabMesh2, 0.5);
toc
groundStructure.createNodesFromGrid();
groundStructure.createGroundStructureFromMemberList();
groundStructure.plotMembers('plotGroundStructure', true);

