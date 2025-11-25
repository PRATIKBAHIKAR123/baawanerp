enum InvoiceType {
  salesInvoice,
  cashInvoice,
  saleReturn,
  salesQuotation,
  salesOrder,
  performaInvoice,
  salesChalan,
  purchaseOrder,
  purchaseInvoice,
  purchaseReturn,
  purchaseQuotation,
  openingStock,
  transferedInStock,
  transferedOutStock,
  adjustedStock,
  purchaseChallan,
  paymentVoucher,
  receiptVoucher,
  journalVoucher,
  contraVoucher,
  absoluteStock,
  salesEnquiry,
  paymentOpenBrc,
  receiptOpenBrc,
  costing,
  materialSlip,
  materialIn,
  materialOut,
  salesChallanReturn,
  purchaseChallanReturn,
  barcode,
  cancelDocument,
  internalOrderGenerate,
  qcGrn,
  qcProduction,
  jobWorkCustomerChallanIn,
  jobWorkCustomerChallanOut,
  jobWorkSupplierChallanIn,
  jobWorkSupplierChallanOut,
  readyProductionSlip,
  mfgOrderSlip,
  packingSlip,
  consumeRawMaterial,
  dismantleEntry,
  jobWorkOrder,
  marketingExpenseVoucher,
  focVoucher,
  replacementOutVoucher,
  capStockVoucher,
  scrapStockVoucher,
  stockAdjustment,
  goodsReceiptNote,
  purchaseRequest,
  opening,
  paymentOpenBRC,
  receiptOpenBRC,
  goodsReceiptNoteReturn,
  qcGRN,
}

// invoice_types.dart

extension InvoiceTypeExtension on InvoiceType {
  String get name {
    switch (this) {
      case InvoiceType.salesInvoice:
        return 'sales-invoice';
      case InvoiceType.cashInvoice:
        return 'cash-invoice';
      case InvoiceType.saleReturn:
        return 'sale-return';
      case InvoiceType.salesQuotation:
        return 'sales-quotation';
      case InvoiceType.salesOrder:
        return 'sales-order';
      case InvoiceType.performaInvoice:
        return 'performa-invoice';
      case InvoiceType.salesChalan:
        return 'sales-chalan';
      case InvoiceType.purchaseOrder:
        return 'purchase-order';
      case InvoiceType.purchaseInvoice:
        return 'purchase-invoice';
      case InvoiceType.purchaseReturn:
        return 'purchase-return';
      case InvoiceType.purchaseQuotation:
        return 'purchase-quotation';
      case InvoiceType.openingStock:
        return 'opening-stock';
      case InvoiceType.transferedInStock:
        return 'transfered-in-stock';
      case InvoiceType.transferedOutStock:
        return 'transfered-out-stock';
      case InvoiceType.adjustedStock:
        return 'adjusted-stock';
      case InvoiceType.purchaseChallan:
        return 'purchase-challan';
      case InvoiceType.paymentVoucher:
        return 'payment-voucher';
      case InvoiceType.receiptVoucher:
        return 'receipt-voucher';
      case InvoiceType.journalVoucher:
        return 'journal-voucher';
      case InvoiceType.contraVoucher:
        return 'contra-voucher';
      case InvoiceType.absoluteStock:
        return 'absolute-stock';
      case InvoiceType.salesEnquiry:
        return 'sales-enquiry';
      case InvoiceType.paymentOpenBrc:
        return 'payment-open-brc';
      case InvoiceType.receiptOpenBrc:
        return 'receipt-open-brc';
      case InvoiceType.costing:
        return 'costing';
      case InvoiceType.materialSlip:
        return 'material-slip';
      case InvoiceType.materialIn:
        return 'material-in';
      case InvoiceType.materialOut:
        return 'material-out';
      case InvoiceType.salesChallanReturn:
        return 'sales-challan-return';
      case InvoiceType.purchaseChallanReturn:
        return 'purchase-challan-return';
      case InvoiceType.barcode:
        return 'barcode';
      case InvoiceType.cancelDocument:
        return 'cancel-document';
      case InvoiceType.internalOrderGenerate:
        return 'internal-order-generate';
      case InvoiceType.qcGrn:
        return 'qc-grn';
      case InvoiceType.qcProduction:
        return 'qc-production';
      case InvoiceType.jobWorkCustomerChallanIn:
        return 'job-work-customer-challan-in';
      case InvoiceType.jobWorkCustomerChallanOut:
        return 'job-work-customer-challan-out';
      case InvoiceType.jobWorkSupplierChallanIn:
        return 'job-work-supplier-challan-in';
      case InvoiceType.jobWorkSupplierChallanOut:
        return 'job-work-supplier-challan-out';
      case InvoiceType.readyProductionSlip:
        return 'ready-production-slip';
      case InvoiceType.mfgOrderSlip:
        return 'mfg-order-slip';
      case InvoiceType.packingSlip:
        return 'packing-slip';
      case InvoiceType.consumeRawMaterial:
        return 'consume-raw-material';
      case InvoiceType.dismantleEntry:
        return 'dismantle-entry';
      case InvoiceType.jobWorkOrder:
        return 'job-work-order';
      case InvoiceType.marketingExpenseVoucher:
        return 'marketing-expense-voucher';
      case InvoiceType.focVoucher:
        return 'foc-voucher';
      case InvoiceType.replacementOutVoucher:
        return 'replacement-out-voucher';
      case InvoiceType.capStockVoucher:
        return 'cap-stock-voucher';
      case InvoiceType.scrapStockVoucher:
        return 'scrap-stock-voucher';
      default:
        return 'unknown';
    }
  }

  int get id {
    switch (this) {
      case InvoiceType.salesInvoice:
        return 1;
      case InvoiceType.cashInvoice:
        return 2;
      case InvoiceType.saleReturn:
        return 3;
      case InvoiceType.salesQuotation:
        return 4;
      case InvoiceType.salesOrder:
        return 5;
      case InvoiceType.performaInvoice:
        return 6;
      case InvoiceType.salesChalan:
        return 7;
      case InvoiceType.purchaseOrder:
        return 8;
      case InvoiceType.purchaseInvoice:
        return 9;
      case InvoiceType.purchaseReturn:
        return 10;
      case InvoiceType.purchaseQuotation:
        return 11;
      case InvoiceType.openingStock:
        return 12;
      case InvoiceType.transferedInStock:
        return 13;
      case InvoiceType.transferedOutStock:
        return 14;
      case InvoiceType.stockAdjustment:
        return 15;
      case InvoiceType.purchaseChallan:
        return 16;
      case InvoiceType.paymentVoucher:
        return 17;
      case InvoiceType.receiptVoucher:
        return 18;
      case InvoiceType.journalVoucher:
        return 19;
      case InvoiceType.contraVoucher:
        return 20;
      case InvoiceType.absoluteStock:
        return 21;
      case InvoiceType.salesEnquiry:
        return 23;
      case InvoiceType.paymentOpenBrc:
        return 24;
      case InvoiceType.receiptOpenBrc:
        return 25;
      case InvoiceType.costing:
        return 26;
      case InvoiceType.materialSlip:
        return 27;
      case InvoiceType.materialIn:
        return 28;
      case InvoiceType.materialOut:
        return 29;
      case InvoiceType.salesChallanReturn:
        return 30;
      case InvoiceType.purchaseChallanReturn:
        return 31;
      case InvoiceType.cancelDocument:
        return 32;

      default:
        return -1;
    }
  }

  InvoiceSubtype get subtype {
    switch (this) {
      case InvoiceType.materialSlip:
        return InvoiceSubtype.Stock;
      case InvoiceType.purchaseChallan:
        return InvoiceSubtype.Purchase;
      // Add cases for other invoice types
      default:
        throw Exception('Unknown invoice type');
    }
  }

  static InvoiceType fromId(int id) {
    switch (id) {
      case 1:
        return InvoiceType.salesInvoice;
      case 2:
        return InvoiceType.cashInvoice;
      case 3:
        return InvoiceType.saleReturn;
      case 4:
        return InvoiceType.salesQuotation;
      case 5:
        return InvoiceType.salesOrder;
      case 6:
        return InvoiceType.performaInvoice;
      case 7:
        return InvoiceType.salesChalan;
      case 8:
        return InvoiceType.purchaseOrder;
      case 9:
        return InvoiceType.purchaseInvoice;
      case 10:
        return InvoiceType.purchaseReturn;
      case 11:
        return InvoiceType.purchaseQuotation;
      case 12:
        return InvoiceType.openingStock;
      case 13:
        return InvoiceType.transferedInStock;
      case 14:
        return InvoiceType.transferedOutStock;
      case 15:
        return InvoiceType.stockAdjustment;
      case 16:
        return InvoiceType.purchaseChallan;
      case 17:
        return InvoiceType.paymentVoucher;
      case 18:
        return InvoiceType.receiptVoucher;
      case 19:
        return InvoiceType.journalVoucher;
      case 20:
        return InvoiceType.contraVoucher;
      case 21:
        return InvoiceType.absoluteStock;
      case 23:
        return InvoiceType.salesEnquiry;
      case 24:
        return InvoiceType.paymentOpenBrc;
      case 25:
        return InvoiceType.receiptOpenBrc;
      case 26:
        return InvoiceType.costing;
      case 27:
        return InvoiceType.materialSlip;
      case 28:
        return InvoiceType.materialIn;
      case 29:
        return InvoiceType.materialOut;
      case 30:
        return InvoiceType.salesChallanReturn;
      case 31:
        return InvoiceType.purchaseChallanReturn;
      case 32:
        return InvoiceType.barcode;
      case 33:
        return InvoiceType.cancelDocument;
      case 34:
        return InvoiceType.internalOrderGenerate;
      case 35:
        return InvoiceType.qcGrn;
      case 36:
        return InvoiceType.qcProduction;
      case 37:
        return InvoiceType.jobWorkCustomerChallanIn;
      case 38:
        return InvoiceType.jobWorkCustomerChallanOut;
      case 39:
        return InvoiceType.jobWorkSupplierChallanIn;
      case 40:
        return InvoiceType.jobWorkSupplierChallanOut;
      case 41:
        return InvoiceType.readyProductionSlip;
      case 42:
        return InvoiceType.mfgOrderSlip;
      case 43:
        return InvoiceType.packingSlip;
      case 44:
        return InvoiceType.consumeRawMaterial;
      case 45:
        return InvoiceType.dismantleEntry;
      case 46:
        return InvoiceType.jobWorkOrder;
      case 47:
        return InvoiceType.marketingExpenseVoucher;
      case 48:
        return InvoiceType.focVoucher;
      case 49:
        return InvoiceType.replacementOutVoucher;
      case 50:
        return InvoiceType.capStockVoucher;
      case 51:
        return InvoiceType.scrapStockVoucher;
      default:
        throw ArgumentError('Invalid id');
    }
  }

  static InvoiceType fromName(String name) {
    switch (name) {
      case 'sales-invoice':
        return InvoiceType.salesInvoice;
      case 'cash-invoice':
        return InvoiceType.cashInvoice;
      case 'sale-return':
        return InvoiceType.saleReturn;
      case 'sales-quotation':
        return InvoiceType.salesQuotation;
      case 'sales-order':
        return InvoiceType.salesOrder;
      case 'performa-invoice':
        return InvoiceType.performaInvoice;
      case 'sales-chalan':
        return InvoiceType.salesChalan;
      case 'purchase-order':
        return InvoiceType.purchaseOrder;
      case 'purchase-invoice':
        return InvoiceType.purchaseInvoice;
      case 'purchase-return':
        return InvoiceType.purchaseReturn;
      case 'purchase-quotation':
        return InvoiceType.purchaseQuotation;
      case 'opening-stock':
        return InvoiceType.openingStock;
      case 'transfered-in-stock':
        return InvoiceType.transferedInStock;
      case 'transfered-out-stock':
        return InvoiceType.transferedOutStock;
      case 'adjusted-stock':
        return InvoiceType.adjustedStock;
      case 'purchase-challan':
        return InvoiceType.purchaseChallan;
      case 'payment-voucher':
        return InvoiceType.paymentVoucher;
      case 'receipt-voucher':
        return InvoiceType.receiptVoucher;
      case 'journal-voucher':
        return InvoiceType.journalVoucher;
      case 'contra-voucher':
        return InvoiceType.contraVoucher;
      case 'absolute-stock':
        return InvoiceType.absoluteStock;
      case 'sales-enquiry':
        return InvoiceType.salesEnquiry;
      case 'payment-open-brc':
        return InvoiceType.paymentOpenBrc;
      case 'receipt-open-brc':
        return InvoiceType.receiptOpenBrc;
      case 'costing':
        return InvoiceType.costing;
      case 'material-slip':
        return InvoiceType.materialSlip;
      case 'material-in':
        return InvoiceType.materialIn;
      case 'material-out':
        return InvoiceType.materialOut;
      case 'sales-challan-return':
        return InvoiceType.salesChallanReturn;
      case 'purchase-challan-return':
        return InvoiceType.purchaseChallanReturn;
      case 'barcode':
        return InvoiceType.barcode;
      case 'cancel-document':
        return InvoiceType.cancelDocument;
      case 'internal-order-generate':
        return InvoiceType.internalOrderGenerate;
      case 'qc-grn':
        return InvoiceType.qcGrn;
      case 'qc-production':
        return InvoiceType.qcProduction;
      case 'job-work-customer-challan-in':
        return InvoiceType.jobWorkCustomerChallanIn;
      case 'job-work-customer-challan-out':
        return InvoiceType.jobWorkCustomerChallanOut;
      case 'job-work-supplier-challan-in':
        return InvoiceType.jobWorkSupplierChallanIn;
      case 'job-work-supplier-challan-out':
        return InvoiceType.jobWorkSupplierChallanOut;
      case 'ready-production-slip':
        return InvoiceType.readyProductionSlip;
      case 'mfg-order-slip':
        return InvoiceType.mfgOrderSlip;
      case 'packing-slip':
        return InvoiceType.packingSlip;
      case 'consume-raw-material':
        return InvoiceType.consumeRawMaterial;
      case 'dismantle-entry':
        return InvoiceType.dismantleEntry;
      case 'job-work-order':
        return InvoiceType.jobWorkOrder;
      case 'marketing-expense-voucher':
        return InvoiceType.marketingExpenseVoucher;
      case 'foc-voucher':
        return InvoiceType.focVoucher;
      case 'replacement-out-voucher':
        return InvoiceType.replacementOutVoucher;
      case 'cap-stock-voucher':
        return InvoiceType.capStockVoucher;
      case 'scrap-stock-voucher':
        return InvoiceType.scrapStockVoucher;
      default:
        throw ArgumentError('Invalid name');
    }
  }
}

const Map<InvoiceType, String> InvoiceVoucherTypesObjByte = {
  InvoiceType.salesInvoice: "Sales Invoice",
  InvoiceType.cashInvoice: "Cash Invoice",
  InvoiceType.saleReturn: "Sale Return",
  InvoiceType.salesQuotation: "Sales Quotation",
  InvoiceType.salesOrder: "Sales Order",
  InvoiceType.performaInvoice: "Performa Invoice",
  InvoiceType.salesChalan: "Dispatch Note",
  InvoiceType.purchaseOrder: "Purchase Order",
  InvoiceType.purchaseInvoice: "Purchase Invoice",
  InvoiceType.purchaseReturn: "Purchase Return",
  InvoiceType.purchaseRequest: "Purchase Request",
  InvoiceType.openingStock: "Open Stock Voucher",
  InvoiceType.transferedInStock: "Stock In Voucher",
  InvoiceType.transferedOutStock: "Stock Out Voucher",
  InvoiceType.stockAdjustment: "Stock Adjustment",
  InvoiceType.purchaseChallan: "Goods Receipt",
  InvoiceType.paymentVoucher: "Payment Voucher",
  InvoiceType.receiptVoucher: "Receipt Voucher",
  InvoiceType.journalVoucher: "Journal Voucher",
  InvoiceType.contraVoucher: "Contra Voucher",
  InvoiceType.absoluteStock: "Absolute Stock",
  InvoiceType.opening: "Opening",
  InvoiceType.salesEnquiry: "Sales Enquiry",
  InvoiceType.paymentOpenBRC: "Payment Open BRC",
  InvoiceType.receiptOpenBRC: "Receipt Open BRC",
  InvoiceType.costing: "Costing",
  InvoiceType.materialSlip: "Material Request Slip",
  InvoiceType.materialIn: "Material In",
  InvoiceType.materialOut: "Material Out",
  InvoiceType.salesChallanReturn: "Dispatch Note Return",
  InvoiceType.goodsReceiptNoteReturn: "Goods Receipt Note Return",
  InvoiceType.barcode: "Barcode",
  InvoiceType.purchaseChallanReturn: "Goods Receipt Return",
  InvoiceType.cancelDocument: "Cancel Document",
  InvoiceType.internalOrderGenerate: "Internal Order Generate",
  InvoiceType.qcGRN: "QC GRN",
  InvoiceType.qcProduction: "QC Production",
  InvoiceType.jobWorkCustomerChallanIn: "Job work Customer Challan In",
  InvoiceType.jobWorkCustomerChallanOut: "Job work Customer Challan Out",
  InvoiceType.jobWorkSupplierChallanIn: "Job work Supplier Challan In",
  InvoiceType.jobWorkSupplierChallanOut: "Job work Supplier Challan Out",
  InvoiceType.readyProductionSlip: "Ready Production Slip",
  InvoiceType.mfgOrderSlip: "Mfg Order Slip",
  InvoiceType.packingSlip: "Packing slip",
  InvoiceType.consumeRawMaterial: "Consume Raw Material",
  InvoiceType.dismantleEntry: "Dismantle Entry",
  InvoiceType.jobWorkOrder: "JOB Work Order",
  InvoiceType.marketingExpenseVoucher: "Marketing Expense Voucher",
  InvoiceType.focVoucher: "FOC Voucher",
  InvoiceType.replacementOutVoucher: "Replacement Out Voucher",
  InvoiceType.capStockVoucher: "CAP Stock Voucher",
  InvoiceType.scrapStockVoucher: "Scrap Stock Voucher",
};

enum InvoiceSubtype {
  Stock,
  Purchase,
  // Add other subtypes here
}

enum ActionType {
  list,
  newAction, // 'new' is a reserved keyword in Dart, renaming it to 'newAction'
  edit,
}

extension InvoiceTypeExtension2 on InvoiceType {
  String getBreadcrumbTitle1() {
    switch (this) {
      case InvoiceType.salesInvoice:
      case InvoiceType.cashInvoice:
      case InvoiceType.salesQuotation:
      case InvoiceType.salesEnquiry:
      case InvoiceType.salesOrder:
      case InvoiceType.salesChalan:
      case InvoiceType.performaInvoice:
      case InvoiceType.saleReturn:
      case InvoiceType.salesChallanReturn:
        return 'Sales';
      case InvoiceType.purchaseOrder:
      case InvoiceType.purchaseChallan:
      case InvoiceType.purchaseInvoice:
      case InvoiceType.purchaseReturn:
      case InvoiceType.costing:
      case InvoiceType.purchaseChallanReturn:
      case InvoiceType.purchaseQuotation:
        return 'Purchase';
      case InvoiceType.openingStock:
      case InvoiceType.transferedInStock:
      case InvoiceType.transferedOutStock:
      case InvoiceType.materialSlip:
      case InvoiceType.materialIn:
      case InvoiceType.materialOut:
      case InvoiceType.stockAdjustment:
      case InvoiceType.barcode:
        return 'Inventory';
      case InvoiceType.internalOrderGenerate:
        return 'Production House';
      default:
        return '';
    }
  }

  String getBreadcrumbTitle2() {
    switch (this) {
      case InvoiceType.salesInvoice:
        return 'Sales Invoice';
      case InvoiceType.cashInvoice:
        return 'Sales Cash Invoice';
      case InvoiceType.salesQuotation:
        return 'Sales Quotation';
      case InvoiceType.salesEnquiry:
        return 'Sales Enquiry';
      case InvoiceType.salesOrder:
        return 'Sales Order';
      case InvoiceType.salesChalan:
        return 'Dispatch Note';
      case InvoiceType.performaInvoice:
        return 'Proforma Invoice';
      case InvoiceType.saleReturn:
        return 'Sales Return';
      case InvoiceType.purchaseOrder:
        return 'Purchase Order';
      case InvoiceType.purchaseChallan:
        return 'Goods Receipt Note';
      case InvoiceType.purchaseInvoice:
        return 'Purchase Invoice';
      case InvoiceType.purchaseReturn:
        return 'Purchase Return';
      case InvoiceType.costing:
        return 'Costing';
      case InvoiceType.openingStock:
        return 'Open Stock Voucher';
      case InvoiceType.transferedInStock:
        return 'Intra Transfer Stock In';
      case InvoiceType.transferedOutStock:
        return 'Intra Transfer Stock Out';
      case InvoiceType.materialSlip:
        return 'Material Request Slip';
      case InvoiceType.materialIn:
        return 'Material In';
      case InvoiceType.materialOut:
        return 'Material Out';
      case InvoiceType.stockAdjustment:
        return 'Stock Adjustment';
      case InvoiceType.salesChallanReturn:
        return 'Dispatch Note Return';
      case InvoiceType.purchaseChallanReturn:
        return 'Goods Receipt Note Return';
      case InvoiceType.purchaseQuotation:
        return 'Purchase Request';
      case InvoiceType.barcode:
        return 'Barcode Generate';
      case InvoiceType.internalOrderGenerate:
        return 'Internal Order Generate';
      default:
        return '';
    }
  }

  Map<String, String> getValuesForAction(ActionType action) {
    switch (this) {
      case InvoiceType.salesInvoice:
      case InvoiceType.cashInvoice:
      case InvoiceType.salesQuotation:
      case InvoiceType.salesEnquiry:
      case InvoiceType.salesOrder:
      case InvoiceType.salesChalan:
      case InvoiceType.performaInvoice:
      case InvoiceType.saleReturn:
      case InvoiceType.purchaseOrder:
      case InvoiceType.purchaseChallan:
      case InvoiceType.purchaseInvoice:
      case InvoiceType.purchaseReturn:
      case InvoiceType.costing:
      case InvoiceType.openingStock:
      case InvoiceType.transferedInStock:
      case InvoiceType.transferedOutStock:
      case InvoiceType.materialSlip:
      case InvoiceType.materialIn:
      case InvoiceType.materialOut:
      case InvoiceType.stockAdjustment:
      case InvoiceType.salesChallanReturn:
      case InvoiceType.purchaseChallanReturn:
      case InvoiceType.purchaseQuotation:
      case InvoiceType.barcode:
      case InvoiceType.internalOrderGenerate:
        return {
          'list': 'List',
          'new': 'New',
          'edit': 'Edit',
        };
      default:
        return {};
    }
  }
}

extension ActionTypeExtension on ActionType {
  String getPageTitle(InvoiceType type) {
    final baseTitle = type.getBreadcrumbTitle2();
    switch (this) {
      case ActionType.list:
        return baseTitle;
      case ActionType.newAction:
        return 'Create New $baseTitle';
      case ActionType.edit:
        return '$baseTitle Info';
      default:
        return '';
    }
  }

  String getBreadcrumbTitle3() {
    switch (this) {
      case ActionType.list:
        return 'List';
      case ActionType.newAction:
        return 'New';
      case ActionType.edit:
        return 'Edit';
      default:
        return '';
    }
  }
}

extension LabelsExtension on InvoiceType {
  String getBillNoLabel() {
    switch (this) {
      case InvoiceType.salesInvoice:
      case InvoiceType.cashInvoice:
        return 'Sale Bill No.';
      case InvoiceType.salesQuotation:
        return 'Sale Qtn. No.';
      case InvoiceType.salesEnquiry:
        return 'Sales Enq. No.';
      case InvoiceType.salesOrder:
        return 'Sales Order No.';
      case InvoiceType.salesChalan:
        return 'Challan No.';
      case InvoiceType.performaInvoice:
        return 'PF Inv. No.';
      case InvoiceType.saleReturn:
        return 'Sale Return No.';
      case InvoiceType.purchaseOrder:
        return 'Pur.Order No.';
      case InvoiceType.purchaseChallan:
        return 'GRN No.';
      case InvoiceType.purchaseInvoice:
        return 'Pur.Inv.No.';
      case InvoiceType.purchaseReturn:
        return 'Pur.Return No.';
      case InvoiceType.costing:
        return 'Costing No.';
      case InvoiceType.openingStock:
        return 'Open Stock No.';
      case InvoiceType.transferedInStock:
        return 'Stock In No.';
      case InvoiceType.transferedOutStock:
        return 'Stock Out No.';
      case InvoiceType.materialSlip:
        return 'Mat.Req.Slip No.';
      case InvoiceType.materialIn:
        return 'Mat.In No.';
      case InvoiceType.materialOut:
        return 'Mat.Out No.';
      case InvoiceType.stockAdjustment:
        return 'Stock Adj. No.';
      case InvoiceType.salesChallanReturn:
        return 'Challan Return No.';
      case InvoiceType.purchaseChallanReturn:
        return 'GRN Return No.';
      case InvoiceType.purchaseQuotation:
        return 'Pur. Req. Qtn. No.';
      case InvoiceType.barcode:
        return 'Barcode Gen. No.';
      case InvoiceType.internalOrderGenerate:
        return 'Int. Order Gen. No.';
      case InvoiceType.readyProductionSlip:
        return 'Production Slip No.';
      case InvoiceType.consumeRawMaterial:
        return 'Consume RM. Slip No.';
      default:
        return '';
    }
  }

  String getLedgerLabel() {
    switch (this) {
      case InvoiceType.salesInvoice:
      case InvoiceType.cashInvoice:
      case InvoiceType.salesQuotation:
      case InvoiceType.salesEnquiry:
      case InvoiceType.salesOrder:
      case InvoiceType.salesChalan:
      case InvoiceType.performaInvoice:
      case InvoiceType.saleReturn:
      case InvoiceType.salesChallanReturn:
      case InvoiceType.readyProductionSlip:
      case InvoiceType.consumeRawMaterial:
        return 'Customer Name';
      case InvoiceType.purchaseOrder:
      case InvoiceType.purchaseChallan:
      case InvoiceType.purchaseInvoice:
      case InvoiceType.purchaseReturn:
      case InvoiceType.costing:
      case InvoiceType.purchaseChallanReturn:
      case InvoiceType.purchaseQuotation:
        return 'Supplier Name';
      case InvoiceType.openingStock:
      case InvoiceType.transferedInStock:
      case InvoiceType.transferedOutStock:
      case InvoiceType.materialSlip:
      case InvoiceType.materialIn:
      case InvoiceType.materialOut:
      case InvoiceType.stockAdjustment:
      case InvoiceType.barcode:
        return 'Stock Ledger';
      case InvoiceType.internalOrderGenerate:
        return 'Customer Name';
      default:
        return '';
    }
  }
}
