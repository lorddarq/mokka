markers = [];

function renderMarkers(map, pins)
{
  var defaultBounds = new google.maps.LatLngBounds();

  for (var i = 0; i < markers.length; i++) {
    markers[i].setMap(null);
  }
  markers = [];

  var image = {
    url: $('#map').attr('data-pin-url'),
    size: new google.maps.Size(25, 35),
    origin: new google.maps.Point(0, 0),
    anchor: new google.maps.Point(25, 35)
  };

  var pinMarker;
  $.each(pins, function(index, pin)
  {
    defaultBounds.extend(new google.maps.LatLng(pin.lat, pin.lng));

    pinMarker = new google.maps.Marker({
      position: new google.maps.LatLng(pin.lat, pin.lng),
      map: map,
      icon: image
    });
//    google.maps.event.addListener(pinMarker, 'click', function(e) {
////        LevisEvents.mapStoreMarkerClicked.dispatch();
////        $.each(_mapInfoBoxes, function(infoBox)
////        {
////          infoBox.remove();
////        });
////        _mapInfoBoxes = [];
////        _mapInfoBoxes.push( new InfoBox({
////          latlng: new google.maps.LatLng(store.lat, store.lng),
////          map: map,
////          content: '<h1>' + store.name + '</h1><p>' + store.address + ', <br>' + store.location + '</p>'
////        }) );
//    });
    pinMarker.setMap(map);

    markers.push(pinMarker);
    map.fitBounds(defaultBounds);

    var listener = google.maps.event.addListener(map, "idle", function() {
      if (map.getZoom() > 16) map.setZoom(16);
      google.maps.event.removeListener(listener);
    });
  });
}

function showMap(pins)
{
  var mapOptions = {
    center: new google.maps.LatLng(55.752037, 37.5786791),
    zoom: 12,
    disableDefaultUI: true,
    mapTypeControlOptions: {
      mapTypeId: [google.maps.MapTypeId.ROADMAP, 'smap']
    }
  };
  var map = new google.maps.Map(document.getElementById('map'), mapOptions);
  var styledMapOptions = [
    {
      featureType: 'all',
      elementType: 'all',
      stylers: [
        { saturation: -100 }
      ]
    }
  ];
  var mapType = new google.maps.StyledMapType(styledMapOptions, { name: 'Grayscale' });
  map.mapTypes.set('smap', mapType);
  map.setMapTypeId('smap');

  return map;
}
