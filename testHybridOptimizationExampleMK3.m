clear
warning('off','all')
for i = 4:9
    clearvars -except i
    casenum = 1;
    switch casenum  
        case 1
            x = 20; y = 10; thickness = 1; setContinuumLevel = 0.3;
            continuumSpacing = 0.2; discreteSpacing = 2;
            loads = [x, x, y/2-0.75, y/2+0.75, -0.1 * i];
            supports = [0, 0, -0.001, y+0.001, 1, 1];
            runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 0.5, 0.1);
            runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 0.5, 0.1);
            runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 0.8, 0.2);
            runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 0.8, 0.2);
        case 2
            x = 10; y = 5; thickness = 1; setContinuumLevel = 0.3;
            continuumSpacing = 0.5; discreteSpacing = 1;
            loads = [x/2-0.3, x/2+0.3, 0, 0, -0.1*i];
            supports = [0, 0.6, 0, 0.0, 1, 1; x-0.6, x, 0, 0.0, 1, 1];
            runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 0.4, 0);
        case 3
            x = 10; y = 5; thickness = 1; setContinuumLevel = 0.3;
            continuumSpacing = 0.125; discreteSpacing = 1.0;
            loads = [x/2-0.3, x/2+0.3, 0, 0, -0.1*i];
            supports = [0, 0.6, 0, 0.0, 1, 1; x-0.6, x, 0, 0.0, 0, 1];
            runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 0.5, 0.1);
            %runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 1.0, 0.1);
    end
end