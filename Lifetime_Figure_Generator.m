
lifeMult = 100;
lambdas = -10:2:-4;
lifeLeft = 0:0.05:1;


figure; hold on;
for iLam = 1:length(lambdas)
    lifeDat(:,iLam) = lifeMult * exp(lambdas(iLam) .* lifeLeft);
    plot(lifeLeft,lifeDat(:,iLam),'DisplayName',sprintf('\x03bb = %+d',lambdas(iLam)))
end
legend
%figure; plot(lifeLeft,lifeDat)
grid on;
xlabel('Life Remaining')
ylabel('Lifetime Score Value')
title('Lifetime Scoring Functions')



%fprintf('\x03bb %g\t', 10)