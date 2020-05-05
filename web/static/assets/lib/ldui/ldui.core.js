// Generated by LiveScript 1.3.1
var ldBoundScroll, scrollto, smoothScroll;
ldBoundScroll = function(n){
  var prevent, handler;
  prevent = function(e){
    e.stopPropagation();
    e.preventDefault();
    e.returnValue = false;
    return false;
  };
  handler = function(e){
    n.scrollTop -= e.wheelDelta || -e.deltaY || 0;
    return prevent(e);
  };
  if (navigator.userAgent.match('CriOS')) {
    return;
  }
  return ['wheel'].map(function(it){
    return n.addEventListener(it, handler);
  });
};
ldBoundScroll.init = function(){
  var i$, ref$, len$, item, results$ = [];
  for (i$ = 0, len$ = (ref$ = document.querySelectorAll('.bound-scroll')).length; i$ < len$; ++i$) {
    item = ref$[i$];
    results$.push(ldBoundScroll(item));
  }
  return results$;
};
scrollto = function(n, d, offset, h){
  var e, b, c, s, f;
  d == null && (d = 500);
  offset == null && (offset = -80);
  n = typeof n === 'string' ? ld$.find(document.body, n, 0) : n;
  if (!(n && n.getBoundingClientRect)) {
    return;
  }
  n = n.getBoundingClientRect();
  e = h || document.scrollingElement || document.documentElement;
  b = e.scrollTop;
  c = n.top + b;
  if (c + window.innerHeight >= e.scrollHeight) {
    c = e.scrollHeight - window.innerHeight;
  }
  c = c - b + offset;
  s = 0;
  f = function(t){
    var o;
    if (!s) {
      s = t;
    }
    t = (t - s) / (d / 2);
    o = t < 1
      ? c / 2 * t * t + b
      : -c / 2 * ((t - 1) * (t - 3) - 1) + b;
    e.scrollTop = o;
    if (t <= 2) {
      return requestAnimationFrame(f);
    }
  };
  return requestAnimationFrame(f);
};
smoothScroll = function(opt){
  var delay, offset;
  opt == null && (opt = {});
  delay = opt.delay || 500;
  offset = opt.offset != null
    ? opt.offset
    : -80;
  return ld$.find(document, "*[data-scrollto]").map(function(d, i){
    var t;
    t = d.getAttribute('data-scrollto');
    return d.addEventListener('click', function(e){
      scrollto(ld$.find(document, t, 0), delay, offset);
      return e.preventDefault();
    });
  });
};
if (document.createEvent || n.fireEvent) {
  ld$.find(document, '.form-check-label').map(function(it){
    var n;
    n = it.previousSibling;
    if (!(n.classList && n.classList.contains('form-check-input'))) {
      return;
    }
    return it.addEventListener('click', function(){
      var evt;
      if (document.createEvent) {
        n.checked = !n.checked;
        evt = document.createEvent('HTMLEvents');
        evt.initEvent('input', false, true);
        return n.dispatchEvent(evt);
      } else if (n.fireEvent) {
        n.checked = !n.checked;
        return n.fireEvent('onchange');
      }
    });
  });
}
// Generated by LiveScript 1.3.1
var ldNotify;
ldNotify = function(opt){
  var this$ = this;
  opt == null && (opt = {});
  this.opt = {
    className: ["alert", "ld"],
    classIn: ["ld-bounce-in"],
    classOut: ["ld-fade-out"],
    delay: 2000
  };
  import$(this.opt, opt);
  ['className', 'classIn', 'classOut'].map(function(it){
    if (typeof this$.opt[it] === 'string') {
      return this$.opt[it] = this$.opt[it].split(' ').filter(function(it){
        return it.trim();
      });
    }
  });
  this.root = typeof opt.root === 'string'
    ? document.querySelector(opt.root)
    : opt.root;
  return this;
};
ldNotify.prototype = import$(Object.create(Object.prototype), {
  send: function(type, msg){
    var node, this$ = this;
    node = ld$.create({
      name: 'div',
      className: this.opt.className.concat(this.opt.classIn, ["alert-" + type]),
      text: msg
    });
    this.root.insertBefore(node, this.root.childNodes[0]);
    return setTimeout(function(){
      node.classList.remove.apply(node.classList, this$.opt.classIn);
      node.classList.add.apply(node.classList, this$.opt.classOut);
      return setTimeout(function(){
        return ld$.remove(node);
      }, this$.opt.delay);
    }, this.opt.delay);
  }
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
