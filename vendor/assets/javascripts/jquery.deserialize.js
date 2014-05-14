(function (jQuery) {
    jQuery.fn.deserialize = function (data, options) {
        var f = jQuery(this), map = {};
        //Escape + to %20
        data = data.replace(/\+/g, '%20');
        //Get map of values
        jQuery.each(data.split("&"), function () {
            var nv = this.split("="),
                n = decodeURIComponent(nv[0]),
                v = nv.length > 1 ? decodeURIComponent(nv[1]) : null;
            if (!(n in map)) {
                map[n] = [];
            }
            map[n].push(v);
        })
        //Set values for all form elements in the data
        jQuery.each(map, function (n, v) {
            if (!options.except || options.except.indexOf(n) == -1) {
                var $input = f.find("[name='" + n + "']");
                if ($input.attr('data-skip-deserialize') != 'true') {
                    $input.val(v);
                }
            }
        })
        //Uncheck checkboxes and radio buttons not in the form data
        jQuery("input[data-skip-deserialize!='true']:checkbox:checked,input:radio:checked").each(function () {
            if (!($(this).attr("name") in map)) {
                $(this).prop('checked', false);
            }
        })

        return this;
    };
})(jQuery);
