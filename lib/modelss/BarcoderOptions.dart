class BarcoderOptions {
  bool enableZeroPadding;

  BarcoderOptions({this.enableZeroPadding = true});
}

class BarcoderFormat {
  final String validChars;
  final int validLength;

  BarcoderFormat({required this.validChars, required this.validLength});
}

class Barcoder {
  // Barcoder._internal();
  // static Barcoder _instance = Barcoder._internal();
  // static Barcoder get instance => _instance;
  var formats = {
    'ean8': BarcoderFormat(validChars: r'^\d+$', validLength: 8),
    'ean13': BarcoderFormat(validChars: r'^\d+$', validLength: 13),
    'ean14': BarcoderFormat(validChars: r'^\d+$', validLength: 14),
    'ean18': BarcoderFormat(validChars: r'^\d+$', validLength: 18),
    'gtin12': BarcoderFormat(validChars: r'^\d+$', validLength: 12),
    'gtin13': BarcoderFormat(validChars: r'^\d+$', validLength: 13),
    'gtin14': BarcoderFormat(validChars: r'^\d+$', validLength: 14),
    'autoSelect': BarcoderFormat(validChars: r'^\d+$', validLength: 13),
  };

  var minValidLength = 6;
  var maxValidLength = 18;
  var usualValidChars = r'^\d+$';

  late BarcoderFormat format;
  late String formatString;
  late BarcoderOptions options;
  bool enableZeroPadding = false;

  /**
   * Barcoder class
   *
   * @param {string}  format    See formats
   * @param {Object}  options   Valid option `enableZeroPadding`, defaults to `true`
   * @api public
   */
  Barcoder({String? format, BarcoderOptions? options})
  // : assert(format != null),
  //   assert(options != null)
  {
    this.format = format != null ? formats[format]! : formats['autoSelect']!;
    this.options = options != null ? options : new BarcoderOptions(enableZeroPadding: true);
    this.formatString = format != null ? format : 'autoSelect';
    if (!this.options.enableZeroPadding) {
      this.options.enableZeroPadding = true;
    }
  }

  /**
   * Validates the checksum (Modulo 10)
   * GTIN implementation factor 3
   *
   * @param  {String} value The barcode to validate
   * @return {Boolean}
   * @api private
   */

  bool validateGtin(String value) {
    var barcode = value.substring(0, value.length - 1);
    var checksum = int.parse(value.substring(value.length - 1));
    var calcSum = 0;
    var calcChecksum = 0;

    barcode.split('').asMap().forEach((index, e) {
      var number = int.parse(e);
      if (value.length % 2 == 0) {
        index += 1;
      }
      if (index % 2 == 0) {
        calcSum += number;
      } else {
        calcSum += number * 3;
      }
    });

    calcSum %= 10;
    calcChecksum = (calcSum == 0) ? 0 : (10 - calcSum);

    if (calcChecksum != checksum) {
      return false;
    }

    return true;
  }

  /**
   * Validates a barcode
   *
   * @param  {string}  barcode   EAN/GTIN barcode
   * @return {Boolean}
   * @api public
   */

  bool validate(String barcode) {
    if (this.formatString == 'autoSelect') {
      if (barcode.length < minValidLength || barcode.length > maxValidLength) {
        return false;
      }

      var isValidGtin = validateGtin(barcode);
      var paddedBarcode = barcode;

      if (!isValidGtin) {
        var possiblyMissingZeros = maxValidLength - barcode.length;
        while (possiblyMissingZeros > 0) {
          possiblyMissingZeros--;
          paddedBarcode = '0' + paddedBarcode;
          if (validateGtin(paddedBarcode)) {
            isValidGtin = true;
            break;
          }
        }
      }
      // generalLog.info(jsonEncode({
      //   'possibleType': (barcode.length > 8)
      //       ? 'GTIN${barcode.length}'
      //       : 'EAN8 / padded GTIN',
      //   'isValid': isValidGtin
      // }));
      return isValidGtin;
    }

    var validChars = this.format.validChars;
    var validLength = this.format.validLength;
    var enableZeroPadding = this.options.enableZeroPadding;

    if (!RegExp(validChars).hasMatch(barcode)) {
      return false;
    }

    if (enableZeroPadding && barcode.length < validLength) {
      var missingZeros = validLength - barcode.length;
      while (missingZeros > 0) {
        missingZeros--;
        barcode = '0' + barcode;
      }
    } else if (!enableZeroPadding && barcode.length != validLength) {
      return false;
    } else if (barcode.length > validLength) {
      return false;
    }

    return validateGtin(barcode);
  }
}