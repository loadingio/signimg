require! <[fs crypto]>
inject = require "./inject"

sign-info = (msg, pvk) -> new Promise (res, rej) ->
  try
    if typeof(msg) != \object => msg := {} <<< {msg}
    msg := JSON.stringify(msg)
    sig = sign(msg, pvk)
    return res({msg, sig})
  catch e
    return rej(e)

sign-file = (img, msg, pvk) ->
  Promise.resolve!
    .then ->
      if typeof(msg) != \object => msg := {} <<< {msg}
      msg.md5 = crypto.createHash \md5 .update img .digest \hex
      sign-info(msg, pvk)
    .then ({msg, sig}) ->
      inject img, msg, sig

#TODO implement these
verify-file = (img, msg, pbk) ->
  #sig2 = Buffer.from(JSON.parse(sig).sig, \hex)
  #verify-result = verify comment, sig2, pbk
verify-info = (msg, sig, pbk) ->

sign = (msg, pvk) ->
  sign = crypto.createSign \RSA-SHA512
  sign.update msg
  sig = sign.sign pvk
  return JSON.stringify({sig: sig.toString(\hex)})
verify = (msg, sig, pbk) ->
  verify = crypto.createVerify \RSA-SHA512
  verify.update(msg)
  verified = verify.verify pbk, sig

module.exports = do
  inject: inject
  sign-info: sign-info
  verify-info: verify-info
  sign-file: sign-file
  verify-file: verify-file
