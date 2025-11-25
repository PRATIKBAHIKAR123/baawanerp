enum VoucherType {
  salesVoucher,
  creditNoteVoucher,
  purchaseVoucher,
  debitNoteVoucher,
  paymentVoucher,
  receiptVoucher,
  journalVoucher,
  contraVoucher,
}

extension VoucherTypeExtension on VoucherType {
  int get id {
    switch (this) {
      case VoucherType.salesVoucher:
        return 1;
      case VoucherType.creditNoteVoucher:
        return 3;
      case VoucherType.purchaseVoucher:
        return 9;
      case VoucherType.debitNoteVoucher:
        return 10;
      case VoucherType.paymentVoucher:
        return 17;
      case VoucherType.receiptVoucher:
        return 18;
      case VoucherType.journalVoucher:
        return 19;
      case VoucherType.contraVoucher:
        return 20;

      default:
        return -1;
    }
  }

  static VoucherType fromInt(int value) {
    switch (value) {
      case 1:
        return VoucherType.salesVoucher;
      case 3:
        return VoucherType.creditNoteVoucher;
      case 9:
        return VoucherType.purchaseVoucher;
      case 10:
        return VoucherType.debitNoteVoucher;
      case 17:
        return VoucherType.paymentVoucher;
      case 18:
        return VoucherType.receiptVoucher;
      case 19:
        return VoucherType.journalVoucher;
      case 20:
        return VoucherType.contraVoucher;
      default:
        throw ArgumentError("Invalid voucher type value: $value");
    }
  }

  String get description {
    switch (this) {
      case VoucherType.salesVoucher:
        return "Sales Voucher";
      case VoucherType.creditNoteVoucher:
        return "Credit Note Voucher";
      case VoucherType.purchaseVoucher:
        return "Purchase Voucher";
      case VoucherType.debitNoteVoucher:
        return "Debit Note Voucher";
      case VoucherType.paymentVoucher:
        return "Payment Voucher";
      case VoucherType.receiptVoucher:
        return "Receipt Voucher";
      case VoucherType.journalVoucher:
        return "Journal Voucher";
      case VoucherType.contraVoucher:
        return "Contra Voucher";
    }
  }
}
