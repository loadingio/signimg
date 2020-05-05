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

 * sign(imageBuffer, message, privateKey)
   - return a promise that resolves to a signed image buffer.
 * verify(imageBuffer, publicKey)
   - return a promise that resolves to true only if provided image buffer is proper signed.


## License

MIT License.

