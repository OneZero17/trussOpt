load('meshfile.mat');
load('matlabMeshfile.mat');
newMatlabMesh = mesh.createNewMeshWithSetLevel(matlabMesh, 0.3);
beforeSmoothing = Mesh(newMatlabMesh);
beforeSmoothing.plotMesh('title', 'beforeSmoothing', 'xLimit', 20, 'yLimit', 10, 'figureNumber', 1,'plotGroundStructure', true);

tempMesh.faces = newMatlabMesh.Elements';
tempMesh.vertices = [newMatlabMesh.Nodes; zeros(1, size(newMatlabMesh.Nodes, 2))]';
%afterSmoothing = smoothpatch(tempMesh, 1, 5, 0.5);
%afterSmoothing = smoothpatch(tempMesh, 1, 1, -0.5);
afterSmoothing.faces = tempMesh.faces;
afterSmoothing.vertices = lpflow_trismooth(tempMesh.vertices, tempMesh.faces, 50, 0.8, 0.87);
newMatlabMesh.Elements = afterSmoothing.faces';
newMatlabMesh.Nodes = afterSmoothing.vertices(:, 1:2)';

afterSmoothingMesh = Mesh(newMatlabMesh);
afterSmoothingMesh.plotMesh('title', 'afterSmoothing', 'xLimit', 20, 'yLimit', 10, 'figureNumber', 2,'plotGroundStructure', true);