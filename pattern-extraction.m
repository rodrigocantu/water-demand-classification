clear all;
clc;
for i=1:4
    % Load the datasets
%     wadept = ["Scottsdale"];
    wadept = ["Denver","Fort Collins","Scottsdale","San Antonio"];
    % Defining the parent directory for the regional demand
    myDir = 'C:\Users\rodcan\Documents\Proyecto de Investigacion\UC Davis\Indoor Water Disaggregation Data\mining\resources\Algorithms\pattern extraction\Global Vector Columns\Indoors\Daily\'+wadept(i); %gets directory
    myFiles = dir(fullfile(myDir,'*.csv')); %gets all .csv files in struct
    mat = [];
    figure
    for k = 1:length(myFiles)
        baseFileName = myFiles(k).name;
        fullFileName = fullfile(myDir, baseFileName);
        fprintf(1, 'Now reading %s\n', fullFileName);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        df = readmatrix(fullFileName);
        y = df;
        % Generating the independent variable (Hours/Month)
        x = (1:length(y))';
        % Fourier Series Approximation
        [f,gof] = fit(x,y,'smoothingspline','SmoothingParam',0.95');
        % Plotting
        figure
        plot(f,x,y)
        ax = gca;
        hold on 
        title(wadept(i),'FontSize',15,'FontWeight','bold','Color','k')
        xlabel('Hour','FontSize',15) 
        ylabel('Demand (Gal/h)','FontSize',15) 
        legend('Data','Fitted Curve','FontSize',10,'Location','Best')
        hold off
        %exportgraphics(ax,'C:\Users\rodcan\Documents\Proyecto de Investigacion\UC Davis\Indoor Water Disaggregation Data\mining\resources\Algorithms\pattern extraction\Global Vector Columns\Outdoors\results\plots\'+wadept(i)+'\'+wadept(i)+k+'.png','Resolution',300)
        for j = 1:length(y)
            mat(j,k)=f(j);
        end
    end
%     avg = trimmean(mat,2,10);
    avg = mean(mat,2);
    [f,gof] = fit(x,avg,'sin8');
    plot(f,x,avg)
    ax = gca;
    hold on 
    title(wadept(i),'FontSize',15,'FontWeight','bold','Color','k')
    xlabel('Hour','FontSize',15) 
    ylabel('Demand (Gal/h)','FontSize',15) 
    legend('Data','Fitted Curve','FontSize',10,'Location','Best')
    hold off
%     exportgraphics(ax,'C:\Users\rodcan\Documents\Proyecto de Investigacion\UC Davis\Indoor Water Disaggregation Data\mining\resources\Algorithms\pattern extraction\Global Vector Columns\Indoors\results\plots\'+wadept(i)+'\'+wadept(i)+'-GLOBAL'+'.png','Resolution',300)
%     writematrix(mat,'C:\Users\rodcan\Documents\Proyecto de Investigacion\UC Davis\Indoor Water Disaggregation Data\mining\resources\Algorithms\pattern extraction\Global Vector Columns\Indoors\results\'+wadept(i)+'.csv');
end