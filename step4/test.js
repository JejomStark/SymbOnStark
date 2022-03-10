const { starkDecode, starkEncode } = require('./test/librairies/string-dec')
const str = '115121109098049'
console.log(str.starkDecode())

console.log(Timeout)

// const v1 = str.substring(0, 8)
// const v2 = str.substring(8, 16)
// console.log('v1', v1)
// console.log('v2', v2)
// String.prototype.starkEncode = function () {
//     const encoder = new TextEncoder()
//     const list = encoder.encode(this)
//     const res = []
//     for (n = 0; n < list.length; n++) {
//         res.push(("000" + list[n]).slice(-3))
//     }
//     return res.join('')
// }

// String.prototype.starkDecode = function () {
//     const list = this.match(/.{1,3}/g) || [];
//     const decoder = new TextDecoder();
//     const u8a = new Uint8Array(list)
//     return decoder.decode(u8a)
// }
// const d = str.starkEncode().join('')
// console.log(d.starkDecode())

// const view = encoder.encode(str) //.join('')
// console.log(view)
// const enc = []
// for (n = 0; n < view.length; n++) {
//     enc.push(("000" + view[n]).slice(-3))
// }

// console.log(enc.join(''))
// const result = view.match(/.{1,16}/g) || [];

// console.log(result)

// String.prototype.hexEncode = function () {
//     var hex, i;

//     var result = "";
//     for (i = 0; i < this.length; i++) {
//         hex = this.charCodeAt(i).toString(16);
//         
//     }

//     return result
// }
// String.prototype.hexDecode = function () {
//     var j;
//     var hexes = this.match(/.{1,4}/g) || [];
//     var back = "";
//     for (j = 0; j < hexes.length; j++) {
//         back += String.fromCharCode(parseInt(hexes[j], 16));
//     }

//     return back;
// }
// const d = str.hexEncode()
// console.log(d)
// const e = d.hexDecode()
// console.log(e)