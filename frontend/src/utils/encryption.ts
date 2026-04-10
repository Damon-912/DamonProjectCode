/**
 * 密码加密工具函数
 * 
 * 与后端 src.Encryption.Encryption 类对应
 * 使用 AES-CBC + Base64 加密
 */

import CryptoJS from 'crypto-js';

// AES 加密密钥和偏移量（与后端一致）
const ENCKEY = '1234567812345678';
const ENCIV = '1234567812345678';

/**
 * 加密密码
 * 对应后端 EnCodeEnc 方法
 * @param password 明文密码
 * @returns 加密后的密码（Base64格式）
 */
export const encryptPassword = (password: string): string => {
  if (!password) return '';
  
  try {
    // 1. AES-CBC 加密
    const key = CryptoJS.enc.Utf8.parse(ENCKEY);
    const iv = CryptoJS.enc.Utf8.parse(ENCIV);
    
    const encrypted = CryptoJS.AES.encrypt(password, key, {
      iv: iv,
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7
    });
    
    // 2. Base64 编码（CryptoJS 默认输出就是 Base64）
    return encrypted.toString();
  } catch (error) {
    console.error('密码加密失败:', error);
    return '';
  }
};

/**
 * 解密密码（用于测试）
 * 对应后端 DeCodeEnc 方法
 * @param encryptedPassword 加密后的密码（Base64格式）
 * @returns 明文密码
 */
export const decryptPassword = (encryptedPassword: string): string => {
  if (!encryptedPassword) return '';
  
  try {
    // 1. Base64 解码并 AES 解密
    const key = CryptoJS.enc.Utf8.parse(ENCKEY);
    const iv = CryptoJS.enc.Utf8.parse(ENCIV);
    
    const decrypted = CryptoJS.AES.decrypt(encryptedPassword, key, {
      iv: iv,
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7
    });
    
    // 2. 转换为字符串
    return decrypted.toString(CryptoJS.enc.Utf8);
  } catch (error) {
    console.error('密码解密失败:', error);
    return '';
  }
};

/**
 * 获取加密后的密码（用于登录）
 * @param plainPassword 明文密码
 * @returns 加密后的密码
 */
export const getEncryptedPassword = (plainPassword: string): string => {
  return encryptPassword(plainPassword);
};

// 测试加密解密
if (import.meta.env.DEV) {
  // 开发模式下测试
  const testPassword = 'admin';
  const encrypted = encryptPassword(testPassword);
  const decrypted = decryptPassword(encrypted);
  
  console.log('密码加密测试:');
  console.log('  原始密码:', testPassword);
  console.log('  加密结果:', encrypted);
  console.log('  解密结果:', decrypted);
  console.log('  验证通过:', testPassword === decrypted);
}
