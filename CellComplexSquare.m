classdef CellComplexSquare < CellBasic
    properties
        splitNum
        boundnodes
        boundMembers
        innerMembers
        nodeNum = 0;
        memberNum = 0;
        optCell
    end
    
    methods
        function obj = CellComplexSquare(xStart, yStart, size, splitNum)
            obj.xStart = xStart;
            obj.yStart = yStart;
            obj.size = size;
            obj.splitNum = splitNum;
        end
        
        function createBoundNodes(self, boundIndex, startNode)
            spacing = self.size/self.splitNum;
            for i = 1:self.splitNum
                if nargin> 2 && i ==1
                    self.boundnodes{boundIndex, 1} = startNode;
                else
                    switch boundIndex
                        case 1
                            x = self.xStart + spacing * (i - 1);
                            y = self.yStart;
                        case 2
                            x = self.xStart + self.size;
                            y = self.yStart + spacing * (i - 1);
                        case 3
                            x = self.xStart + self.size - spacing * (i - 1);
                            y = self.yStart + self.size;
                        case 4
                            x = self.xStart;
                            y = self.yStart + self.size - spacing * (i - 1);
                    end
                    node = GeoNode(x, y);
                    self.nodeNum = self.nodeNum+1;
                    self.nodes{self.nodeNum, 1} = node;
                    self.boundnodes{boundIndex, i} = node;
                end
            end
            
        end
        
        function addBoundEndNode(self)
            for i = 1:4
                if isempty(self.boundnodes{i, self.splitNum+1})
                    if i ~= 4
                        self.boundnodes{i, self.splitNum+1} = self.boundnodes{i+1, 1};

                    else
                        self.boundnodes{i, self.splitNum+1} = self.boundnodes{1, 1};
                    end
                end
            end
        end
        
        function createBoundMembers(self, boundIndex)
            for i = 1:self.splitNum
                self.boundMembers{boundIndex, i} = GeoMember(self.boundnodes{boundIndex, i}, self.boundnodes{boundIndex, i+1});
                self.memberNum = self.memberNum +1;
                self.members{self.memberNum, 1} = self.boundMembers{boundIndex, i};
            end
        end
        
        function createInnerMembers(self)
           innerMemberNum=0;
           self.innerMembers = cell(2*((self.splitNum+1)*(self.splitNum+1)-2)-2, 1);
           for i = 1:self.splitNum+1
               for j = 1:self.splitNum+1
                   if (i==1 && j == self.splitNum+1)  || (j==1 && i == self.splitNum+1)
                        continue;
                   end
                   self.memberNum = self.memberNum +1;
                   self.members{self.memberNum, 1} = GeoMember(self.boundnodes{1, i}, self.boundnodes{3, j});
                   innerMemberNum = innerMemberNum+1;
                   self.innerMembers{innerMemberNum, 1}= self.members{self.memberNum, 1};
                   if ~((i==1&& j ==1) ||(i==self.splitNum+1&& j==self.splitNum+1))
                        self.memberNum = self.memberNum +1;
                        self.members{self.memberNum, 1} = GeoMember(self.boundnodes{2, i}, self.boundnodes{4, j});
                        innerMemberNum = innerMemberNum+1;
                        self.innerMembers{innerMemberNum, 1}= self.members{self.memberNum, 1};
                   end
               end
           end
        end
        
        function newMembers = initialize(self)
            self.boundnodes = cell(4, self.splitNum + 1);
            self.boundMembers = cell(4, self.splitNum);
            newMembers = cell(4*self.splitNum + 2*((self.splitNum+1)*(self.splitNum+1)-2)-2, 1);
            self.innerMembers = cell(2*((self.splitNum+1)*(self.splitNum+1)-2)-2, 1);
            newMemberNum = 0;
            
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
            

            self.members = newMembers;
        end
    end
end

