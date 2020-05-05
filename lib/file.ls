if module? => CRC32 = require "crc-32"

inject = (img, msg, sig) -> new Promise (res, rej) ->
  if typeof(msg) != \string => msg := JSON.stringify(msg)
  if typeof(sig) != \string => sig := JSON.stringify(sig)
  type = if [0x47 0x49 0x46 0x38].map((d,i) -> img[i] == d).reduce(((a,b) -> a and b),true) => \gif
  else if [0x89 0x50 0x4e 0x47].map((d,i) -> img[i] == d).reduce(((a,b) -> a and b),true) => \png
  else \unknown
  if type == \gif =>
    buf = Buffer.concat [make-gif-block(msg, false), make-gif-block(sig, true)]
    return res(inject-gif-block img, buf)
  else if type == \png =>
    buf = Buffer.concat [make-png-block(msg, false), make-png-block(sig, true)]
    return res(inject-png-block img, buf)
  else return Promise.reject(new Error("unsupported file format"))

make-png-block = (input, is-sig = false) ->
  if typeof(input) == \string => input = Buffer.from(input)
  src = Buffer.alloc(input.length + 12)
  input.copy src, 8
  crc = CRC32.buf input
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

sbsize = (buf, idx) ->
  txts = []
  offset = 0
  sum = 0
  data = []
  while idx < buf.length
    offset = buf[idx + sum]
    sum += (offset + 1)
    if offset <= 0 => break
    d = Buffer.alloc(offset)
    buf.copy d, 0, (idx + sum - offset), idx + sum
    data.push d
  ret = Buffer.concat data
  return {offset: sum, data: ret}

parse-gif-block = (buf) ->
  txts = []
  gct = buf.10 .&. 0x80
  gcts = buf.10 .&. 0x07
  idx = 13 + (if gct => (3 * (2 ** (gcts + 1))) else 0)
  while idx < buf.length
    if buf[idx] == 0x21 and buf[idx + 1] == 0xf9 =>
      idx += 8
    else if buf[idx] == 0x3b => break
    else if buf[idx] == 0x2c =>
      lct = buf[idx + 9] .&. 0x80
      lcts = buf[idx + 9] .&. 0x07
      idx += (10 + if lct => (3 * (2 ** (lcts + 1))) else 0) + 1
      {offset} = sbsize(buf, idx)
      idx = idx + offset
    else if buf[idx] == 0x21 =>
      is-comment = buf[idx + 1] == 0xfe
      {offset, data} = sbsize(buf, idx + 2)
      if is-comment =>
        data = data.toString!
        try
          obj = JSON.parse(data)
          txts.push obj
        catch e
      idx = idx + 2 + offset
    else
      console.log "parse error."
      console.log buf[idx]
      break
  sig = txts.filter(-> it.sig?).0
  msg = txts.filter(->!(it.sig?)).0
  return {sig, msg}

parse-png-block = (buf) ->
  txts = []
  idx = 8
  while idx < buf.length
    offset = (buf.readUInt32BE(idx) >? 0)
    if [4 to 7].map(-> String.fromCharCode(buf[idx + it])).join('') == \iTXt =>
      data = Buffer.alloc(offset)
      buf.copy data, 0, idx + 8, (idx + 8 + offset)
      try
        obj = JSON.parse(data.toString!)
        txts.push obj
      catch e
        console.log '.'
    idx += (offset + 12)
  sig = txts.filter(-> it.sig?).0
  msg = txts.filter(->!(it.sig?)).0
  return {msg, sig}

parse = (buf) -> new Promise (res, rej) ->
  type = if [0x47 0x49 0x46 0x38].map((d,i) -> buf[i] == d).reduce(((a,b) -> a and b),true) => \gif
  else if [0x89 0x50 0x4e 0x47].map((d,i) -> buf[i] == d).reduce(((a,b) -> a and b),true) => \png
  else \unknown
  return res(
    if type == \gif => parse-gif-block buf
    else if type == \png => parse-png-block buf
    else {}
  )

if module? => module.exports = {inject, parse}
if window? => window.signimg = {inject, parse}
