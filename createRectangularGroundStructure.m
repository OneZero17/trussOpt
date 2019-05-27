function obj = createRectangularGroundStructure(sizeX, sizeY)

if (nargin == 0)
    sizeX = 10;
    sizeY = 10;
end

nodes = cell(sizeX*sizeY, 1);
nodeNum = 1;
for i= 1:sizeX
    for j = 1:sizeY
        nodes{nodeNum, 1} = GeoNode(i,j);
        nodeNum = nodeNum+1;
    end
end

members = cell(size(nodes,1)*(size(nodes,1) - 1)/2, 1);
memberNum = 1;
for i = 1:size(nodes)
    for j = i+1:size(nodes)
        members{memberNum, 1} = GeoMember(nodes{i,1}, nodes{j,1});
        memberNum = memberNum + 1;
    end
end

obj = GeoGroundStructure(nodes, members);
end