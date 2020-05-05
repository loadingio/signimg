require! <[fs crypto]>
crc32 = require "crc-32"

sign-file = (img, msg, pvk) -> new Promise (res, rej) ->
  try
    if typeof(msg) == \string => msg := {} <<< {msg}
    msg.md5 = crypto.createHash \md5 .update img .digest \hex
    # TODO accurately check file format
    type = if img.0 == 0x47 => \gif else \png
    msg := JSON.stringify(msg)
    sig = sign(msg, pvk)
    if type == \gif =>
      buf = Buffer.concat [make-gif-block(msg, false), make-gif-block(sig, true)]
      return res(inject-gif-block img, buf)
    else if type == \png =>
      buf = Buffer.concat [make-png-block(msg, false), make-png-block(sig, true)]
      return res(inject-png-block img, buf)
    else throw new Error("unsupported file format")
  catch e
    return rej(e)

#TODO implement this
verify-file = (img, msg, pbk) ->
  #sig2 = Buffer.from(JSON.parse(sig).sig, \hex)
  #verify-result = verify comment, sig2, pbk

sign = (msg, pvk) ->
  sign = crypto.createSign \RSA-SHA512
  sign.update msg
  sig = sign.sign pvk
  return JSON.stringify({sig: sig.toString(\hex)})
verify = (msg, sig, pbk) ->
  verify = crypto.createVerify \RSA-SHA512
  verify.update(msg)
  verified = verify.verify pbk, sig

make-png-block = (input, is-sig = false) ->
  if typeof(input) == \string => input = Buffer.from(input)
  src = Buffer.alloc(input.length + 12)
  input.copy src, 8
  crc = crc32.buf input
  src.writeUInt32BE input.length, 0
  src.writeInt32BE crc, input.length + 8
  for i from 0 til 4 => src[i + 4] = "iTXt".charCodeAt(i)
  return src

make-gif-block = (input, is-sig = false) ->
  if typeof(input) == \string => input = Buffer.from(input)

  #src = Buffer.alloc(input.length + 6)
  # LDIO
  #[0x4c 0x44 0x49 0x4f, (if is-sig => 0x53 else 0x43)].map (d,i) -> src[i] = d
  #input.copy(src, 5)
  src = input
  des = Buffer.alloc(2 + src.length + Math.ceil( src.length / 255) + if src.length == 0 => 0 else 1)
  # comment extensioon indicator
  des.0 = 0x21
  des.1 = 0xfe
  srcp = 0
  desp = 2
  srclen = src.length
  while true
    offset = if srclen <= 255 => srclen else 255
    des[desp] = offset
    if offset > 0 =>
      src.copy des, desp + 1, srcp, srcp + offset
      srcp += offset
      desp += (offset + 1)
      srclen -= offset
    else
      break
  return des

inject-gif-block = (gif, buf) ->
  global = (gif.10 .&. 0x80)
  gcts = if global => 2 ** ((gif.10 .&. 0x07) + 1) else 0
  out = Buffer.alloc(gif.length + buf.length)
  gif.copy out, 0, 0, 13 + (gcts * 3) - 1
  buf.copy out, (13 + gcts * 3), 0, buf.length - 1
  gif.copy out, (13 + gcts * 3) + buf.length, (13 + gcts * 3), gif.length - 1
  return out

inject-png-block = (png, buf) ->
  out = Buffer.alloc(png.length + buf.length)
  offset = png.readUInt32BE(8) + 8 + 12
  png.copy out, 0, 0, offset
  buf.copy out, offset
  png.copy out, offset + buf.length, offset
  return out

module.exports = {sign: sign-file, verify: verify-file}
