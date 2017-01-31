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
//= require new_design/jquery.min
//= require jquery_ujs
//= require new_design/bootstrap.min
//= require spree/frontend/all
//= require new_design/wow.min
//= require new_design/lightslider
//= require new_design/jquery.flexslider
//= require new_design/custom

//= stub merchant.js
//= stub chatbox.min.js
//= require social-share-button

$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

var pyklocal = {

	init: function() {
    this.restrictNumber();
		this.showNoty();
		this.setDeliveryType();
		this.filterByRadius();
		this.filterProducts();
    this.sortProduct();
    this.changeNoOfProductShow();
    this.applyCoupon();
    this.configurePhoneField();
	},

  restrictNumber: function() {
    jQuery('.numbersOnly').keyup(function () {
      this.value = this.value.replace(/[^0-9\.]/g,'');
    });
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
	    timeout: 35000, // delay for closing event. Set false for sticky notifications
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
  },

  applyCoupon: function() {
    $('#apply-coupon-code').click(function () {
      var order_id = $(this).data('order_id');
      var order_token = $(this).data('order_token');
      var couponStatus = $("#coupon-response");
      couponStatus.removeClass();
      $.ajax({
        url: "/api/v1/orders/"+$(this).data('order_id')+"/apply_coupon_code",
        method: 'put',
        headers: {"X-Spree-Order-Token": $(this).data('order_token')},
        data: {coupon_code: $('#coupon-code').val(), order_token: $(this).data('order_token')},
        success: function(data) {
          if(data.status == "1") {
            couponStatus.addClass('alert-success').text(data.message);
            location.reload();
            // refreshOrderSummary(order_id, order_token);
          } else {
            couponStatus.addClass('alert-error').text(data.message);
          }
        }
      });
    });
  },

  configurePhoneField: function() {
    $('.number-only').keypress(function(e){
      if($(this).val().length <= 9) {
        if((e.which >= 48 && e.which <= 57) || (e.which == 46)){
        } else {
          return false;
        }
      } else {
        return false;
      }
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
    var location_data = { lat: startPos.coords.latitude, lng: startPos.coords.longitude }
    $.post("/api/v1/store_sessions", location_data, function(data){});
  };
  navigator.geolocation.getCurrentPosition(geoSuccess);
};


function refreshOrderSummary(order_id, order_token){
 // $.get("/api/v1/orders/"+order_id+"/refresh_order_summary", order_token, function(data){});4
 console.log(order_id)
  $.ajax({
    url: "/api/v1/orders/"+order_id+"/refresh_order_summary.js",
    method: 'get',
    success: function(data) {
      console.log(data);
      data = data.toString().replace(/\\\//g,"");
      console.log(data)
      $("#checkout-summary").html(data);
    }
    //headers: {"X-Spree-Order-Token": order_token},
    // data: {order_token: order_token},
  })
}
