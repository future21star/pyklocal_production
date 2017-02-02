// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require spree/backend

//= require_tree .
//= require spree/backend/spree_print_invoice
//= require spree/backend/spree_braintree_vzero

$(document).ajaxStart(function(){
        $("#wait").css("display", "block");
    });
    $(document).ajaxComplete(function(){
        $("#wait").css("display", "none");
    });
  $(document).on('click','.icon-plus',function(){
    $('.icon-minus').attr('class', 'icon icon-plus');
    $(this).attr('class', 'icon icon-minus');
    var id = $(this).attr('id');
    setTimeout(function(){
      $('.sale-products').not('#'+id).each(function(){
      $(this).remove();
    });
    },500);
        
    
    var trHTML = '';
      console.log($(this).attr('id'));
      date_from = $('#range_from_date').val();
      date_to = $('#range_to_date').val();
      $.get('/admin/reports/store_sale_product',{order_completed_at_gt: date_from, order_completed_at_lt: date_to, store_id: id},function(response){
          console.log(response);
          if (response.length){
            trHTML = 
                  '<tr id="'+ id +'" class="sale-products"><td></td><th>Name</th><th>Price(USD)</th><th>Quantity</th><th>Tax Rate(%)</th></tr>'; 
            // $('tr').filter('#'+id).css("display","");
            $.each(response,function(index){
              // console.log(response[index]);
              trHTML += 
                  '<tr id="'+ id +'" class="sale-products"><td></td><td>' + response[index].name + 
                  '</td><td>' + response[index].price + 
                  '</td><td>' + response[index].qty + 
                  '</td><td>' + (response[index].tax_rate * 100 )+ 
                  '</td></tr>';     
              
            });
            
           
          } else {
            trHTML += 
                  '<tr id="'+ id +'" class="sale-products"><td></td><th>No Product Found</th>'
            // alert('No Products found!');
          }
          $('tr').filter('#'+id).after(trHTML);
          $('.sale-products').fadeIn();
      });
  });
  $(document).on('click','.icon-minus',function(){
    $(this).attr('class', 'icon icon-plus');
    var id = $(this).attr('id');
    // console.log($('.sale-products').filter('#'+id));
    $('.sale-products').filter('#'+id).fadeOut();
    setTimeout(function(){
      if ($('.sale-products').filter('#'+id).length){
        $('.sale-products').filter('#'+id).each(function(){
          $(this).remove();
        });
      }
    },500);     
  });