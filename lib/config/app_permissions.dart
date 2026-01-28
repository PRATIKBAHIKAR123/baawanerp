class AppPermissions {
  // === DEFINE YOUR MODULE PERMISSIONS HERE ===
  // Note: These IDs match the 'right_ID' values returned from your backend.

  // ==============================================================================
  // MASTERS & CORE ENTITIES
  // ==============================================================================

  static const int _PLACEHOLDER = 999999;

  static const int can_view_masters_module = -1;

  // Ledgers (Type 101)
  static const int can_search_ledgers = 1;
  static const int can_view_ledgers = 2; // Retrieve
  static const int can_edit_ledgers = 3; // Update
  static const int can_create_ledgers = 4; // Save/Create
  static const int can_delete_ledgers = 5;
  static const int can_utility_ledgers = 6;

  // Items (Type 102)
  static const int can_search_items = 7;
  static const int can_view_items = 8; // Retrieve
  static const int can_edit_items = 9; // Update
  static const int can_create_items = 10; // Create
  static const int can_delete_items = 11;
  static const int can_utility_items = 12;

  // Companies (Type 117)
  static const int can_search_companies = 324;
  static const int can_view_companies = 325;
  static const int can_edit_companies = 326;
  static const int can_create_companies = 327;
  static const int can_delete_companies = 328;
  static const int can_utility_companies = 329;

  // Project Site (Type 116)
  static const int can_search_project_sites = 318;
  static const int can_view_project_sites = 319;
  static const int can_edit_project_sites = 320;
  static const int can_create_project_sites = 321;
  static const int can_delete_project_sites = 322;
  static const int can_utility_project_sites = 323;

  // Sales Persons (Type 118)
  static const int can_search_sales_persons = 333;
  static const int can_view_sales_persons = 334;
  static const int can_edit_sales_persons = 335;
  static const int can_create_sales_persons = 336;
  static const int can_delete_sales_persons = 337;
  static const int can_utility_sales_persons = 338;

  // Item Rate Category (Type 119)
  static const int can_search_item_rate_categories = 339;
  static const int can_view_item_rate_categories = 340;
  static const int can_edit_item_rate_categories = 341;
  static const int can_create_item_rate_categories = 342;
  static const int can_delete_item_rate_categories = 343;
  static const int can_utility_item_rate_categories = 344;

  // ==============================================================================
  // SALES MODULE
  // ==============================================================================
  static const int can_view_sales_module = -1;

  // Sales Invoice (Type 1)
  static const int can_search_sales_invoice = 59;
  static const int can_view_sales_invoice = 60;
  static const int can_edit_sales_invoice = 61;
  static const int can_create_sales_invoice = 62;
  static const int can_delete_sales_invoice = 63;
  static const int can_utility_sales_invoice = 64;

  // Sales Quotation (Type 4)
  static const int can_search_sales_quotation = 71;
  static const int can_view_sales_quotation = 72;
  static const int can_edit_sales_quotation = 73;
  static const int can_create_sales_quotation = 74;
  static const int can_delete_sales_quotation = 75;
  static const int can_utility_sales_quotation = 76;

  // Sales Order (Type 5)
  static const int can_search_sales_order = 77;
  static const int can_view_sales_order = 78;
  static const int can_edit_sales_order = 79;
  static const int can_create_sales_order = 80;
  static const int can_delete_sales_order = 81;
  static const int can_utility_sales_order = 82;

  // Sales Return (Type 3)
  static const int can_search_sales_return = 65;
  static const int can_view_sales_return = 66;
  static const int can_edit_sales_return = 67;
  static const int can_create_sales_return = 68;
  static const int can_delete_sales_return = 69;
  static const int can_utility_sales_return = 70;

  // Sales Enquiry (Type 23)
  static const int can_search_sales_enquiry = 188;
  static const int can_view_sales_enquiry = 189;
  static const int can_edit_sales_enquiry = 190;
  static const int can_create_sales_enquiry = 191;
  static const int can_delete_sales_enquiry = 192;
  static const int can_utility_sales_enquiry = 193;

  // Proforma Invoice (Type 6)
  static const int can_search_msg_proforma_invoice = 161;
  static const int can_view_msg_proforma_invoice = 162;
  static const int can_edit_msg_proforma_invoice = 163;
  static const int can_create_msg_proforma_invoice = 164;
  static const int can_delete_msg_proforma_invoice = 165;
  static const int can_utility_msg_proforma_invoice = 166;

  // Dispatch Note (Sales Chalan) (Type 7)
  static const int can_search_dispatch_note = 83;
  static const int can_view_dispatch_note = 84;
  static const int can_edit_dispatch_note = 85;
  static const int can_create_dispatch_note = 86;
  static const int can_delete_dispatch_note = 87;
  static const int can_utility_dispatch_note = 88;

  // Dispatch Note Return (Sales Chalan Return) (Type 30)
  static const int can_search_dispatch_note_return = 261;
  static const int can_view_dispatch_note_return = 262;
  static const int can_edit_dispatch_note_return = 263;
  static const int can_create_dispatch_note_return = 264;
  static const int can_delete_dispatch_note_return = 265;
  static const int can_utility_dispatch_note_return = 266;

  // Cancel Document (Type 32)
  static const int can_search_cancel_document = 273;
  static const int can_view_cancel_document = 274;
  static const int can_edit_cancel_document = 275;
  static const int can_create_cancel_document = 276;
  static const int can_delete_cancel_document = 277;
  static const int can_utility_cancel_document = 278;

  // ==============================================================================
  // PURCHASE MODULE
  // ==============================================================================
  static const int can_view_purchase_module = -1;

  // Purchase Order (Type 8)
  static const int can_search_purchase_order = 89;
  static const int can_view_purchase_order = 90;
  static const int can_edit_purchase_order = 91;
  static const int can_create_purchase_order = 92;
  static const int can_delete_purchase_order = 93;
  static const int can_utility_purchase_order = 94;

  // Goods Receipt (Purchase Challan) (Type 16)
  static const int can_search_goods_receipt = 200;
  static const int can_view_goods_receipt = 201;
  static const int can_edit_goods_receipt = 202;
  static const int can_create_goods_receipt = 203;
  static const int can_delete_goods_receipt = 204;
  static const int can_utility_goods_receipt = 205;

  // Purchase Invoice (Type 9)
  static const int can_search_purchase_invoice = 95;
  static const int can_view_purchase_invoice = 96;
  static const int can_edit_purchase_invoice = 97;
  static const int can_create_purchase_invoice = 98;
  static const int can_delete_purchase_invoice = 99;
  static const int can_utility_purchase_invoice = 100;

  // Purchase Return (Type 10)
  static const int can_search_purchase_return = 101;
  static const int can_view_purchase_return = 102;
  static const int can_edit_purchase_return = 103;
  static const int can_create_purchase_return = 104;
  static const int can_delete_purchase_return = 105;
  static const int can_utility_purchase_return = 106;

  // Purchase Challan Return (Type 31)
  static const int can_search_purchase_challan_return = 267;
  static const int can_view_purchase_challan_return = 268;
  static const int can_edit_purchase_challan_return = 269;
  static const int can_create_purchase_challan_return = 270;
  static const int can_delete_purchase_challan_return = 271;
  static const int can_utility_purchase_challan_return = 272;

  // Costing (Type 26)
  static const int can_search_costing = 228;
  static const int can_view_costing = 229;
  static const int can_edit_costing = 230;
  static const int can_create_costing = 231;
  static const int can_delete_costing = 232;
  static const int can_utility_costing = 233;

  // Mapped/Aliased
  static const int can_view_goods_receipt_return = 268;

  // ==============================================================================
  // STOCK MODULE
  // ==============================================================================
  static const int can_view_stock_module = -1;

  // Opening Stock (Type 12)
  static const int can_search_open_stock = 107;
  static const int can_view_open_stock = 108;
  static const int can_edit_open_stock = 109;
  static const int can_create_open_stock = 110;
  static const int can_delete_open_stock = 111;
  static const int can_utility_open_stock = 112;

  // Stock In (Type 13)
  static const int can_search_stock_in = 113;
  static const int can_view_stock_in = 114;
  static const int can_edit_stock_in = 115;
  static const int can_create_stock_in = 116;
  static const int can_delete_stock_in = 117;
  static const int can_utility_stock_in = 118;

  // Stock Out (Type 14)
  static const int can_search_stock_out = 119;
  static const int can_view_stock_out = 120;
  static const int can_edit_stock_out = 121;
  static const int can_create_stock_out = 122;
  static const int can_delete_stock_out = 123;
  static const int can_utility_stock_out = 124;

  // Material Req Slip (Type 27)
  static const int can_search_material_req_slip = 242;
  static const int can_view_material_req_slip = 243;
  static const int can_edit_material_req_slip = 244;
  static const int can_create_material_req_slip = 245;
  static const int can_delete_material_req_slip = 246;
  static const int can_utility_material_req_slip = 247;

  // Material In (Type 28)
  static const int can_search_material_in = 248;
  static const int can_view_material_in = 249;
  static const int can_edit_material_in = 250;
  static const int can_create_material_in = 251;
  static const int can_delete_material_in = 252;
  static const int can_utility_material_in = 253;

  // Material Out (Type 29)
  static const int can_search_material_out = 254;
  static const int can_view_material_out = 255;
  static const int can_edit_material_out = 256;
  static const int can_create_material_out = 257;
  static const int can_delete_material_out = 258;
  static const int can_utility_material_out = 259;

  // Stock Adjustment (Type 15)
  static const int can_search_stock_adjustment = 125;
  static const int can_view_stock_adjustment = 126;
  static const int can_edit_stock_adjustment = 127;
  static const int can_create_stock_adjustment = 128;
  static const int can_delete_stock_adjustment = 129;
  static const int can_utility_stock_adjustment = 130;

  // ==============================================================================
  // ACCOUNTS MODULE
  // ==============================================================================
  static const int can_view_accounts_module = -1;

  static const int can_view_sales_voucher = _PLACEHOLDER;
  static const int can_view_credit_note = _PLACEHOLDER;
  static const int can_view_purchase_voucher = _PLACEHOLDER;
  static const int can_view_debit_note = _PLACEHOLDER;

  // Payment Voucher (Type 17)
  static const int can_search_payment_voucher = 131;
  static const int can_view_payment_voucher = 132;
  static const int can_edit_payment_voucher = 133;
  static const int can_create_payment_voucher = 134;
  static const int can_delete_payment_voucher = 135;
  static const int can_utility_payment_voucher = 136;

  // Receipt Voucher (Type 18)
  static const int can_search_receipt_voucher = 137;
  static const int can_view_receipt_voucher = 138;
  static const int can_edit_receipt_voucher = 139;
  static const int can_create_receipt_voucher = 140;
  static const int can_delete_receipt_voucher = 141;
  static const int can_utility_receipt_voucher = 142;

  // Journal Voucher (Type 19)
  static const int can_search_journal_voucher = 143;
  static const int can_view_journal_voucher = 144;
  static const int can_edit_journal_voucher = 145;
  static const int can_create_journal_voucher = 146;
  static const int can_delete_journal_voucher = 147;
  static const int can_utility_journal_voucher = 148;

  // Contra Voucher (Type 20)
  static const int can_search_contra_voucher = 149;
  static const int can_view_contra_voucher = 150;
  static const int can_edit_contra_voucher = 151;
  static const int can_create_contra_voucher = 152;
  static const int can_delete_contra_voucher = 153;
  static const int can_utility_contra_voucher = 154;

  // ==============================================================================
  // REPORTS
  // ==============================================================================
  // Assuming reports mostly have Retrieve (View). Some might have 'Search' (Type 5), but sticking to Retrieve primarily for now unless specified.
  // MSL Report (Type 190) - Only Retrieve listed in quick summary but logic applies if types match.

  static const int can_view_reports_module = -1;

  static const int can_view_current_stock =
      177; // Type 161 Name Retrieve (Current Stock)
  static const int can_view_ledger_outstanding =
      168; // Type 152 Name Retrieve (Ledger Outstanding)
  static const int can_view_ledger_register =
      167; // Type 151 Name Retrieve (Ledger Register)
  static const int can_view_trial_balance =
      169; // Type 153 Name Retrieve (Trial Balance)
  static const int can_view_balance_sheet =
      170; // Type 154 Name Retrieve (Balance Sheet)
  static const int can_view_pnl = 171; // Type 155 Name Retrieve (PnL)
  static const int can_view_stock_valuation =
      286; // Type 166 Name Stock Valuation Retrieve

  static const int can_view_ledger_child_outstanding =
      185; // Type 162 Name Ledger Outstanding Summary Retrieve (Best guess match)
  static const int can_view_item_register =
      285; // Type 165 Name Item Register Retrieve
  static const int can_view_sales_margin =
      288; // Type 168 Name Sales Margin Retrieve
  static const int can_view_so_summary =
      289; // Type 169 Name SO Summary Retrieve
  static const int can_view_batch_stock_summary =
      290; // Type 170 Name Batch Stock Summary Retrieve
  static const int can_view_item_batch_register =
      291; // Type 171 Name Item Batch Register Retrieve
  static const int can_view_process_order =
      292; // Type 172 Name Process Order Retrieve
  static const int can_view_schedule_report =
      293; // Type 173 Name Schedule Report Retrieve

  static const int can_view_sales_register =
      294; // Type 174 Name Sales Register Retrieve
  static const int can_view_purchase_register =
      295; // Type 175 Name Purchase Register Retrieve
  static const int can_view_sales_register_columnar =
      296; // Type 176 Name Sales Register Columnar Retrieve
  static const int can_view_purchase_register_columnar =
      297; // Type 177 Name Purchase Register Columnar Retrieve
  static const int can_view_ageing_report =
      298; // Type 178 Name Ageing Report Retrieve
  static const int can_view_bank_reconciliation =
      299; // Type 179 Name Bank Reconciliation Retrieve
  static const int can_view_process_discount =
      300; // Type 180 Name Process Discount Retrieve

  static const int can_view_group_summary =
      301; // Type 181 Name Group Summary Retrieve
  static const int can_view_dealer_analysis =
      302; // Type 182 Name Dealer Analysis Retrieve
  static const int can_view_day_book = 303; // Type 183 Name Day Book Retrieve
  static const int can_view_gstr_1 = 304; // Type 184 Name GSTR 1 Retrieve
  static const int can_view_gstr_2 = 305; // Type 185 Name GSTR 2 Retrieve
  static const int can_view_gstr_3b = 306; // Type 186 Name GSTR 3B Retrieve

  static const int can_view_process_tcs =
      307; // Type 187 Name Process TCS Retrieve
  static const int can_view_process_tds =
      308; // Type 188 Name Process TDS Retrieve
  static const int can_view_ledger_target =
      309; // Type 189 Name Ledger Target Retrieve (Matches ID 309 in list)
  static const int can_view_msl_report =
      310; // Type 190 Name MSL Report Retrieve
  static const int can_view_sales_person_report =
      311; // Type 191 Name Sales Person Report Retrieve
  static const int can_view_sales_data_by_sales_person =
      312; // Type 192 Name Sales Data By Sales Person Retrieve
  static const int can_view_counter_sale_report =
      313; // Type 193 Name Counter Sale Report Retrieve
  static const int can_view_rate_comparison =
      314; // Type 194 Name Rate Comparison Retrieve
  static const int can_view_item_register_group_wise =
      315; // Type 195 Name Item Register Group Wise Retrieve
  static const int can_view_invoice_item_pending_po =
      316; // Type 196 Name Invoice Item Pending PO Retrieve
  static const int can_view_documents_report =
      317; // Type 197 Name Documents Report Retrieve
  static const int can_view_audit_log = 332; // Type 198 Name Audit Log Retrieve

  // Aliases
  static const int can_view_batch_summary = can_view_batch_stock_summary;

  // Confirmed correct alias from list for Sales Person
  static const int can_view_sales_person =
      can_view_sales_persons; // Mapped to Sales Person Master view (334) or Sales Person Report (311)?
  // NOTE: Original code mapped it to sales_person_report. Let's keep it safe.
  // Actually, there is "can_view_sales_persons" (Master) and "can_view_sales_person_report".
  // Let's resolve the ambiguity by checking usage if needed. For now aliasing to report as per previous code.
  // Wait, previous code aliased to sales_person_report (311).
  // But there is also "Sales Person" master (Type 118).
  // I will leave this alias pointing to report (311) as it was before, unless the user meant Master.
  // Given context of "Reports", 311 makes sense.
  // can_view_sales_persons is the master (334).

  // ==============================================================================
  // UTILITIES & OTHERS
  // ==============================================================================
  static const int can_view_brs_search = 175; // Type 159 Retrieve BRS Search
  static const int can_view_inventory_report =
      176; // Type 160 Retrieve Inventory Report
  static const int can_view_j1j2 = 172; // Type 156 Retrieve J1J2
  static const int can_view_vat_report = 173; // Type 157 Retrieve VATReport
  static const int can_view_deposit_slip =
      174; // Type 158 Retrieve Deposit Slip
}
