$.ajaxSetup({
  headers: {
    'X-Spree-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

var Store = function(){
  this.init();
}

Store.prototype = {
  init: function() {
    this.bindAddLocation();
    this.previewMap();
    this.saveLocation();
  },

  getLatLng: function() {
    var latitude, longitude;
    var mapPreview = $("#map-preview");

    if(mapPreview.length != 0) {
      var isLocated = mapPreview.data("is_located");
      if(isLocated){
        latitude = parseFloat(mapPreview.data("latitude"));
        longitude = parseFloat(mapPreview.data("longitude"));
      } else {
        latitude = 40.7142700;
        longitude = -74.0059700;
      }
      return(new google.maps.LatLng(latitude, longitude));  
    } else {
      return(false);
    }
  },

  getInfoWindow: function(map, marker) {
    var infowindow = new google.maps.InfoWindow({content  : "<b>"+$("#company-name").text()+"</b><div>"+$("#full-address").text()+"</div>"})
    google.maps.event.addListener(marker, 'click', function() {
      infowindow.open(map, marker);
    });
  },

  previewMap: function() {
    var latLng = this.getLatLng();
    if(latLng) {
      var mapOptions = {
        center: latLng,
        zoom: 8,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      map = new google.maps.Map(document.getElementById("map-preview"), mapOptions);
      this.markOnMap(map, latLng);  
    }
  },

  markOnMap: function(map, latLng) {
    if($("#map-preview").data("is_located")) {
      var marker = new google.maps.Marker({
        position: latLng,
        map: map
      });
      this.lastMarker = marker;
      // this.getInfoWindow(map, marker);  
    }
  },

  addSearchBoxInMap: function(map) {

    var input = $("<input>").attr({type: "text", id: "pac-input", class: "controls form-control map-search", placeholder: "Search a location..."})[0];
    map.controls[google.maps.ControlPosition.TOP].push(input);
    var searchBox = new google.maps.places.SearchBox(input);
    var markers = [];

    google.maps.event.addListener(searchBox, 'places_changed', function() {

      var places = searchBox.getPlaces();

      for (var i = 0, marker; marker = markers[i]; i++) {
        marker.setMap(null);
      }

      markers = [];

      var bounds = new google.maps.LatLngBounds();

      for (var i = 0, place; place = places[i]; i++) {
        var image = {
          url: place.icon,
          size: new google.maps.Size(71, 71),
          origin: new google.maps.Point(0, 0),
          anchor: new google.maps.Point(17, 34),
          scaledSize: new google.maps.Size(25, 25)
        };

        bounds.extend(place.geometry.location);
      }

      map.fitBounds(bounds);
    });

    google.maps.event.addListener(map, 'bounds_changed', function() {
      var bounds = map.getBounds();
      searchBox.setBounds(bounds);
    });

  },

  setMapAttributes: function() {
    var latLng = this.getLatLng();
    var that = this;
    var mapOptions = {
      center: latLng,
      zoom: 2,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    var map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
    that.myMap = map;
    this.addSearchBoxInMap(map);
    google.maps.event.trigger(map, 'resize');
    map.setZoom(map.getZoom());
    this.markOnMap(map, latLng);
    google.maps.event.addListener(map, 'click', function(e) {
      that.setLocation(e.latLng, map);
    });
  },

  saveLocation: function() {
    $(document).on("click", "#save-location", function(event) {
      var $this = $(event.target);
      if(this.lastMarker) {
        alert("Please select the location");
      } else {
        $.ajax({
          url: "/api/v1/merchant_stores/"+$this.data("store_id")+"/update_location",
          method: "put",
          data: { "merchant_store[latitude]": myCompany.lastMarker.position.lat(), "merchant_store[longitude]": myCompany.lastMarker.position.lng()},
          success: function(data, status) {
            if(data.success) {
              $("#map-preview").data("latitude", myCompany.lastMarker.position.lat());
              $("#map-preview").data("longitude", myCompany.lastMarker.position.lng());
              $("#map-preview").data("is_located", true);
              myCompany.previewMap();
              alert(data.message);
              $('.modal').modal('hide');
            } else {
              alert(data.message);
            }
          }
        });  
      }
      return(false);
    });
  },

  setLocation: function(latLng, map) {
    if(this.lastMarker) {
      this.lastMarker.setMap(null);
    } 
    var marker = new google.maps.Marker({
      position: latLng,
      map: map
    });
    this.lastMarker = marker;
    this.getInfoWindow(map, marker);
  },

  bindAddLocation: function() {
    var that = this;
    $("#add-location").bind("click", function() {
      $("#map-dialog").modal('show');
      that.setMapAttributes();
      return(false);
    });
    $("#map-dialog").on("shown.bs.modal", function() {
      that.setMapAttributes();
    });
  }
}

var myCompany = new Store();