// Generated by LiveScript 1.3.1
var fs, crypto, ref$, inject, parse, signInfo, signFile, verifyFile, verifyInfo, sign, verify;
fs = require('fs');
crypto = require('crypto');
ref$ = require("./file"), inject = ref$.inject, parse = ref$.parse;
signInfo = function(msg, pvk){
  return new Promise(function(res, rej){
    var sig, e;
    try {
      if (typeof msg !== 'object') {
        msg = {
          msg: msg
        };
      }
      msg = JSON.stringify(msg);
      sig = sign(msg, pvk);
      return res({
        msg: msg,
        sig: sig
      });
    } catch (e$) {
      e = e$;
      return rej(e);
    }
  });
};
signFile = function(img, msg, pvk){
  return Promise.resolve().then(function(){
    if (typeof msg !== 'object') {
      msg = {
        msg: msg
      };
    }
    msg.md5 = crypto.createHash('md5').update(img).digest('hex');
    return signInfo(msg, pvk);
  }).then(function(arg$){
    var msg, sig;
    msg = arg$.msg, sig = arg$.sig;
    return inject(img, msg, sig);
  });
};
verifyFile = function(img, msg, pbk){};
verifyInfo = function(msg, sig, pbk){
  return new Promise(function(res, rej){
    sig = Buffer.from((typeof sig === 'string' ? JSON.parse(sig) : sig).sig, 'hex');
    msg = typeof msg === 'string'
      ? msg
      : JSON.stringify(msg);
    return res(verify(msg, sig, pbk));
  });
};
sign = function(msg, pvk){
  var sign, sig;
  sign = crypto.createSign('RSA-SHA512');
  sign.update(msg);
  sig = sign.sign(pvk);
  return JSON.stringify({
    sig: sig.toString('hex')
  });
};
verify = function(msg, sig, pbk){
  var verify, verified;
  verify = crypto.createVerify('RSA-SHA512');
  verify.update(msg);
  return verified = verify.verify(pbk, sig);
};
module.exports = {
  inject: inject,
  signInfo: signInfo,
  verifyInfo: verifyInfo,
  signFile: signFile,
  verifyFile: verifyFile
};
