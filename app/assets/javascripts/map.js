markers = [];
_mapInfoBoxes = [];

function renderMarkers(map, pins)
{
  var defaultBounds = new google.maps.LatLngBounds();

  for (var i = 0; i < markers.length; i++) {
    markers[i].setMap(null);
  }
  markers = [];

  if(appMode == 'tablet')
  {
    var image = {
      url: $('#map').attr('data-pin-url'),
      size: new google.maps.Size(69, 97),
      origin: new google.maps.Point(0, 0),
      anchor: new google.maps.Point(69, 97)
    };
  }
  else
  {
    var image = {
      url: $('#map').attr('data-pin-url'),
      size: new google.maps.Size(28, 42),
      origin: new google.maps.Point(0, 0),
      anchor: new google.maps.Point(28, 42)
    };
  }


  var pinMarker;
  $.each(pins, function(index, pin)
  {
    defaultBounds.extend(new google.maps.LatLng(pin.lat, pin.lng));

    pinMarker = new google.maps.Marker({
      position: new google.maps.LatLng(pin.lat, pin.lng),
      map: map,
      icon: image
    });

    google.maps.event.addListener(pinMarker, 'mouseover', function(e) {

      $.each(_mapInfoBoxes, function(index, infoBox)
      {
        infoBox.setMap(null);
        infoBox.remove();
      });
      _mapInfoBoxes = [];
      if(appMode == 'tablet')
      {
        var opts = {
          latlng: new google.maps.LatLng(pin.lat, pin.lng),
          map: map,
          content: '<div class="yel">' + pin.time + '</div>',
          offsetVertical_: -109,
          offsetHorizontal_: -141,
          height_: 127,
          width_: 212
        };
      }
      else
      {
        var opts = {
          latlng: new google.maps.LatLng(pin.lat, pin.lng),
          map: map,
          content: '<div class="yel">' + pin.time + '</div>',
          offsetVertical_: -46,
          offsetHorizontal_: -52,
          height_: 46,
          width_: 77
        };
      }

      _mapInfoBoxes.push( new InfoBox(opts) );
    });

    google.maps.event.addListener(pinMarker, 'mouseout', function(e) {

      $.each(_mapInfoBoxes, function(index, infoBox)
      {
        infoBox.setMap(null);
        infoBox.remove();
      });
    });


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

/* An InfoBox is like an info window, but it displays
 * under the marker, opens quicker, and has flexible styling.
 * @param {GLatLng} latlng Point to place bar at
 * @param {Map} map The map on which to display this InfoBox.
 * @param {Object} opts Passes configuration options - content,
 *   offsetVertical, offsetHorizontal, className, height, width
 */
function InfoBox(opts) {
  google.maps.OverlayView.call(this);
  this.latlng_ = opts.latlng;
  this.map_ = opts.map;
  this.content_ = opts.content;
  this.offsetVertical_ = opts.offsetVertical_;
  this.offsetHorizontal_ =  opts.offsetHorizontal_;
  this.height_ = opts.height_;
  this.width_ = opts.width_;

  this.removed_ = false;

  var me = this;
  this.boundsChangedListener_ =
    google.maps.event.addListener(this.map_, "bounds_changed", function() {
      return me.panMap.apply(me);
    });

  // Once the properties of this OverlayView are initialized, set its map so
  // that we can display it.  This will trigger calls to panes_changed and
  // draw.
  this.setMap(this.map_);
}

/* InfoBox extends GOverlay class from the Google Maps API
 */
InfoBox.prototype = new google.maps.OverlayView();

/* Creates the DIV representing this InfoBox
 */
InfoBox.prototype.remove = function() {
  if (this.div_) {
    this.div_.parentNode.removeChild(this.div_);
    this.div_ = null;
  }
  this.removed_ = true;
};

/* Redraw the Bar based on the current projection and zoom level
 */
InfoBox.prototype.draw = function() {
  // Creates the element if it doesn't exist already.
  if (this.removed_) return;

  this.createElement();
  if (!this.div_) return;

  // Calculate the DIV coordinates of two opposite corners of our bounds to
  // get the size and position of our Bar
  var pixPosition = this.getProjection().fromLatLngToDivPixel(this.latlng_);
  if (!pixPosition) return;

  // Now position our DIV based on the DIV coordinates of our bounds
  this.div_.style.width = this.width_ + "px";
  this.div_.style.left = (pixPosition.x + this.offsetHorizontal_) + "px";
  this.div_.style.height = this.height_ + "px";
  this.div_.style.top = (pixPosition.y + this.offsetVertical_) + "px";
  this.div_.style.display = 'block';
};

/* Creates the DIV representing this InfoBox in the floatPane.  If the panes
 * object, retrieved by calling getPanes, is null, remove the element from the
 * DOM.  If the div exists, but its parent is not the floatPane, move the div
 * to the new pane.
 * Called from within draw.  Alternatively, this can be called specifically on
 * a panes_changed event.
 */
InfoBox.prototype.createElement = function() {
  var that = this;

  var panes = this.getPanes();
  var div = this.div_;
  if (!div) {
    // This does not handle changing panes.  You can set the map to be null and
    // then reset the map to move the div.
    var $div = $('<div />', {'class': 'map-popup', 'data-latlng': this.latlng_.lat() + ',' + this.latlng_.lng()});
    $div.append(this.content_);

//    var closeButton = document.createElement('div');
//    closeButton.className = 'map-popup-close';
//    google.maps.event.addDomListener(closeButton, 'click', removeInfoBox(this));
//    function removeInfoBox(ib) {
//      return function() {
//        ib.setMap(null);
//      };
//    }

    div = this.div_ = $div[0];
//    div.appendChild(closeButton);
    panes.floatPane.appendChild(div);
    this.panMap();
  } else if (div.parentNode != panes.floatPane) {
    // The panes have changed.  Move the div.
    div.parentNode.removeChild(div);
    panes.floatPane.appendChild(div);
  } else {
    // The panes have not changed, so no need to create or move the div.
  }
};

/* Pan the map to fit the InfoBox.
 */
InfoBox.prototype.panMap = function() {
  // if we go beyond map, pan map
  var map = this.map_;
  var bounds = map.getBounds();
  if (!bounds) return;

  // The position of the infowindow
  var position = this.latlng_;

  // The dimension of the infowindow
  var iwWidth = this.width_;
  var iwHeight = this.height_;

  // The offset position of the infowindow
  var iwOffsetX = this.offsetHorizontal_;
  var iwOffsetY = this.offsetVertical_;

  // Padding on the infowindow
  var padX = 40;
  var padY = 40;

  // The degrees per pixel
  var mapDiv = map.getDiv();
  var mapWidth = mapDiv.offsetWidth;
  var mapHeight = mapDiv.offsetHeight;
  var boundsSpan = bounds.toSpan();
  var longSpan = boundsSpan.lng();
  var latSpan = boundsSpan.lat();
  var degPixelX = longSpan / mapWidth;
  var degPixelY = latSpan / mapHeight;

  // The bounds of the map
  var mapWestLng = bounds.getSouthWest().lng();
  var mapEastLng = bounds.getNorthEast().lng();
  var mapNorthLat = bounds.getNorthEast().lat();
  var mapSouthLat = bounds.getSouthWest().lat();

  // The bounds of the infowindow
  var iwWestLng = position.lng() + (iwOffsetX - padX) * degPixelX;
  var iwEastLng = position.lng() + (iwOffsetX + iwWidth + padX) * degPixelX;
  var iwNorthLat = position.lat() - (iwOffsetY - padY) * degPixelY;
  var iwSouthLat = position.lat() - (iwOffsetY + iwHeight + padY) * degPixelY;

  // calculate center shift
  var shiftLng =
    (iwWestLng < mapWestLng ? mapWestLng - iwWestLng : 0) +
    (iwEastLng > mapEastLng ? mapEastLng - iwEastLng : 0);
  var shiftLat =
    (iwNorthLat > mapNorthLat ? mapNorthLat - iwNorthLat : 0) +
    (iwSouthLat < mapSouthLat ? mapSouthLat - iwSouthLat : 0);

  // The center of the map
  var center = map.getCenter();

  // The new map center
  var centerX = center.lng() - shiftLng;
  var centerY = center.lat() - shiftLat;

  // center the map to the new shifted center
  map.setCenter(new google.maps.LatLng(centerY, centerX));

  // Remove the listener after panning is complete.
  google.maps.event.removeListener(this.boundsChangedListener_);
  this.boundsChangedListener_ = null;
};

function openWindow(url, width, height, centered)
{
  var left = (centered) ? (screen.width/2)-(width/2) : 0,
    top = (centered) ? (screen.height/2)-(height/2) : 0;

  window.open(url, '', 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, ' +
    'width=' + width + ', height=' + height + ', left=' + left + ', top=' + top);
}
