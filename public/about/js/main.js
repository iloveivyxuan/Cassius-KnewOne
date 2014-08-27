jQuery(document).ready(function($){

	var contentSections = $('.single-section'),
		navigationItems = $('#cd-vertical-nav a');

	updateNavigation();
	$(window).on('scroll', function(){
		updateNavigation();
	});

	//smooth scroll to the section
	navigationItems.on('click', function(event){
        event.preventDefault();
        smoothScroll($(this.hash));
    });
    //smooth scroll to second section
    $('.cd-scroll-down').on('click', function(event){
        event.preventDefault();
        smoothScroll($(this.hash));
    });

    //open-close navigation on touch devices
    $('.cd-nav-trigger').on('click', function(){
    	$('#cd-vertical-nav').toggleClass('open');
  
    });
    //close navigation on touch devices when selectin an elemnt from the list
    $('#cd-vertical-nav a').on('click', function(){
    	$('#cd-vertical-nav').removeClass('open');
    });

	function updateNavigation() {
		contentSections.each(function(){
			$this = $(this);
			var activeSection = $('#cd-vertical-nav a[href="#'+$this.attr('id')+'"]').data('number') - 1;
			if ( ( $this.offset().top - $(window).height()/2 < $(window).scrollTop() ) && ( $this.offset().top + $this.height() - $(window).height()/2 > $(window).scrollTop() ) ) {
				navigationItems.eq(activeSection).addClass('is-selected');
			}else {
				navigationItems.eq(activeSection).removeClass('is-selected');
			}
		});
	}

	function smoothScroll(target) {
        $('body,html').animate(
        	{'scrollTop':target.offset().top},
        	600
        );
	}


	var is_firefox = navigator.userAgent.indexOf('Firefox') > -1;

	$('#share, #review, #guide').find('a').on('click', function(event){
		event.preventDefault();
		var selected_member = $(this).data('type');
		$('.share-slide-in.'+selected_member+'').addClass('slide-in');
		$('.slide-in-close').addClass('is-visible');
		if( is_firefox ) {
			$('.slide-section').addClass('slide-out').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function(){
				$('body').addClass('overflow-hidden');
			});
		} else {
			$('.slide-section').addClass('slide-out');
			$('body').addClass('overflow-hidden');
		}
	});

	$(document).on('click', '.slide-in-overlay, .slide-in-close', function(event){
		event.preventDefault();
		$('.share-slide-in').removeClass('slide-in');
		$('.slide-in-close').removeClass('is-visible');
		if( is_firefox ) {
			$('.slide-section').removeClass('slide-out').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function(){
				$('body').removeClass('overflow-hidden');
			});
		} else {
			$('.slide-section').removeClass('slide-out');
			$('body').removeClass('overflow-hidden');
		}
	});

});