%% Leafia and Nhia

% Instructions: Follow through this code step by step, while also referring
% to the overall instructions and questions from the lab assignment sheet.
% Everywhere you see "% -->" is a place where you will need to write in
% your own line of code to accomplish the next task.

%% Read in the file for your station as a data table
filename = '936150.csv'; %change this to select a different station
stationdata = readtable(filename);

%% Investigate the data you are working with
%Click in the workspace to open up the new table named stationdata. You
%should be able to see headers for each column in the table.

%Open up the original csv file (Excel is a good way to do this) to see how
%the imported headers match those in the original file.

%You should also be able to see the latitude and longitude of the original
%station in the csv file. Add these below:

stationlat = -42.72; %uncomment to run this line of code after adding the station latitude
stationlon = 170.98; %uncomment to run this line of code after adding the station longitude

%% Plot the data from a single month
% Make a plot for all data from a single month with year on the x-axis and
% temperature on the y-axis. You will want this plot to have individual
% point markers rather than a line connecting each data point.

% --> 
figure(1); clf
plot(stationdata.Year,stationdata.Jan,'b*')
title('January Data', 'FontSize', 20)
xlabel('Year','FontSize',18)
ylabel('Temperature','FontSize',18)

% Calculate the monthly mean, minimum, maximum, and standard deviation
% note: some of these values will come out as NaN is you use the regular
% mean and std functions --> can you tell why? use the functions nanmean
% and nanstd to avoid this issue.

monthMean = nanmean(stationdata.Jan);
monthStd = nanstd(stationdata.Jan);
monthMin = min(stationdata.Jan);
monthMax = max(stationdata.Jan);

%% Calculate the annual climatology
% Extract the monthly temperature data from the table and store it in an
% array, using the function table2array
tempData = table2array(stationdata(:,4:15));

%Calculate the mean, standard deviation, minimum, and maximum temperature
%for every month. This will be similar to what you did above for a single
%month, but now applied over all months simultaneously.
tempMean = nanmean(tempData); 
tempStd = nanstd(tempData);
tempMin = min(tempData);
tempMax = max(tempData);

%Use the plotting function "errorbar" to plot the monthly climatology with
%error bars representing the standard deviation. Add a title and axis
%labels. Use the commands "axis", "xlim", and/or "ylim" if you want to
%change from the automatic x or y axis limits.

figure(2); clf
errorbar(tempMean,tempStd)
xlim([0 13])
ylim([0 18])
title('Monthly Climatology', 'FontSize', 20)
xlabel('Month','FontSize',18)
ylabel('Average Monthly Temperature','FontSize',18) 
% --> (note that this may take multiple lines of code)

%% Fill missing values with the monthly climatological value
% Find all values of NaN in tempData and replace them with the
% corresponding climatological mean value calculated above.

% We can do this by looping over each month in the year:
for i = 1:12
    %use the find and isnan functions to find the index location in the
    %array of data points with NaN values
    indnan = find(isnan(tempData(:,i)) == 1); %check to make sure you understand what is happening in this line
    %now fill the corresponding values with the climatological mean
     tempData(indnan,i) = tempMean(i);

end

%% Calculate the annual mean temperature for each year
% AnMean = mean(tempData); %this is just each month's mean

AnnualMean = mean(tempData,2); %mean(matrix, dimension), if dimension is 2 then mean across a row instead of column


%% Calculate the temperature anomaly for each year, compared to the 1981-2000 mean
% The anomaly is the difference from the mean over some baseline period. In
% this case, we will pick the baseline period as 1981-2000 for consistency
% across each station (though note that this is a choice we are making, and
% that different temperature analysese often pick different baselines!)


%Calculate the annual mean temperature over the period from 1981-2000
  %Use the find function to find rows contain data where stationdata.Year is between 1981 and 2000
indTemp = find(stationdata.Year>1980 & stationdata.Year<2001); %I created a variable here b/c I thought it would make it easier 
% to access if the information is needed again

Period = AnnualMean(indTemp,:);
  
  %Now calculate the mean over the full time period from 1981-2000
Mean_Period = mean(Period);

  
%Calculate the annual mean temperature anomaly as the annual mean
%temperature for each year minus the baseline mean temperature
% -->

anMeanTempAnomaly = AnnualMean - Mean_Period;

%% Plot the annual temperature anomaly over the full observational record
figure(3); clf; hold on;
%Make a scatter plot with year on the x axis and the annual mean
%temperature anomaly on the y axis
a1 = scatter(stationdata.Year,anMeanTempAnomaly,'filled'); M1 = 'Annual Temperature Anomaly';
title('Annual Temperature Anomaly', 'FontSize', 20)
xlabel('Year','FontSize',18)
ylabel('Annual Temperature Anomaly','FontSize',18)
% ylim([-4 4])

%% Smooth the data by taking a 5-year running mean of the data to plot
%This will even out some of the variability you observe in the scatter
%plot. There are many methods for filtering data, but this is one of the
%most straightforward - use the function movmean for this.
smoothAnMeanTempAnomaly = movmean(anMeanTempAnomaly,5);

%Now add a line with this smoothed data to the scatter plot

a2 = plot(stationdata.Year,smoothAnMeanTempAnomaly, 'LineWidth', 1.5); M2 = '5 year Running Mean';


%% Add and plot linear trends for whole time period, and for 1960 to today
%Here we will use the function polyfit to calculate a linear fit to the data
%For more information, type "help polyfit" in the command window and/or
%read the documentation at https://www.mathworks.com/help/matlab/data_analysis/linear-regression.html
    %use polyfit to calculate the slope and intercept of a best fit line
    %over the entire observational period
% --> 
p1 = polyfit(stationdata.Year,anMeanTempAnomaly,1);

    %also calculate the slope and intercept of a best fit line just from
    %1960 to the end of the observational period
    % Hint: start by finding the index for where 1960 is in the list of
    % years
% --> 
ind1960 = find(stationdata.Year >= 1960);
Period2 = anMeanTempAnomaly(ind1960,:);
Years = stationdata.Year;
p2 = polyfit(Years(ind1960,:), Period2,1);

%Add lines for each of these linear trends on the annual temperature
%anomaly plot (you can do this either directly using the values in P_all
%and P_1960on, or using the polyval function). Plot each new line in a
%different color.
% -->
f1 = polyval(p1,stationdata.Year);
a3 = plot(stationdata.Year,f1,'m-')
f2 = polyval(p2, Years(ind1960,:));
a4 = plot(Years(ind1960,:),f2,'c-','LineWidth',2)

%% Add a legend, axis labels, and a title to your temperature anomaly plot
% --> 
legend([a1;a2;a3;a4], M1,M2, 'Linear Trend', 'Linear Trend from 1960 on')
