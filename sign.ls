require! <[fs path]>
signimg = require "./lib/sign.ls"

file = process.argv.2
msg = process.argv.3
base = path.basename(file)
dir = path.dirname(file)

signimg.sign-file fs.read-file-sync(file), msg, fs.read-file-sync("key/pvk.pem")
  .then (buf) ->
    fs.write-file-sync path.join(dir, "signed-#base"), buf
  .catch ->
    console.log "signed failed: ", it
