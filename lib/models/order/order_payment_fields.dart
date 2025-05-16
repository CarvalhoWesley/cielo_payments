class OrderPaymentFields {
  final bool? isDoubleFontPrintAllowed;
  final bool? hasPassword;
  final String? primaryProductCode;
  final bool? isExternalCall;
  final String? primaryProductName;
  final String? receiptPrintPermission;
  final bool? isOnlyIntegrationCancelable;
  final String? upFrontAmount;
  final String? creditAdminTax;
  final String? firstQuotaDate;
  final bool? isFinancialProduct;
  final bool? hasSignature;
  final bool? hasPrintedClientReceipt;
  final bool? hasWarranty;
  final String? applicationName;
  final String? interestAmount;
  final String? changeAmount;
  final String? serviceTax;
  final String? cityState;
  final bool? hasSentReference;
  final String? v40Code;
  final String? secondaryProductName;
  final String? paymentTransactionId;
  final String? avaiableBalance;
  final String? pan;
  final String? originalTransactionId;
  final String? originalTransactionDate;
  final String? secondaryProductCode;
  final bool? hasSentMerchantCode;
  final String? documentType;
  final String? statusCode;
  final String? merchantAddress;
  final String? merchantCode;
  final String? paymentTypeCode;
  final bool? hasConnectivity;
  final String? productName;
  final String? merchantName;
  final String? entranceMode;
  final String? firstQuotaAmount;
  final String? cardCaptureType;
  final String? totalizerCode;
  final String? requestDate;
  final String? boardingTax;
  final String? applicationId;
  final String? numberOfQuotas;
  final String? document;

  OrderPaymentFields({
    this.isDoubleFontPrintAllowed,
    this.hasPassword,
    this.primaryProductCode,
    this.isExternalCall,
    this.primaryProductName,
    this.receiptPrintPermission,
    this.isOnlyIntegrationCancelable,
    this.upFrontAmount,
    this.creditAdminTax,
    this.firstQuotaDate,
    this.isFinancialProduct,
    this.hasSignature,
    this.hasPrintedClientReceipt,
    this.hasWarranty,
    this.applicationName,
    this.interestAmount,
    this.changeAmount,
    this.serviceTax,
    this.cityState,
    this.hasSentReference,
    this.v40Code,
    this.secondaryProductName,
    this.paymentTransactionId,
    this.avaiableBalance,
    this.pan,
    this.originalTransactionId,
    this.originalTransactionDate,
    this.secondaryProductCode,
    this.hasSentMerchantCode,
    this.documentType,
    this.statusCode,
    this.merchantAddress,
    this.merchantCode,
    this.paymentTypeCode,
    this.hasConnectivity,
    this.productName,
    this.merchantName,
    this.entranceMode,
    this.firstQuotaAmount,
    this.cardCaptureType,
    this.totalizerCode,
    this.requestDate,
    this.boardingTax,
    this.applicationId,
    this.numberOfQuotas,
    this.document,
  });

  factory OrderPaymentFields.fromMap(Map<String, dynamic> map) {
    return OrderPaymentFields(
      isDoubleFontPrintAllowed:
          map['isDoubleFontPrintAllowed'] == "true",
      hasPassword: map['hasPassword'] == "true",
      primaryProductCode: map['primaryProductCode'],
      isExternalCall: map['isExternalCall'] == "true",
      primaryProductName: map['primaryProductName'],
      receiptPrintPermission: map['receiptPrintPermission'],
      isOnlyIntegrationCancelable:
          map['isOnlyIntegrationCancelable'] == "true",
      upFrontAmount: map['upFrontAmount'],
      creditAdminTax: map['creditAdminTax'],
      firstQuotaDate: map['firstQuotaDate'],
      isFinancialProduct: map['isFinancialProduct'] == "true",
      hasSignature: map['hasSignature'] == "true",
      hasPrintedClientReceipt: map['hasPrintedClientReceipt'] == "false"
          ? false
          : true,
      hasWarranty: map['hasWarranty'] == "true",
      applicationName: map['applicationName'],
      interestAmount: map['interestAmount'],
      changeAmount: map['changeAmount'],
      serviceTax: map['serviceTax'],
      cityState: map['cityState'],
      hasSentReference: map['hasSentReference'] == "true",
      v40Code: map['v40Code'],
      secondaryProductName: map['secondaryProductName'],
      paymentTransactionId: map['paymentTransactionId'],
      avaiableBalance: map['avaiableBalance'],
      pan: map['pan'],
      originalTransactionId: map['originalTransactionId'],
      originalTransactionDate: map['originalTransactionDate'],
      secondaryProductCode: map['secondaryProductCode'],
      hasSentMerchantCode: map['hasSentMerchantCode'] == "true",
      documentType: map['documentType'],
      statusCode: map['statusCode'],
      merchantAddress: map['merchantAddress'],
      merchantCode: map['merchantCode'],
      paymentTypeCode: map['paymentTypeCode'],
      hasConnectivity: map['hasConnectivity'] == "true",
      productName: map['productName'],
      merchantName: map['merchantName'],
      entranceMode: map['entranceMode'],
      firstQuotaAmount: map['firstQuotaAmount'],
      cardCaptureType: map['cardCaptureType'],
      totalizerCode: map['totalizerCode'],
      requestDate: map['requestDate'],
      boardingTax: map['boardingTax'],
      applicationId: map['applicationId'],
      numberOfQuotas: map['numberOfQuotas'],
      document: map['document'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isDoubleFontPrintAllowed': isDoubleFontPrintAllowed.toString(),
      'hasPassword': hasPassword.toString(),
      'primaryProductCode': primaryProductCode,
      'isExternalCall': isExternalCall.toString(),
      'primaryProductName': primaryProductName,
      'receiptPrintPermission': receiptPrintPermission,
      'isOnlyIntegrationCancelable':
          isOnlyIntegrationCancelable.toString(),
      'upFrontAmount': upFrontAmount,
      'creditAdminTax': creditAdminTax,
      'firstQuotaDate': firstQuotaDate,
      'isFinancialProduct': isFinancialProduct.toString(),
      'hasSignature': hasSignature.toString(),
      'hasPrintedClientReceipt': hasPrintedClientReceipt.toString(),
      'hasWarranty': hasWarranty.toString(),
      'applicationName': applicationName,
      'interestAmount': interestAmount,
      'changeAmount': changeAmount,
      'serviceTax': serviceTax,
      'cityState': cityState,
      'hasSentReference': hasSentReference.toString(),
      'v40Code': v40Code,
      'secondaryProductName': secondaryProductName,
      'paymentTransactionId': paymentTransactionId,
      'avaiableBalance': avaiableBalance,
      'pan': pan,
      'originalTransactionId': originalTransactionId,
      'originalTransactionDate': originalTransactionDate,
      'secondaryProductCode': secondaryProductCode,
      'hasSentMerchantCode': hasSentMerchantCode.toString(),
      'documentType': documentType,
      'statusCode': statusCode,
      'merchantAddress': merchantAddress,
      'merchantCode': merchantCode,
      'paymentTypeCode': paymentTypeCode,
      'hasConnectivity': hasConnectivity.toString(),
      'productName': productName,
      'merchantName': merchantName,
      'entranceMode': entranceMode,
      'firstQuotaAmount': firstQuotaAmount,
      'cardCaptureType': cardCaptureType,
      'totalizerCode': totalizerCode,
      'requestDate': requestDate,
      'boardingTax': boardingTax,
      'applicationId': applicationId,
      'numberOfQuotas': numberOfQuotas,
      'document': document,
    };
  }
}
