crypto = require 'crypto'
tokencrypto = require '../src/tokencrypto'

IRONMQ_MESSAGE_SIZE_LIMIT = 64000



randomValueHex = (len) ->
  crypto.randomBytes(Math.ceil(len/2)).toString('hex') .slice(0,len)

for i in [64000..30000]
  if done
    done = i
    break
  tokencrypto.getEncrypted (randomValueHex i), (randomValueHex 32), (err, encryptedText) ->
    if encryptedText.length < IRONMQ_MESSAGE_SIZE_LIMIT
      console.log "input string #{i} and encrypted: #{encryptedText.length}"
      done = true

console.log 'ended with i', i