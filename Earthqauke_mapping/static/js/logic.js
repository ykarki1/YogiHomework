// Earthquake data link 
var EarthquakeLink = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.geojson"

// Perform a GET request to the Earthquake query URL 
d3.json(EarthquakeLink, function(data){
    //Once we get the response, send the daata.features object to the createFeatures function
    createFeatures(data.features);
});

function createFeatures(earthquakeData) {
   // Create a GeoJSON layer containing the features array on the earthquakeData object
   // Run the onEachFeature function once for each peice of data in the array 
   var earthquakes = L.geoJson(earthquakeData, {
       onEachFeature: function (feature,layer){
           layer.bindPopup("<h3>"+ feature.properties.place+ "<br> Magnitude: "+ feature.properties.mag +
           "</h3><hr><p>" + new Date(feature.properties.time)+ "</p>");
       },
    pointToLayer: function(feature, latLng){
        return new L.circle(latLng,
            {radius: getRadius(feature.properties.mag),
            fillColor: getColor(feature.properties.mag),
            fillOpacity: .7,
            color: "black",
            weight: .5
        })
    }
   });
   
   //Sending our earthquakes layer to the createMap function
   createMap(earthquakes)
}

function createMap(earthquakes) {
   // Define streetmap and darkmap layers
   var streetmap = L.tileLayer("https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}", {
    attribution: "Map data &copy; <a href=\"https://www.openstreetmap.org/\">OpenStreetMap</a> contributors, <a href=\"https://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"https://www.mapbox.com/\">Mapbox</a>",
    maxZoom: 18,
    id: "mapbox.streets",
    accessToken: API_KEY
  });

  var darkmap = L.tileLayer("https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}", {
    attribution: "Map data &copy; <a href=\"https://www.openstreetmap.org/\">OpenStreetMap</a> contributors, <a href=\"https://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"https://www.mapbox.com/\">Mapbox</a>",
    maxZoom: 18,
    id: "mapbox.dark",
    accessToken: API_KEY
  });

  // Define a baseMaps object to hold our base layers
  var baseMaps = {
    "Street Map": streetmap,
    "Dark Map": darkmap
  };  

  // Create overlay object to hold our overlay layer
  var overlayMaps = {
    Earthquakes: earthquakes
  };
// Create our map, giving it the streetmap and earthquakes layers to display on load
var myMap = L.map("map", {
    center: [31.7, -7.09],
    zoom: 2.5,
    layers: [streetmap, earthquakes]
  });
    // Create a layer control
  // Pass in our baseMaps and overlayMaps
  // Add the layer control to the map
  L.control.layers(baseMaps, overlayMaps, {
    collapsed: false
  }).addTo(myMap);

  // Create legend
  var legend = L.control({position: 'bottomright'});

  legend.onAdd = function (myMap) {

    var div = L.DomUtil.create('div', 'info legend'),
              grades = [0, 1, 2, 3, 4, 5],
              labels = [];
   // loop through our density intervals and generate a label with a colored square for each interval
   for (var i = 0; i < grades.length; i++) {
    div.innerHTML +=
        '<i style="background:' + getColor(grades[i] + 1) + '"></i> ' +
        grades[i] + (grades[i + 1] ? '&ndash;' + grades[i + 1] + '<br>' : '+');
}
return div;
};

legend.addTo(myMap);
}             
function getColor(d) {
    return d > 5 ? '#F30' :
    d > 4  ? '#F60' :
    d > 3  ? '#F90' :
    d > 2  ? '#FC0' :
    d > 1  ? '#FF0' :
              '#9F3';
  }
  
  function getRadius(value){
    return value*40000
  }