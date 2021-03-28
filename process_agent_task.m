function [agents,tasks] = process_agent_task(numAgents,numTasks,JD_epoch,simDurWks, lightMult, lifeMult)

%--------- Agent information
agentSeedSMA   = 6378 + 1000; % km
agentSigmaSMA  = 20;  % km

agentSeedInc   = 47;  % deg
agentSigmaInc  = 0.1; % deg

agentSeedRAAN  = 30;  % deg
agentSigmaRAAN = 30; % deg

agentDvSeed = 1;     % km/sec
agentSigmaDv = 0.1;  % km/sec

%--------- Task information
taskSeedSMA   = 6378 + 1000; % km
taskSigmaSMA  = 20;  % km
taskSeedInc   = 47;  % deg
taskSigmaInc  = 0.1; % deg
taskSeedRAAN  = 30;  % deg
taskSigmaRAAN = 30; % deg

taskSeedLife  = 4;   % years
taskSigmaLife = 1;   % years

typeVal   = 1; % type indicator. Must match task type.

% Generate agent structure
agents = generate_agents(numAgents,agentSeedSMA,agentSigmaSMA,agentSeedInc,...
    agentSigmaInc,agentSeedRAAN,agentSigmaRAAN,agentDvSeed, agentSigmaDv, typeVal);

% Generate task structure
tasks = generate_tasks(numTasks,simDurWks,taskSeedSMA,taskSigmaSMA,...
    taskSeedInc,taskSigmaInc,taskSeedRAAN,taskSigmaRAAN,taskSeedLife,taskSigmaLife,typeVal);

for iTask = 1:numTasks
    
    % Pull beta information
    S = RendezvousFunc_weeks_updated(agents(1),tasks(iTask),JD_epoch,JD_epoch,simDurWks);
    
    % Compute score for lighting conditions
    lightScore = lightMult * exp(tasks(iTask).beta_lambda * ( abs(tasks(iTask).pref_beta - S.RSO.Beta)) / 180);
    
    % Compute score for lifetime
    lifeScore  = get_lifetime_boost(simDurWks, tasks(iTask).life_remaining, tasks(iTask).design_life, lifeMult);
    
    % Add lifetime and lighting scores together
    combinedScore = lightScore + lifeScore;
    
    % Extract average task score between start/end times
    tasks(iTask).score = round(mean(combinedScore(tasks(iTask).start:tasks(iTask).end)),2);
    
end

end
%==========================================================================
%                       END OF FUNCTION
%==========================================================================