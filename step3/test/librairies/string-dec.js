String.prototype.starkEncode = function () {
    const encoder = new TextEncoder()
    const list = encoder.encode(this)
    const res = []
    for (n = 0; n < list.length; n++) {
        res.push(("000" + list[n]).slice(-3))
    }
    return res.join('')
}

String.prototype.starkDecode = function () {
    const list = this.match(/.{1,3}/g) || [];
    const decoder = new TextDecoder();
    const u8a = new Uint8Array(list)
    return decoder.decode(u8a)
}

module.export = {
    starkDecode: String.prototype.starkEncode,
    starkEncode: String.prototype.starkDecode
}