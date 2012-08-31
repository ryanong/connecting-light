/*
 *= require jquery
 *= require jquery_ujs
 *= require jquery.ui.slider
 *= require jquery.effects.all
 *= require jquery.form
 *= require jquery.animate-enhanced
 *= require_self
 */

function memoize( fn ) {
    return function () {
        var args = Array.prototype.slice.call(arguments),
            hash = "",
            i = args.length;
        currentArg = null;
        while (i--) {
            currentArg = args[i];
            hash += (currentArg === Object(currentArg)) ?
            JSON.stringify(currentArg) : currentArg;
            fn.memoize || (fn.memoize = {});
        }
        return (hash in fn.memoize) ? fn.memoize[hash] :
        fn.memoize[hash] = fn.apply(this, args);
    };
}
