%% JCDstatusPlot
%  How to read and use data from Xively IoT API
%  Copyright (C) 2014  Jorge Garcia Tiscar
% 
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation; either version 3 of the License, or
%  (at your option) any later version (see LICENSE).

%% Initialize
clc
close all
clear all
addpath Auxiliary % Put all required files here

%% Get data
load       ./Auxiliary/apiKey
contract = 'Valence';
url      = 'https://api.jcdecaux.com/vls/v1/stations';
rawData  = urlread([url '?contract=' contract '&apiKey=' apiKey ]);

% Parse JSON
% mathworks.es/matlabcentral/fileexchange/33381-jsonlab
% --a-toolbox-to-encode-decode-json-files-in-matlab-octave
stations = cell2mat(loadjson(rawData));

%%  Compute stats
fullSt       = sum([stations(:).available_bike_stands] == 0);
emptySt      = sum([stations(:).available_bikes] == 0);
availBikes   = sum([stations(:).available_bikes]);
availStands  = sum([stations(:).available_bike_stands]);
totalStands  = sum([stations(:).bike_stands]);

%  Percentages
fullStP      = round(fullSt  / length(stations) *100);
emptyStP     = round(emptySt / length(stations) *100);
availBikesP  = round(availBikes  / totalStands *100);
availStandsP = round(availStands / totalStands *100);

%  Most populated station
[~,sortSt]   = sort([stations(:).available_bikes],'descend');
mostPopSt    = stations(sortSt(1)).address;

%%  Compute last update on local time
updateTimes  = [stations(:).last_update];
%  Diference between POSIX time and local time
dif          = now - (java.lang.System.currentTimeMillis ...
                     / (1000*60*60*24) + datenum('1970','yyyy'));
%  Add the difference and convert to datenums
localVect    = updateTimes ./ (1000*60*60*24) + datenum('1970','yyyy') + dif;
%  Take the average time
lastUpdate   = mean(localVect);

%% Plot
%  Options
locations    = [stations(:).position];
lat          = [locations(:).lat];
long         = [locations(:).lng];
sizes        = 1.8.*([stations(:).available_bikes]+13);
colors       = [stations(:).available_bikes] ./ [stations(:).bike_stands];
voronoiColor = [22 105 122]./255;
textColor    = [186 216 228]./255;
longLims     = [min(long)-0.005 max(long)+0.005];
latLims      = [min(lat)-0.0005 max(lat)+0.0005];

%  Prepare figure
figure('DefaultTextFontName', 'Myriad Pro', ...
    'DefaultTextFontSize', 5.5,...
    'DefaultTextColor', textColor,...
    'DefaultTextHorizontalAlignment', 'right',...
    'DefaultTextUnits','normalized')
hold on

% Plot Voronoi diagram
[x,y] = voronoi(long,lat);
plot(x,y,'-','Color',voronoiColor)

%  Plot stations
scatter(long,lat,sizes,colors,'fill')

%  Style figure
set(gcf, 'Position', [0, 0, 700, 500]);
set(gcf, 'Color', 'w');
xlim(longLims)
ylim(latLims)
axis off

%  Add stats
text(0.01,0.01,{
    ['Full stations: ' num2str(fullSt) ' (' num2str(fullStP) '%)']
    ['Empty stations: ' num2str(emptySt) ' (' num2str(emptyStP) '%)']
    ['Available bikes: ' num2str(availBikes) ' (' num2str(availBikesP) '%)']
    ['Available stands: ' num2str(availStands) ' (' num2str(availStandsP) '%)']
    % ['Most populated: ' mostPopSt]
    'CC-BY 2.0 @JorgeGT - Data from developer.jcdecaux.com'
    },'HorizontalAlignment','left','VerticalAlignment','bottom') %#ok<*UNRCH>

%  Add title
text(0.99,1,[contract ' Bike Network'],'FontSize',12,'VerticalAlignment','top')

%  Add subtitles
text(0.99,0.91,{
    'Size: available bikes / Color: occupation'
    datestr(lastUpdate,'dd/mm/yy HH:MM')
    },'HorizontalAlignment','right','FontSize',6)

%  Add Google map
%  http://www.mathworks.es/matlabcentral/fileexchange/27627-plot-google-map
%  You can customize the map look adding a style parameter to the URL
%  https://developers.google.com/maps/documentation/staticmaps/?csw=1#StyledMaps
plot_google_map('showlabels',0)

%  Export figure
%  https://github.com/ojwoodford/export_fig
export_fig(['JCDstatus_' contract],'-png','-zbuffer','-a3','-m2')

%  Close all
close all
