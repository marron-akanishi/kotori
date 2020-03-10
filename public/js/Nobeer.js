(function( $ ) {
  $.fn.Nobeer = function(_option) {
	var wrapper = this;
	var idx = _option.idx || 0;
	var limit = idx;
	_option = Object.assign({
		domList:[],
		show:function(){
			$(this).show();
			window.d = this
		},
		hide:function(deleater){
			deleater();
		},
		pipe:function(idx){
		}
	},_option)
	_option.domList = _option.domList.map(el=>{
		return typeof el === "string" ? $(el) : el;
	})
	return {
		add:function(){
			var appender = $('<div/>',{"data-idx":idx}).hide();
			_option.domList.map(el=>el.clone(true).appendTo(appender))
			_option.pipe.call(appender,idx);
			wrapper.append(appender)
			_option.show.call(appender,function(){
				appender.remove();
			});
			idx++;
		},
		remove:function(){
			if(idx == limit) return;
			var els = wrapper.find(`[data-idx=${idx-1}]`)
			_option.hide.call(els,function(){
				els.remove();
			});
			idx--;
		},
		reset:function(){
			for(;idx > limit;idx--){
				var els = wrapper.find(`[data-idx=${idx - 1}]`)
				els.remove();
			}
		}
	}
  };
})( jQuery );