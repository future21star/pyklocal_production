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
//= require spree/backend/report


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

$(document).ready(function(){
      flag = true;
      $('.user_address_form').on('submit', function(e){
          e.preventDefault();
          if ((validateFirstName()) * (validateLastName()) * (validateAddress1()) * (validateCity()) * (validateAddress2()) * ( validatePhone()) * (validateZip()) ) {
              this.submit();
          }
      });
    });
  

    $(document).ready(function(){
      flag = true;
      $('#checkout_form_address').on('submit', function(e){
          e.preventDefault();
          if ((validateFirstName()) * (validateLastName()) * (validateAddress1()) * (validateCity()) * (validateAddress2()) * ( validatePhone()) * (validateZip()) ) {
              this.submit();
          }
      });
    });


    $('.address_firstname').on('blur',function(){
      validateFirstName();
    });

    $('.address_lastname').on('blur',function(){
        validateLastName();
    });

    $('.address_address1').on('blur',function(){
        validateAddress1();
    });


    $('.address_address2').on('blur',function(){
        validateAddress2();
    });

    $('.address_city').on('blur',function(){
        validateCity();
    });

    $('.address_zipcode').on('blur',function(){
        validateZip();
    });

    $('.address_phone').on('blur',function(){
        validatePhone();
    });



    function validateFirstName(){
      if($('.address_firstname').val().trim().length == 0){
        $('#first-name-error').html("<p class='text-red'> First Name can not be blank </p");
        $('#first-name-error').show();
        return 0;
      }
      else{
        $('#first-name-error').hide();
         return 1 ;
      }
    }

    function validateLastName(){
      if($('.address_lastname').val().trim().length == 0){
        $('#last-name-error').html("<p class='text-red'> Last Name can not be blank </p");
        $('#last-name-error').show();
         return  0;
      }
      else{
        $('#last-name-error').hide();
         return 1;
      }
    }

    function validateAddress1(){
      if($('.address_address1').val().trim().length == 0){
        $('#address1-error').html("<p class='text-red'> Street Address1 can not be blank </p");
        $('#address1-error').show();
         return  0;
      }
      else{
        $('#address1-error').hide();
         return 1;
      }
    }

    function validateAddress2(){
      if($('.address_address2').val().trim().length > 200){
        $('#address2-error').html("<p class='text-red'> Street Address2 can not be greater than 200 </p");
        $('#address2-error').show();
         return  0;
      }
      else{
        $('#address2-error').hide();
         return 1;
      }
    }

    function validateCity(){
      flag = true;
      errorStr = "";
      var letters = /^[A-Za-z ]+$/;
      if($('.address_city').val().trim().length == 0){
        errorStr += "City can not be blank";
        flag = false;
      }
      else if ( ($('.address_city').val()).match(letters) == null){
          errorStr += "only character(s) are allowed in city";
          flag = false;
      }

      if (flag == false){
        OutputErrorStr = "<p class='text-red'> " + errorStr + "</p>";
        $('#city-error').html(OutputErrorStr);
         $('#city-error').show();
        return 0;
      }
      else{
         $('#city-error').hide();
        return 1;
      }
    }

    function validateZip(){
      flag = true;
      var letters = /^[0-9]+$/;
      errorStr = "";
      if($('.address_zipcode').val().trim().length == 0){
        errorStr += "Zipcode can not be blank";
        flag = false;
      }
      else if (($('.address_zipcode').val()).match(letters) == null){
          errorStr += "only number(s) are allowed in zipcode";
          flag = false;
      }

      if (flag == false){
        OutputErrorStr = "<p class='text-red'> " + errorStr + "</p>";
        $('#zipcode-error').html(OutputErrorStr);
         $('#zipcode-error').show();
        return 0;
      }
      else{
         $('#zipcode-error').hide();
        return 1;
      }
    }


    function validatePhone(){

      flag = true;
      var letters = /^[0-9]+$/;
      errorStr = "";
      if($('.address_phone').val().trim().length == 0){
        errorStr += "Phone Number can not be blank";
        flag = false;
      }
      else if (($('.address_phone').val()).match(letters) == null){
          errorStr += "only number(s) are allowed in phone number";
          flag = false;
      }
      else if($('.address_phone').val().trim().length < 10){
        errorStr += "Phone Number must have 10 digits";
        flag = false;
      }

      if (flag == false){
        OutputErrorStr = "<p class='text-red'> " + errorStr + "</p>";
        $('#phone-error').html(OutputErrorStr);
         $('#phone-error').show();
        return 0;
      }
      else{
         $('#phone-error').hide();
        return 1;
      }

    }

/*===================================== Registration Form Validations ============================================*/

$(document).ready(function(){
      $('.reg-form').on('submit', function(e){
          e.preventDefault();
          if ((validateRegPassword()) * (validateRegConfirmPassword()) * (validateRegFirstName()) * (validateRegLastName()) * ( ValidateRegEmail()) ) {
              this.submit();
          }
      });
    });


   $('.reg-password').on('blur',function(){
      console.log("called");
      validateRegPassword();
    });

    $('.reg-password-confrim').on('blur',function(){
        validateRegConfirmPassword();
    });

    function validateRegPassword(){
      flag = true;
      errorStr = "";
      if($('.reg-password').val().trim().length == 0){
        errorStr += "Password can not be blank";
        flag = false;
      }

      if (($('.reg-password').val().trim().length > 0) && ($('.reg-password').val().trim().length < 6)){
        errorStr += "Password length must be greater than 6";
        flag = false;
      }


      if (flag == false){
        OutputErrorStr = "<p class='text-red'> " + errorStr + "</p>";
        $('#password-error').html(OutputErrorStr);
         $('#password-error').show();
        return 0;
      }
      else{
         $('#password-error').hide();
        return 1;
      }
    }


    $('#spree_user_first_name').on('blur',function(){
      validateRegFirstName();
    });

    $('#spree_user_last_name').on('blur',function(){
        validateRegLastName();
    });

    function validateRegFirstName(){
      if($('#spree_user_first_name').val().trim().length == 0){
        $('#first-name-error').html("<p class='text-red'> First Name can not be blank </p");
        $('#first-name-error').show();
        return 0;
      }
      else{
        $('#first-name-error').hide();
         return 1 ;
      }
    }

    function validateRegLastName(){
      if($('#spree_user_last_name').val().trim().length == 0){
        $('#last-name-error').html("<p class='text-red'> Last Name can not be blank </p");
        $('#last-name-error').show();
         return  0;
      }
      else{
        $('#last-name-error').hide();
         return 1;
      }
    }

    function validateRegConfirmPassword(){
      if($('.reg-password').val().trim() != $('.reg-password-confirm').val().trim()) {
         $('#password-confirm-error').html("<p class='text-red'> Password does not match");
         $('#password-confirm-error').show();
         return 0;
      }
      else{
         $('#password-confirm-error').hide();
        return 1;
      }
    }

    $('#spree_user_email').on('blur',function(){
        ValidateRegEmail();
    });

    function  ValidateRegEmail(){
      flag = true;
      errorStr = ""
      if ( $('.reg-email').val() == null || $('.reg-email').val() == ''){
        errorStr = " Email can not be blank";
        flag = false;
      }
      else if (validateRegistrationEmail() == false){
        errorStr = "Email is Invalid";
        flag = false;
      }
      
      if (flag == false){
        OutputErrorStr = "<p class='text-red'> " + errorStr + "</p>";
        $('#invalid-email').html(OutputErrorStr);
        $('#invalid-email').show();
        return 0;
      }
      else{
        $('#invalid-email').hide();
        return 1;
      }
    }


    function validateRegistrationEmail(){
      var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/  ;
          console.log($('.reg-email').val());
          return re.test($('.reg-email').val());
    }





