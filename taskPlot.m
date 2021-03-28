figure('Position',  [500, 500, 1000, 600])

hold on

xlim([0 simDurWks])
ylim([0 16])
grid on
v = 0.5;
for i = 1:numRSOs
    a = tasks(i).start;
    b  = tasks(i).end;
    patch([a b b a],[v v v+1 v+1],'k','facealpha',0.2,'linestyle','none')
    v = v+1;
end

for i = 1:3
    path = CBBA_Assignments(i).path;
    path = path(path>0);
    n = length(path);
    linex = [];
    liney = [];
    for j = 1:n
        start = CBBA_Assignments(i).times(j);
        rso = CBBA_Assignments(i).path(j);
        dur = tasks(rso).duration;
        a = start;
        b = start+dur;
        c = get(groot,'DefaultAxesColorOrder');
        c = c(i,:);
        p = 0.35;
        patch([a b b a],[rso-p rso-p rso+p rso+p],c)
        linex = [linex a b];
        liney = [liney rso rso];
        if j > 1
            plot(linex(end-2:end-1),liney(end-2:end-1),'--','color',c,'linewidth',1.5)
        end
    end
end

xlabel('Weeks','FontSize',14)
ylabel('RSO','FontSize',14)
title('Agent Schedules','FontSize',16)
    