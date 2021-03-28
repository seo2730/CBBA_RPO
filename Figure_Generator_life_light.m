
lifeMult = 100;
lambdas = -10:2:-4;
lifeLeft = 0:0.005:1;


%figure('Renderer', 'painters', 'Position', [100 300 900 700]); 
figure('Position',[300 300 700 600])
hold on;
for iLam = 1:length(lambdas)
    lifeDat(:,iLam) = lifeMult * exp(lambdas(iLam) .* lifeLeft);
    plot(lifeLeft,lifeDat(:,iLam),'DisplayName',sprintf('\x03bb_{life} = %+d',lambdas(iLam)))
end
lgd1 = legend;
lgd1.FontSize = 13;
%figure; plot(lifeLeft,lifeDat)
grid on;
xlabel('Life Remaining','FontSize',14)
ylabel('Lifetime Score','FontSize',14)
title('Remaining Life Score Functions','FontSize',15)



%fprintf('\x03bb %g\t', 10)
betaLambda = -10:2:-4;
betaPref = 20;
betaReal = -90:1:90;
lightMult = 100;



%figure('Renderer', 'painters', 'Position', [100 300 900 700]);  
figure('Position',[300 300 700 600])
hold on;

for iLight = 1:length(betaLambda)
    lightScore(:,iLight) = lightMult * exp(betaLambda(iLight) * ( abs(betaPref - betaReal)) / 180);
    plot(betaReal,lightScore(:,iLight),'DisplayName',sprintf('\x03bb_{light} = %+d',betaLambda(iLight)))
end

legend
lgd2 = legend;
lgd2.FontSize = 13;
xlim([-90,90])
grid on;
xlabel('Beta Angle (deg)','FontSize',13)
ylabel('Lighting Score','FontSize',13)
title('Lighting Score Functions','FontSize',14)


%% Delta V cost function

%dvMultiplier
lambdaDV = -10:2:-4;
remainingDV = [0:0.05:1];
dvMultiplier = 100;

%penalty = dvMultiplier * exp(lambdaDV * remainingDV)
numDvLams = length(lambdaDV);

figure('Position',[300 300 700 600])
hold on;

for idV = 1:numDvLams
    penaltyVal(:,idV) = dvMultiplier * exp(lambdaDV(idV) * remainingDV);
    %lightScore(:,idV) = lightMult * exp(betaLambda(idV) * ( abs(betaPref - betaReal)) / 180);
    plot(remainingDV,penaltyVal(:,idV),'DisplayName',sprintf('\x03bb_\x0394_V = %+d',lambdaDV(idV)))
    
%     plot(remainingDV,penaltyVal(:,idV))
%     legendCell{idV,1} = {['\lambda_{\DeltaV} =' num2str(lambdaDV(idV))]};
%     
%     legend_cell{idV,1}=num2str(cell2mat(legendCell{idV,1}));
end

%legend(legend_cell{1:numDvLams});

legend
lgd2 = legend;
lgd2.FontSize = 13;
xlim([0,1])
grid on;
xlabel('Remaining \DeltaV Capacity (f_{\DeltaV})','FontSize',13)
ylabel('\DeltaV Cost','FontSize',13)
title('\DeltaV Cost Functions','FontSize',14)
























