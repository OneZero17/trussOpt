function toRhino(folder, name, structure)
    structureTools = OptStructureTools;
    [Cn, Nd] = structureTools.generateCnAndNdList(structure);
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    filepath = [folder,'/'];

    createNode(Nd, filepath);
    if ~isempty(Cn)
        createTruss(Cn, filepath, name);
        %createGrillage(Cn, filepath, name);
    end
end

function createNode(Nd, folder)
    pos = Nd;
    if size(pos,2) == 2
        pos = [pos, zeros(size(pos,1),1)];
    end
    fprintf('writing %d nodes to csv\n', size(Nd, 1));
    csvwrite([folder, 'node.csv'], pos);
end

function createTruss(Cn, folder, name)
    if size(Cn, 1)>0
        fprintf('writing %d truss bars to csv\n', size(Cn, 1));
        csvwrite([folder, sprintf('%s.csv',name)], Cn);
    end
end

function createGrillage(Cn, folder, name)
type = vertcat(Cn.type);
Cn = Cn(type==2);
if length(Cn)>1
    nid = vertcat(Cn.nid);
    a1 = vertcat(Cn.a1);
    a2 = vertcat(Cn.a2);
    data = [nid, a1, a2];
    lst = find((a1+a2)>max(a1+a2)*0.0001);
    fprintf('writing %d grillage beams to csv\n', length(lst));
    csvwrite([folder, 'grillage.csv'], data);
end
end






