

load('Agents_RPO_tasks.mat')

rEarth = 6378; %km
numAgents = length(agents);
numRSOs   = length(tasks);
numWeeks  = 50;
wkVect = 1:numWeeks;

JD0 = JD_epoch;
JD = JD0;
Ag = struct('dv',{},'sma',{});
for iAgent = 1:numAgents
    Agent = agents(iAgent);
    
    for jRSO = 1:numRSOs
        RSO = tasks(jRSO);
        
        Output = RendezvousFunc_weeks_updated(Agent,RSO,JD,JD0,numWeeks);
        
        Ag(iAgent).dv(jRSO,:) = 1000*Output.RSO.deltaV;
        Ag(iAgent).astar(jRSO,:) = Output.RSO.a_star - rEarth;
    end
end


% ----------------Delta-V Figure
figure('Position',  [500, 500, 800, 500])
subplot(3,1,1); plot(wkVect,Ag(1).dv(1:numRSOs,:))
ylim([0,1000])
grid on
text(40,700,'Agent 1','FontSize',12)
%ylabel('Agent 1'); % \DeltaV (m/s)')
subplot(3,1,2); plot(wkVect,Ag(2).dv(1:numRSOs,:))
ylim([0,1000])
grid on
text(40,700,'Agent 2','FontSize',12)
%ylabel('Agent 2'); % \DeltaV (m/s)')
%ylabel('\DeltaV (m/s)','FontSize',15)

subplot(3,1,3); plot(wkVect,Ag(3).dv(1:numRSOs,:))
ylim([0,1000])
grid on
text(40,700,'Agent 3','FontSize',12)
%ylabel('Agent 3'); % \DeltaV (m/s)')
xlabel('Week')
[ax1,h1]=suplabel('\DeltaV (m/s)','y');
[ax4,h3]=suplabel('Agent \DeltaV for RSO Servicing Operations'  ,'t');

% ----------------a* Figure
figure('Position',  [500, 500, 800, 500])
subplot(3,1,1); plot(wkVect,Ag(1).astar(1:numRSOs,:))
hold on; plot([0,wkVect],300*ones(length(wkVect)+1),'--r')
ylim([0,2000])
grid on
text(40,1500,'Agent 1','FontSize',12)
text(23,425,'Drag Limit','Color','red','FontSize',12)

subplot(3,1,2); plot(wkVect,Ag(2).astar(1:numRSOs,:))
hold on; plot([0,wkVect],300*ones(length(wkVect)+1),'--r')
ylim([0,2000])
grid on
text(40,1500,'Agent 2','FontSize',12)
text(23,425,'Drag Limit','Color','red','FontSize',12)

subplot(3,1,3); plot(wkVect,Ag(3).astar(1:numRSOs,:))
hold on; plot([0,wkVect],300*ones(length(wkVect)+1),'--r')
ylim([0,2000])
grid on
text(40,1500,'Agent 3','FontSize',12)
text(23,425,'Drag Limit','Color','red','FontSize',12)
%ylabel('Agent 3'); % \DeltaV (m/s)')
xlabel('Week')
[ax1,h1]=suplabel('a* (km)','y');
[ax4,h3]=suplabel('Agent Transfer Altitudes (a*) for RSO Servicing Operations'  ,'t');
    

% subplot(3,2,2); plot(wkVect,Ag(1).sma(1:numRSOs,:))
% grid on
% text(40,1E4,'Agent 1','FontSize',12)
% %ylabel('Agent 1 a* (km)')
% subplot(3,2,4); plot(wkVect,Ag(2).sma(1:numRSOs,:))
% grid on
% text(40,1E4,'Agent 2','FontSize',12)
% ylabel('<-- a* (km) -->','FontSize',15)
% subplot(3,2,6); plot(wkVect,Ag(3).sma(1:numRSOs,:))
% grid on
% text(40,1E4,'Agent 3','FontSize',12)
% %ylabel('Agent 3 a* (km)')
% xlabel('Week')
% 
% %[ax1,h1]=suplabel('a* (km)','y');
% 
% [ax4,h3]=suplabel('Agent \DeltaV and a* for RSOs'  ,'t');
% set(h3,'FontSize',18)
% 
% %%%%%%%%%%%%%%%%%%%%%%%%
% figure('Position',[300 300 900 800])
% subplot(3,1,1); plot(wkVect,Ag(1).dv(1:numRSOs,:))
% %ylim([0,1000])
% grid on
% text(40,2000,'Agent 1','FontSize',12)
% %ylabel('Agent 1'); % \DeltaV (m/s)')
% subplot(3,1,2); plot(wkVect,Ag(2).dv(1:numRSOs,:))
% %ylim([0,1000])
% grid on
% text(40,2000,'Agent 2','FontSize',12)
% %ylabel('Agent 2'); % \DeltaV (m/s)')
% %ylabel('<--- \DeltaV (m/s) --->','FontSize',15)
% 
% subplot(3,1,3); plot(wkVect,Ag(3).dv(1:numRSOs,:))
% %ylim([0,1000])
% grid on
% text(40,2000,'Agent 3','FontSize',12)
% %ylabel('Agent 3'); % \DeltaV (m/s)')
% xlabel('Week','FontSize',15)
% [ax1,h1]=suplabel('\DeltaV (m/s)','y');
% 
% [ax1,h1]=suplabel('a* (km)','y');
% 















