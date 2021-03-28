% Copyright 2010
% Massachusetts Institute of Technology
% All rights reserved
% Developed by the Aerospace Controls Lab, MIT

%---------------------------------------------------------------------%
% Consensus-Based Bundle Algorithm (CBBA)

% This software package implements the Consensus-Based Bundle Algorithm
% (CBBA), a decentralized market-based protocol that provides provably good 
% approximate solutions for multi-agent multi-task allocation problems
% over networks of heterogeneous agents. The current version supports 
% tasks with time windows of validity, heterogeneous agent-task 
% compatibility requirements, and score functions that balance task
% reward and fuel costs.
%
%---------------------------------------------------------------------%
% Main test file.  Initializes problem and calls CBBA.
%---------------------------------------------------------------------%


%=======================================================================%
%=======================================================================%
% Modified 2019
% Skylar Cox, Space Dynamics Laboratory
%------------------------------------------------------------------------
% Description: Modified to operate on an RPO planning mission for
% long-range spacecraft rendezvous and servicing.
%========================================================================
%=======================================================================%

% Clear environment
% clearvars; % all;
% close all; 
% 
% %global dvMult lambdaDV
% %---------------------------------------------------------------------%
% % Define agents and tasks
% %---------------------------------------------------------------------%
% % Define number of agents and tasks
% numAgents = 3;            % # of agents
% numRSOs   = 25;           % # of tasks
% 
% % Time information:
% JD_epoch = 2451545; % Julian Day start of simulation
% simYears = 2;
% lifeMult = 50;
% lightMult = 200;
% 
% yrsToWks = 52; % Weeks in a year
% simDurWks = simYears * yrsToWks;
% 
% % Initialize parameters
% CBBA_Params    = CBBA_Init_RPO(numAgents,numRSOs);
% CBBA_Params.JD = JD_epoch; 
% 
% CBBA_Params.sim_years = simYears; %CBBA_Params.JD + simYears * 365;
% CBBA_Params.num_weeks = simDurWks;
% 
% CBBA_Params.N = numAgents;
% CBBA_Params.M = numRSOs;
% 
% % Generate agents and tasks
% [agents,tasks] = process_agent_task(numAgents,numRSOs,JD_epoch,simDurWks, lightMult, lifeMult);
% 
% %---------------------------------------------------------------------%
% % Initialize communication graph and diameter
% %---------------------------------------------------------------------%
% 
% % Fully connected graph
% Graph = ~eye(numAgents);


load('Agents_RPO_tasks.mat')
%---------------------------------------------------------------------%
% Run CBBA
%---------------------------------------------------------------------%
costWeights = 100:25:1000;
lamVals = -1:-0.25:-15;


numMults = length(costWeights);
numLams  = length(lamVals);

costGrid = repmat(costWeights,[numLams,1]);
lamGrid  = repmat(lamVals',[1,numMults]);
    
totalRuns = numMults * numLams;

totDeltaV      = zeros(numMults,numLams);
totScore       = zeros(numMults,numLams);
normUtility    = zeros(numMults,numLams);
tasksScheduled = zeros(numMults,numLams);

runNum = 0;
for iWeight = 1:numMults
    for iLam = 1:numLams
        dvMult = costWeights(iWeight);
        lambdaDV = lamVals(iLam);
        
        CBBA_Params.dvMult = dvMult;
        CBBA_Params.lambdaDV = lambdaDV;
        
        
        [CBBA_Assignments, Total_Score] = CBBA_Main_RPO(CBBA_Params, agents, tasks, Graph);
        
        %PlotAssignments_RPO_Corrected(CBBA_Params, CBBA_Assignments, agents, tasks,simDurWks, 1);
        
        [tasksMissed,tasksVisited] = process_assignments(CBBA_Assignments);
        
        fprintf('%d  Tasks Missed out of %d \n',length(tasksMissed),numRSOs)
        fprintf('%d Tasks Fulfilled \n',length(tasksVisited))
        %PlotAssignments(WORLD, CBBA_Assignments, agents, tasks, 1);
        
        % Calculate delta-V for each agent
        totalDeltaV = zeros(numAgents,1);
        for iAgent = 1:numAgents
            totalDeltaV(iAgent,1) = compute_deltaV_for_sequence(agents(iAgent), CBBA_Assignments(iAgent), tasks, JD_epoch, simDurWks);
            
        end
        
        tasksScheduled(iWeight,iLam) = length(tasksVisited);
        
        totDeltaV(iWeight,iLam) = 1000* sum(totalDeltaV);
        totScore(iWeight,iLam) = Total_Score;
        
        normUtility(iWeight,iLam) = Total_Score / (1000*sum(totalDeltaV));
        
        runNum = runNum + 1;
        fprintf('Run %d of %d done. ----> %3.1f percent complete.\n',runNum,totalRuns,100* runNum/totalRuns)
    end
end

% ------------------
%% Generate figures
figure('Position',[300 300 900 800])
surfc(costGrid',lamGrid',totScore)
shading interp
colormap jet
title('Normalized Score by Weight and Scale Factor')
xlabel('Weight Factor (w_{\DeltaV})')
ylabel('Scale Factor ({\lambda_{\DeltaV}})')
zlabel('Score Value')
colorbar

figure('Position',[300 300 900 800])
surfc(costGrid',lamGrid',totDeltaV)
shading interp
colormap jet
title('Resulting Global {\DeltaV} by Weight and Scale Factor')
xlabel('Weight Factor (w_{\DeltaV})')
ylabel('Scale Factor ({\lambda_{\DeltaV}})')
zlabel('{\DeltaV} (m/sec)')
colorbar


figure('Position',[300 300 900 800])
surfc(costGrid',lamGrid',tasksScheduled)
shading interp
colormap jet
title('Nunber of Tasks Scheduled by Weight and Scale Factor')
xlabel('Weight Factor (w_{\DeltaV})')
ylabel('Scale Factor ({\lambda_{\DeltaV}})')
zlabel('Number of Tasks Scheduled')
colorbar

% Illustrate in STK
%root = display_CBBA_RSO(agents,tasks,JD_epoch, simYears);



