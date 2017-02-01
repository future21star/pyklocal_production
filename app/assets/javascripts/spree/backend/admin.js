$(document).ready(function () {
  'use strict';
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
      $.get('/admin/reports/store_sale_product',{order_completed_at_gt: '1/1/2017', order_completed_at_lt: '31/1/2017', store_id: id},function(response){
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
})


