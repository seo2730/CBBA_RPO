function taskS = generate_tasks(numTasks,simDurWks,seedSMA,sigmaSMA,seedInc,sigmaInc,seedRAAN,sigmaRAAN,seedLife,sigmaLife,typeVal)

maxDurationTask = 4;
endAdderWks     = 20;

taskS = struct('family','','id',{},'type',{},'start',{},'end',{},...
    'duration',{},'pref_beta',{},'SMA',{},'INCL',{},'RAAN',{},...
    'life_remaining',{},'design_life',{},'score',{});

for iTask = 1:numTasks
    
    taskS(iTask).family = 'task';
    
    taskS(iTask).id   = iTask;
    taskS(iTask).type = typeVal;
    
    % Temporal constraints
    taskS(iTask).start    = round(simDurWks * rand(1),0);
    taskS(iTask).duration = 1 + round(maxDurationTask * rand(1),1);
    taskS(iTask).end      = taskS(iTask).start + ceil(taskS(iTask).duration) + round(endAdderWks * rand(1),0);
    if taskS(iTask).end > simDurWks
        taskS(iTask).end      = simDurWks;
        
        if (taskS(iTask).duration > (taskS(iTask).end - taskS(iTask).start) )
            taskS(iTask).duration = taskS(iTask).end - taskS(iTask).start;
        end
    end
    
    % Lighting information
    taskS(iTask).pref_beta   = round(90 * rand(1),1);
    taskS(iTask).beta_lambda = -5; %round(-6 + 1.5 * randn(1),2);
    
    % Orbit Parms
    taskS(iTask).SMA  = seedSMA + sigmaSMA * randn(1);
    taskS(iTask).INCL = seedInc + sigmaInc * randn(1);
    taskS(iTask).RAAN = seedRAAN + sigmaRAAN * randn(1);
    
    % RSO (task) spacecraft properties
    taskS(iTask).life_remaining = rand(1);
    taskS(iTask).design_life    = round(seedLife + sigmaLife * randn(1),1);
    
end

end