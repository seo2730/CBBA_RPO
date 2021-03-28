function [tasksMissed,tasksVisited] = process_assignments(CBBA_Assignments)

numAgentsInSim = length(CBBA_Assignments);

tasksMissed = 1:length(CBBA_Assignments(1).path);
tasksVisited = [];
for iAgent = 1:numAgentsInSim
    
    validInds = find(CBBA_Assignments(iAgent).path > 0);
    taskIDs = CBBA_Assignments(iAgent).path(validInds); %#ok<FNDSB>
    
    tasksVisited = [tasksVisited,taskIDs]; %#ok<AGROW>
    
    for iTask = 1:length(taskIDs)
        tasksMissed(tasksMissed == taskIDs(iTask)) = [];
        
    end
    
    %tasksNotFulfilled(tasksNotFulfilled==taskIDs) = [];
    
end


tasksVisited = sortrows(tasksVisited');
