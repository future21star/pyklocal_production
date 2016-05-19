$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

var merchant = {
	init: function() {
		this.bindAddLocation();
		this.getLatLng();
		this.markOnMap();
		this.previewMap();
		this.addSearchBoxInMap();
		this.saveLocation();
		this.setMapAttributes();
		this.setLocation();
	},

	getLatLng: function() {
    var mapPreview = $("#map-preview");
    if(mapPreview.length != 0) {
      var isLocated = mapPreview.data("is_located");
      var latitude = isLocated ? parseFloat(mapPreview.data("latitude")) : 33.13755119234614;
      var longitude = isLocated ? parseFloat(mapPreview.data("longitude")) : -101.953125;
      return(new google.maps.LatLng(latitude, longitude));  
    } else {
      return(false);
    }
  },

  previewMap: function() {
    var latLng = this.getLatLng();
    if(latLng) {
      var mapOptions = {
        center: latLng,
        zoom: 8,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      var map = new google.maps.Map($("#map-preview")[0], mapOptions);
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
          url: "/companies/"+$this.data("company_id")+"/save_location",
          method: "put",
          data: { "company[latitude]": myCompany.lastMarker.position.lat(), "company[longitude]": myCompany.lastMarker.position.lng()},
          success: function(data, status) {
            if(data.success) {
              $("#map-preview").data("latitude", myCompany.lastMarker.position.lat());
              $("#map-preview").data("longitude", myCompany.lastMarker.position.lng());
              $("#map-preview").data("is_located", true);
              myCompany.previewMap();
              alert(data.message);
              $.close();
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
      $("#map-dailog").modal('show');
      that.setMapAttributes();
      return(false);
    });
    $("#map-dailog").on("shown.bs.modal", function() {
      that.setMapAttributes();
    });
  }
}

$(document).ready(function() {
	merchant.init();
});