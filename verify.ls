require! <[fs ./lib/sign]>
{inject, parse} = require "./lib/file"

fn = process.argv.2
buf = fs.read-file-sync fn
{msg, sig} = parse buf
ret = sign.verify-info msg, sig, fs.read-file-sync './key/pbk.pem'
console.log "message: ", msg
console.log "signature: ", sig
console.log "verify result: ", if ret => "correctly signed. " else "not correctly signed."

