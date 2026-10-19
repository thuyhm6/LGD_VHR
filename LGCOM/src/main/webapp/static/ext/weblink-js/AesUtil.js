//
// 나이스 D&B 보안
//
// Descriptions
//  - 서비스 운영에 필요한 Javascript AES
// -----------------------------------------------------
var AesUtil = function(keySize, iterationCount) {	
  this.keySize = keySize / 32;
  this.iterationCount = iterationCount;
  this.salt = "4FF2EC019C627B945225DEBAD71A01B6985FE84C95A70EB132882F88C0A59A55";
  this.iv = "127D5C9927726BCEFE752eB1BDD3E138";
};

AesUtil.prototype.generateKey = function(salt, passPhrase) {
  var key = CryptoJS.PBKDF2(
      passPhrase, 
      CryptoJS.enc.Hex.parse(salt),
      { keySize: this.keySize, iterations: this.iterationCount });
  return key;
}

AesUtil.prototype.encrypt = function( passPhrase, plainText) {
  var salt = this.salt;
  var iv = this.iv;
  var key = this.generateKey(salt, passPhrase);
  var encrypted = CryptoJS.AES.encrypt(
      plainText,
      key,
      { iv: CryptoJS.enc.Hex.parse(iv) });
  return encrypted.ciphertext.toString(CryptoJS.enc.Hex);
}

AesUtil.prototype.decrypt = function(passPhrase, cipherText) {
  var salt = this.salt;
  var iv = this.iv;
  var key = this.generateKey(salt, passPhrase);
  var cipherParams = CryptoJS.lib.CipherParams.create({
    ciphertext: CryptoJS.enc.Hex.parse(cipherText)
  });
  var decrypted = CryptoJS.AES.decrypt(
      cipherParams,
      key,
      { iv: CryptoJS.enc.Hex.parse(iv) });
  return decrypted.toString(CryptoJS.enc.Utf8);
}