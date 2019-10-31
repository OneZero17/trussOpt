clear
groundStructure = GeoGroundStructure3D;
x=10; y=40; z=10;
spacing = 5;
solverOptions = OptOptions();
solverOptions.nodalSpacing = spacing * 1.75;
groundStructure.createCustomizedNodeGrid([0,0,0], [x, y, z], [spacing, spacing, spacing]);

loadcase1 = PhyLoadCase();
load1NodeIndex1 = groundStructure.findNodeIndex([x/2, y, 0]);
load1 = PhyLoad3D(load1NodeIndex1, 0.0, 0.0, -0.5);
loadcase1.loads = {load1};
%loadcase2 = PhyLoadCase();
%load2 = PhyLoad3D(load1NodeIndex, -0.0, 0.5, 0.0);
%loadcase2.loads = {load2};
loadcases = {loadcase1};
 
support1NodeIndex = groundStructure.findNodeIndex([0, 0, 0]);
support2NodeIndex = groundStructure.findNodeIndex([10, 0, 0]);
support3NodeIndex = groundStructure.findNodeIndex([0, 10, 5]);
support4NodeIndex = groundStructure.findNodeIndex([10, 10, 5]);
support1 = PhySupport3D(support1NodeIndex);
support2 = PhySupport3D(support2NodeIndex);
support3 = PhySupport3D(support3NodeIndex);
support4 = PhySupport3D(support4NodeIndex);
supports = {support1; support2; support3; support4};
 
groundStructure.createMembersFromNodes();

forceList = memberAdding(groundStructure, loadcases, supports, solverOptions);
groundStructure.plotMembers(forceList);
