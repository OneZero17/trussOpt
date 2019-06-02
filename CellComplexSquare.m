classdef CellComplexSquare < CellBasic
    properties
        splitNum
        boundnodes
        boundMembers
        innerMembers
    end
    
    methods
        function obj = CellComplexSquare(nodes, splitNum)
            obj.nodes = nodes;
            obj.splitNum = splitNum;
        end
        
        function newMembers = initialize(self)
            self.boundnodes = cell(4, self.splitNum + 1);
            self.boundMembers = cell(4, self.splitNum);
            newMembers = cell(4*self.splitNum + 2*((self.splitNum+1)*(self.splitNum+1)-2)-2, 1);
            self.innerMembers = cell(2*((self.splitNum+1)*(self.splitNum+1)-2)-2, 1);
            newMemberNum = 0;
            innerMemberNum=0;
            for i =1:4
                if (i == 4)
                    self.boundnodes(i,:) = [self.nodes(self.splitNum*(i-1)+1:self.splitNum*i, 1);self.nodes(1, 1)];  
                else
                    self.boundnodes(i,:) = self.nodes(self.splitNum*(i-1)+1:self.splitNum*i + 1, 1);
                end
            end
            
            for i =1:4
                for j = 1:self.splitNum
                    self.boundMembers{i, j} = GeoMember(self.boundnodes{i, j}, self.boundnodes{i, j+1});
                    newMemberNum = newMemberNum +1;
                    newMembers{newMemberNum, 1} = self.boundMembers{i, j};
                end
            end
            
            for i = 1:self.splitNum+1
                for j = 1:self.splitNum+1
                    if (i==1 && j == self.splitNum+1)  || (j==1 && i == self.splitNum+1)
                        continue;
                    end
                    newMemberNum = newMemberNum +1;
                    newMembers{newMemberNum, 1} = GeoMember(self.boundnodes{1, i}, self.boundnodes{3, j});
                    innerMemberNum = innerMemberNum+1;
                    self.innerMembers{innerMemberNum, 1}= newMembers{newMemberNum, 1};
                    if ~((i==1&& j ==1) ||(i==self.splitNum+1&& j==self.splitNum+1))
                        newMemberNum = newMemberNum +1;
                        newMembers{newMemberNum, 1} = GeoMember(self.boundnodes{2, i}, self.boundnodes{4, j});
                        innerMemberNum = innerMemberNum+1;
                        self.innerMembers{innerMemberNum, 1}= newMembers{newMemberNum, 1};
                    end
                end
            end
            self.members = newMembers;
        end
    end
end

