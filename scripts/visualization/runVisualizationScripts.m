function runVisualizationScripts(robotVisualization, optimizationProperties, data)
EEnames        = data.basicProperties.EEnames;
config         = data.basicProperties.configSelection;
classSelection = data.basicProperties.classSelection;
task           = data.basicProperties.task;

%% Nominal robot
  if robotVisualization.view 
    fprintf('Visualizing nominal robot. \n');
    optimized = false;
    fileName = strcat('Nominal_', classSelection, '_',task, '_', config, '.gif'); % for gif of motion
    
    if robotVisualization.allLegs
        vizIndex = 1;
    elseif robotVisualization.oneLeg
        vizIndex = data.basicProperties.legCount;
    end
    
    for i = 1:vizIndex
        EEselection = EEnames(i,:);
        visualizeRobot(data, EEselection, fileName, robotVisualization, optimized);
    end
  end
    
%% Optimized robot
    if data.optimizationProperties.runOptimization && robotVisualization.view
        fprintf('Visualizing optimized robot. \n');
        optimized = true;
        fileName = strcat('Optimized_', classSelection, '_',task, '_', config, '.gif'); % for gif of motion
        if robotVisualization.allLegs
            vizIndex = 1;
        elseif robotVisualization.oneLeg
            vizIndex = data.basicProperties.legCount;
        end

        for i = 1:vizIndex
            EEselection = EEnames(i,:);
            visualizeRobot(data, EEselection, fileName, robotVisualization, optimized);
        end
    end
  end