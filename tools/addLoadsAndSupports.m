function [outputLoads, outputSupports] = addLoadsAndSupports(matlabMesh, loads, supports)
    outputLoads = [];
    for i = 1:size(loads, 1)
        load = loads(i, end);
        loadRange = [loads(i, 1:2); loads(i, 3:4)];
        uniformLoad = PhyUniformLoad(loadRange, 0, load, matlabMesh);
        outputLoads = [outputLoads; uniformLoad.loads];
    end
    
    outputSupports = [];
    for i = 1:size(supports, 1)
        supportRange = [supports(i, 1:2); supports(i, 3:4)];
        uniformSupports = PhyUniformSupport(supportRange, supports(i, end-1), supports(i, end), matlabMesh);
        outputSupports = [outputSupports; uniformSupports.supports];
    end
end