# imagesign

add signed information in PNG and SVG file.


## Usage

 * prepare Public / Private Key Pair ( pbk.pem and pvk.pem ):

    mkdir -p key
    openssl genrsa -out key/pvk.pem 2048
    openssl rsa -in key/pvk.pem -pubout -out key/pbk.pem


 * sign with `sign.ls`:

    node_modules/.bin/lsc sign.ls <yourfile> <yourmessage>


## API

signimg provides two API:

 * signFile(imageBuffer, message, privateKey)
   - return a promise that resolves to a signed image buffer.
 * signInfo(message, privateKey)
   - return a promise that resolves to a JSON object with following fields:
     * msg: original message (stringified)
     * sig: signature ( stringified json {sig: ... })
 * verifyFile(imageBuffer, publicKey)
   - return a promise that resolves to true only if provided image buffer is proper signed.
 * verifyInfo(message, signature, publicKey)
   - verify with provided publickey that message is correctly signed by signature.
 * inject(imageBuffer, message, signature)
   - inject message and signature into image buffer. support PNG and GIF.
     - message: either string or JSON.
     - signature: either string or JSON.



## License

MIT License.

