clear all;
clc;
myDir = 'C:\Users\rodcan\Documents\Proyecto de Investigacion\UC Davis\Indoor Water Disaggregation Data\mining\resources\Algorithms\pattern extraction\Global Vector Columns\Outdoors\coefficients-outdoors.csv'; %gets directory
avg_tot = readmatrix(myDir);

myDir = 'C:\Users\rodcan\Documents\Proyecto de Investigacion\UC Davis\Indoor Water Disaggregation Data\mining\resources\Algorithms\pattern extraction\Global Vector Columns\Indoors\coefficients-indoors.csv'; %gets directory
avg = readmatrix(myDir);
coef = [];

wadept = ["Denver","Fort Collins","Scottsdale","San Antonio"];

diff_matrix = [];

for i=1:4
    
    x = (1:length(avg_tot(:,i)))';
    [f_tot,gof_tot] = fit(x, avg_tot(:,i),'sin8');
    tot = [5704.29, 215850.44, 195848.95, 126167.94];
    num_tot = f_tot(x)*tot(i);
    
    sum(f_tot(x));
    
    x = (1:length(avg(:,i)))';
    [f,gof] = fit(x, avg(:,i),'sin8');
    indoors = [2700.57, 46469.89, 32440.78, 41626.32];
    num = f(x)*indoors(i);
    
    sum(f(x));
    
    outdoors = [3003.29, 169380.61, 163408.33, 84541.67];
    diff = (num_tot-num)/outdoors(i);
    [f_diff,gof_diff] = fit(x, diff,'sin8');
    coef = horzcat(coef,coeffvalues(f_diff)');
    
    writematrix(coef,'C:\Users\rodcan\Documents\Proyecto de Investigacion\UC Davis\Indoor Water Disaggregation Data\mining\resources\Algorithms\pattern extraction\Global Vector Columns\Outdoors\results\coef_Outdoor-Diff.csv');
    
    diff_matrix = horzcat(diff_matrix,diff);
    
    sum(diff);
    
    figure;
    plot(x,diff);
    ay = gca;
    title(wadept(i),'FontSize',15,'FontWeight','bold','Color','k')
    xlabel('Hour','FontSize',15) 
    ylabel('Normalized Demand','FontSize',15) 
    legend('Outdoor Pattern','FontSize',10,'Location','Best')
    hold on
    n = 1;
    p = indoors(i)/tot(i)
    q = outdoors(i)/tot(i)
    plot(x,q*diff)
    plot(x,p*(f(x)))
    plot(x,n*(f_tot(x)))
    ax = gca;
    title(wadept(i),'FontSize',15,'FontWeight','bold','Color','k')
    xlabel('Hour','FontSize',15) 
    ylabel('Normalized Demand','FontSize',15) 
    legend('Outdoor','Indoor', 'Total','FontSize',10,'Location','Best')
    hold off
%     exportgraphics(ax,'C:\Users\rodcan\Documents\Proyecto de Investigacion\UC Davis\Indoor Water Disaggregation Data\mining\resources\Algorithms\pattern extraction\Global Vector Columns\Outdoors\results\plots\'+wadept(i)+'-ALL Patterns'+'.png','Resolution',300)
end

%     writematrix(diff_matrix,'C:\Users\rodcan\Documents\Proyecto de
%     Investigacion\UC Davis\Indoor Water Disaggregation
%     Data\mining\resources\Algorithms\pattern extraction\Global Vector Columns\Outdoors\results\Outdoor-Diff.csv');