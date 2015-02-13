JCDstatusPlot
==========

An example of how to access [JCDecaux Open Data API](https://developer.jcdecaux.com/#/opendata/vls?page=getstarted) from MATLAB. They offer real time status updates of their public bike services around the world, a very valuable information if one wishes to gain insight of city dynamics, transportation necessities, etc.

### Requirements  
Assuming that you have read the API docs and got a key with real-time data reading permissions, you need to save it in a matfile like this:

```matlab
apiKey = 'YOUR_KEY_HERE';
save('apiKey.mat','apiKey');
```

The script can work as standalone, but I've used two libraries from the MathWorks Matlab Central which you can either download (their URLs are included in the source) or disable.

> Tip: Browse Oliver O'Brien's [Bike Share Map](http://bikes.oobrien.com/global.php) for an example of a net web application built upon this data!

### Example result

This example script gets the status of the municipal bike service of the city of Valencia and plots a simple visualization of it, conveying the number of bikes available on each station, their ocupation rate, and some simple statistics. Also, a Voronoi diagram is plotted on top of it, showing the "cells" that each stations should, in theory, cover.

<p align="center">
    <img src="http://i.imgur.com/YFsOXMB.png" alt="Results"
    width="70%" height="70%" />
</p>



### Further examples

#### Global status

As all covered cities are also accesible through the API, it's easy to loop through all of them in order to build a global visualization of the service status. You could use a code like this:

```matlab
url       = 'https://api.jcdecaux.com/vls/v1/contracts';
rawData   = urlread([url '?apiKey=' apiKey]);
contracts = cell2mat(loadjson(rawData));

for i = 1:length(contracts)
    try
    % Make the script a function and comment out
    % the contract name, passing it as an argument 
    JCDstatusPlot_function(contracts(i).name)
    catch error
        disp(error)
    end
end
```

This should allow you to build a global snapshop like this one:

<p align="center">
    <img src="http://i.imgur.com/9ENp0jll.jpg" alt="Results"
    width="70%" height="70%" />
</p>

#### Animation
Another interesting option is to save a snapshot of the status of a contract every few minutes and then loop through the images in order to create an animation displaying the "flow" of people across the city. In this example, you can see people flocking to the city center and the northwest university campuses at around 8h-9h, going to the beach at around 16h, etc.

<p align="center">
   <iframe width="420" height="315" src="https://www.youtube.com/embed/fOYGDHCDFm0" frameborder="0" allowfullscreen></iframe>
</p>

### Licensing
This script is licensed under GPL v3.
