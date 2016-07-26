// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require spree/frontend/all
//= require twitter/bootstrap
//= require turbolinks
//= require_tree .
//= stub merchant.js
//= require noty/jquery.noty
//= require noty/layouts/topCenter
//= require noty/themes/default


var pyklocal = {

	init: function() {
		this.showNoty();
		this.setDeliveryType();
		this.filterByRadius();
		this.filterProducts();
    this.sortProduct();
    this.changeNoOfProductShow();
	},

	showNoty: function() {
		$.noty.defaults = {
	    layout: 'topCenter',
	    theme: 'defaultTheme', // or 'relax'
	    type: 'alert',
	    text: '', // can be html or string
	    dismissQueue: true, // If you want to use queue feature set this true
	    template: '<div class="noty_message"><span class="noty_text"></span><div class="noty_close"></div></div>',
	    animation: {
	        open: {height: 'toggle'}, // or Animate.css class names like: 'animated bounceInLeft'
	        close: {height: 'toggle'}, // or Animate.css class names like: 'animated bounceOutLeft'
	        easing: 'swing',
	        speed: 500 // opening & closing animation speed
	    },
	    timeout: 5000, // delay for closing event. Set false for sticky notifications
	    force: false, // adds notification to the beginning of queue when set to true
	    modal: false,
	    maxVisible: 5, // you can set max visible notification for dismissQueue true option,
	    killer: false, // for close all notifications before show
	    closeWith: ['click'], // ['click', 'button', 'hover', 'backdrop'] // backdrop click will close all notifications
	    callback: {
        onShow: function() {},
        afterShow: function() {},
        onClose: function() {},
        afterClose: function() {},
        onCloseClick: function() {},
	    },
	    buttons: false // an array of buttons
		};
		if ( !! noty_option) {
      noty(noty_option);
    }
	},

	setDeliveryType: function() {
		$('.delivery-li').click(function() {
			var deliveryType = $(this).data('value');
			$('#delivery').val(deliveryType);
			$('.delivery-li').removeClass('active');
			$(this).addClass('active');
		});
	},

	filterByRadius: function() {
		$('#radiusFilter').change(function() {
			$('#rFilter').submit();
		});
	},

	filterProducts: function() {
		$('.filter-field').click(function() {
			$('#facet-filter').submit();
		});
	},

  sortProduct: function() {
    $('#input-sort').change(function() {
      $('#sortFilter').submit();
    });
  },

  changeNoOfProductShow: function() {
    $('#noOfItem').change(function() {
      $('#itemShow').submit();
    });
  }

};

$(document).ready(function(){
	pyklocal.init();
});

window.onload = function() {
  var startPos;
  var geoSuccess = function(position) {
    startPos = position;
    $('#lat').val(startPos.coords.latitude);
    $('#lng').val(startPos.coords.longitude);
  };
  navigator.geolocation.getCurrentPosition(geoSuccess);
};
