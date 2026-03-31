import CryptoJS from 'crypto-js';
const key = '1234567812345678'; // 32位
const iv = '1234567812345678'; // 16位

// 加密
export function encrypt(text) {
    return CryptoJS.AES.encrypt(text, CryptoJS.enc.Utf8.parse(key), {
        iv: CryptoJS.enc.Utf8.parse(iv),
        mode: CryptoJS.mode.CBC,
        padding: CryptoJS.pad.Pkcs7
    }).toString()
}

// 解密
export function decrypt(text) {
    let decrypted = CryptoJS.AES.decrypt(text, CryptoJS.enc.Utf8.parse(key), {
        iv: CryptoJS.enc.Utf8.parse(iv),
        mode: CryptoJS.mode.CBC,
        padding: CryptoJS.pad.Pkcs7
    });
    return decrypted.toString(CryptoJS.enc.Utf8)
}
