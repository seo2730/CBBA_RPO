% Copyright 2010
% Massachusetts Institute of Technology
% All rights reserved
% Developed by the Aerospace Controls Lab, MIT

%---------------------------------------------------------------------%
%---------------------------------------------------------------------%
% Plots CBBA outputs
%---------------------------------------------------------------------%

function fig = PlotAssignments_RPO_Corrected(CBBA_Params,CBBA_Assignments, agents, tasks, simDurWks, pathFlag)

%---------------------------------------------------------------------%
% Set plotting parameters

set(0, 'DefaultAxesFontSize', 12)
set(0, 'DefaultTextFontSize', 10, 'DefaultTextFontWeight','demi')
set(0,'DefaultAxesFontName','arial')
set(0,'DefaultTextFontName','arial')
set(0,'DefaultLineLineWidth',2); % < == very important
set(0,'DefaultlineMarkerSize',10)

% %---------------------------------------------------------------------%
% % Plot agent and task positions vs. time
% 
offset = 0.01; 
%fig    = figure(figureID);
figure('Renderer', 'painters', 'Position', [100 300 900 700]); 
Cmap   = colormap('lines');

% Plot tasks @ start
for m=1:length(tasks)

    plot3(tasks(m).INCL , tasks(m).RAAN , 0 ,'x','Color', [100, 100, 100] / 255,'LineWidth',3);
    hold on;
 
end

% Plot agents
for n=1:length(agents)
    plot3(agents(n).INCL, agents(n).RAAN, 0,'o','color',Cmap(agents(n).id,:));
    text(agents(n).INCL+offset, agents(n).RAAN+offset, 0.1, ['Agent ' num2str(n)],'color',Cmap(agents(n).id,:),'FontSize',14);

    % Check if path has something in it
    if( CBBA_Assignments(n).path(1) > -1 )
        taskPrev = lookupTask(tasks, CBBA_Assignments(n).path(1));
        
        visitTime = CBBA_Assignments(n).times(1);
        
        Output = RendezvousFunc_weeks_updated(agents(n),taskPrev,CBBA_Params.JD,CBBA_Params.JD,CBBA_Params.num_weeks);
        
        newRAAN = Output.RSO.RAAN(visitTime);
        newIncl = Output.RSO.INCL(visitTime);
        
        plot3(newIncl + [0 0], newRAAN + [0 0], [visitTime visitTime+taskPrev.duration],'x:','color','k','LineWidth',3);
        plot3([taskPrev.INCL, newIncl] , [taskPrev.RAAN,newRAAN] , [0,visitTime] ,':','Color',[100, 100, 100] / 255,'LineWidth',1);
        text(newIncl  +offset, newRAAN +offset, visitTime, ['RSO' num2str(taskPrev.id)]);
        
        if pathFlag
            plot3([agents(n).INCL,newIncl], [agents(n).RAAN,newRAAN], [0,visitTime],'-','color',Cmap(agents(n).id,:));
            plot3(newIncl, newRAAN, visitTime,'^','color',Cmap(agents(n).id,:));
        end
        % Now set taskPrev for follow on tasks
        taskPrev.INCL = newIncl;
        taskPrev.RAAN = newRAAN;
        
        for m = 2:length(CBBA_Assignments(n).path)
            if( CBBA_Assignments(n).path(m) > -1 )
                
                nextTask = lookupTask(tasks, CBBA_Assignments(n).path(m));
                
                %nextVisitTime = CBBA_Assignments(n).times(m);
                
                
                Output = RendezvousFunc_weeks_updated(agents(n),tasks(CBBA_Assignments(n).path(m)),CBBA_Params.JD,CBBA_Params.JD,CBBA_Params.num_weeks);
                wkVal = round(CBBA_Assignments(n).times(m),0);
                
                taskNext.SMA  = Output.RSO.SMA(wkVal);
                taskNext.INCL = Output.RSO.INCL(wkVal);
                taskNext.RAAN = Output.RSO.RAAN(wkVal);
                
                taskNext.duration = nextTask.duration;
                taskNext.start = nextTask.start;
                taskNext.end = nextTask.end;
                taskNext.id  = nextTask.id;
                
                
                %taskNext.start = nextTask.start;
                tID = taskNext.id;
                
                plot3(taskNext.INCL + [0 0], taskNext.RAAN + [0 0], [taskNext.start taskNext.end],'x:','color','k','LineWidth',3);
                text(taskNext.INCL  +offset, taskNext.RAAN +offset, taskNext.start, ['RSO' num2str(tID)]);
                
                plot3([tasks(tID).INCL, taskNext.INCL] , [tasks(tID).RAAN,taskNext.RAAN] , [0,tasks(tID).start] ,':','Color',[0, 0, 0] / 255,'LineWidth',1);
                
                %%%%%%%%%%%%%%%%%
                X = [taskPrev.INCL, taskNext.INCL];
                Y = [taskPrev.RAAN, taskNext.RAAN];
                T = [CBBA_Assignments(n).times(m-1)+taskPrev.duration, CBBA_Assignments(n).times(m)];
                
                if pathFlag
                    plot3(X,Y,T,'-^','color',Cmap(agents(n).id,:));
                    plot3(X(end)+[0 0], Y(end)+[0 0], [T(2) T(2)+taskNext.duration],'-^','color',Cmap(agents(n).id,:));
                end
                %%%%%%%%%%%%%%%%%
                
                taskPrev = taskNext;
            else
                break;
            end
        end
    end
end

hold off;
title('Servicing Satellite Paths with Time Windows','FontSize',16)
xlabel('Inclination (deg)','FontSize',14);
ylabel('RAAN (deg)','FontSize',14);
zlabel('Time (weeks)','FontSize',14);
grid on

% Plot agent schedules
Cmap   = colormap('lines');
%fig = figure(figureID+1);
figure('Renderer', 'painters', 'Position', [100 300 900 700]); 
subplot(length(agents),1,1);
title(['Agent Schedules'])

for n=1:length(agents)
    subplot(length(agents),1,n);
    ylabel(['Agent ' num2str(n)])
    hold on;
    grid on;
    axis([0 simDurWks, 0 2])
    
    for m = 1:length(CBBA_Assignments(n).path)
        if (CBBA_Assignments(n).path(m) > -1)
            taskCurr = lookupTask(tasks, CBBA_Assignments(n).path(m));
            plot([CBBA_Assignments(n).times(m) CBBA_Assignments(n).times(m)+taskCurr.duration],[1 1],'-','color',Cmap(agents(n).id,:), 'Linewidth',10)
            
            if mod(m,2)==0
               t = text(CBBA_Assignments(n).times(m), 1.15, ['RSO' num2str(CBBA_Assignments(n).path(m))]);
            else
                t = text(CBBA_Assignments(n).times(m), 1-0.15, ['RSO' num2str(CBBA_Assignments(n).path(m))]);
            end
            %s = t.FontSize;
            %t.FontSize = 12;
            t.FontWeight = 'bold';
            
            plot([taskCurr.start taskCurr.end],[1 1],'--','color',Cmap(agents(n).id,:))
        else
            break;
        end
    end
end
xlabel('Time (weeks)','FontSize',14);

return

function task = lookupTask(tasks, taskID)

for m=1:length(tasks)
    if(tasks(m).id == taskID)
        task = tasks(m);
        return;
    end
end

task = [];
disp(['Task with index=' num2str(taskID) ' not found'])

return

    