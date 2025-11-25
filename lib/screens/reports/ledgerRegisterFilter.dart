import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/global/styles.dart';

class LedgerRegisterFilterPopup extends StatefulWidget {
  final Function(String, String, bool, bool, bool, bool, String) onSubmit;
  final String initialFromDate;
  final String initialToDate;
  final bool initialOpeningBal;
  final bool initialRunningBal;
  final bool initialChildLedgers;
  final bool initialMonthWise;
  final String initialCrDr;

  LedgerRegisterFilterPopup({
    required this.onSubmit,
    this.initialFromDate = '',
    this.initialToDate = '',
    this.initialOpeningBal = false,
    this.initialRunningBal = false,
    this.initialChildLedgers = false,
    this.initialMonthWise = false,
    this.initialCrDr = '1',
  });

  @override
  _LedgerRegisterFilterPopupState createState() =>
      _LedgerRegisterFilterPopupState();
}

class _LedgerRegisterFilterPopupState extends State<LedgerRegisterFilterPopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  );
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  late bool isOpeningBal;
  late bool isRunningBal;
  late bool isChildLedgers;
  late bool isMonthWise;
  late String isCrDr;

  @override
  void initState() {
    super.initState();
    fromDate.text = DateFormat('dd/MM/yyyy').format(
        DateFormat('dd/MM/yyyy HH:mm:ss').parse(widget.initialFromDate!));
    toDate.text = DateFormat('dd/MM/yyyy')
        .format(DateFormat('dd/MM/yyyy HH:mm:ss').parse(widget.initialToDate!));
    isOpeningBal = widget.initialOpeningBal;
    isRunningBal = widget.initialRunningBal;
    isChildLedgers = widget.initialChildLedgers;
    isMonthWise = widget.initialMonthWise;
    isCrDr = widget.initialCrDr;
  }

  @override
  void dispose() {
    fromDate.dispose();
    toDate.dispose();
    super.dispose();
  }

  Future<void> onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime(2100),
      firstDate: DateTime(1900),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    setState(() {
      fromDate.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  Future<void> onTapToDateFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (pickedDate == null) return;

    setState(() {
      toDate.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  void submitDate() {
    String formattedFromDate =
        fromDate.text.isNotEmpty ? '${fromDate.text} 00:00:00' : '';
    String formattedToDate =
        toDate.text.isNotEmpty ? '${toDate.text} 23:59:59' : '';

    widget.onSubmit(
      formattedFromDate,
      formattedToDate,
      isOpeningBal,
      isRunningBal,
      isChildLedgers,
      isMonthWise,
      isCrDr,
    );
    Navigator.of(context).pop();

    print('fromDate: $formattedFromDate');
    print('toDate: $formattedToDate');
    print('Opening Balance Checked: $isOpeningBal');
    print('Running Balance Checked: $isRunningBal');
    print('Child Ledgers Checked: $isChildLedgers');
    print('Month Wise Checked: $isMonthWise');
    print('Selected Radio Value: $isCrDr');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Container(
        height: 420,
        width: 400,
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: fromDate,
                      decoration: InputDecoration(
                        hintText: 'From',
                        border: borderStyle,
                      ),
                      onTap: () => onTapFunction(context: context),
                    ),
                  ),
                  SizedBox(width: 16), // Add spacing between the text fields
                  Expanded(
                    child: TextFormField(
                      controller: toDate,
                      decoration: InputDecoration(
                        hintText: 'To',
                        border: borderStyle,
                      ),
                      onTap: () => onTapToDateFunction(context: context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isOpeningBal = !isOpeningBal;
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: isOpeningBal,
                      onChanged: (bool? value) {
                        setState(() {
                          isOpeningBal = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'Opening balance',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isRunningBal = !isRunningBal;
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: isRunningBal,
                      onChanged: (bool? value) {
                        setState(() {
                          isRunningBal = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'Running balance',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isChildLedgers = !isChildLedgers;
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: isChildLedgers,
                      onChanged: (bool? value) {
                        setState(() {
                          isChildLedgers = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'Child Ledgers',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isMonthWise = !isMonthWise;
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: isMonthWise,
                      onChanged: (bool? value) {
                        setState(() {
                          isMonthWise = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'Month Wise',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isCrDr = '1';
                      });
                    },
                    child: Row(
                      children: [
                        Radio<String>(
                          value: '1',
                          groupValue: isCrDr,
                          onChanged: (String? value) {
                            setState(() {
                              isCrDr = value ?? '1';
                            });
                          },
                        ),
                        Text(
                          'All',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isCrDr = '2';
                      });
                    },
                    child: Row(
                      children: [
                        Radio<String>(
                          value: '2',
                          groupValue: isCrDr,
                          onChanged: (String? value) {
                            setState(() {
                              isCrDr = value ?? '2';
                            });
                          },
                        ),
                        Text(
                          'Credit',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isCrDr = '3';
                      });
                    },
                    child: Row(
                      children: [
                        Radio<String>(
                          value: '3',
                          groupValue: isCrDr,
                          onChanged: (String? value) {
                            setState(() {
                              isCrDr = value ?? '3';
                            });
                          },
                        ),
                        Text(
                          'Debit',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                height: 42,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: mlcoGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: () {
                    submitDate();
                  },
                  child: Text(
                    "Apply Filter",
                    style: GoogleFonts.poppins(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
