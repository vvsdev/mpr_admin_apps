import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:mpr_admin/screens/home_screen.dart';

class ScanQRScreen extends StatefulWidget {
  final String id;
  final String name;

  const ScanQRScreen({
    Key? key,
    required this.id,
    required this.name,
  }) : super(key: key);

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  String _scanBarcode = 'Unknown';

  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _withdrawController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = _scanBarcode;
  }

  Future<void> _scanQR() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );
      _getDataTransaction();
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
      _textEditingController.text = _scanBarcode;
    });
  }

  // Formater currency
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> updateData() async {
    // Mengambil referensi dokumen yang ingin diperbarui
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('transactions').doc(_scanBarcode);

    try {
      // Melakukan update pada nilai tertentu dalam dokumen
      await documentReference.update({
        'status': 'Berhasil',
        'admin': widget.name,
      });

      showSnackbar('Data berhasil diupdate');

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    } catch (e) {
      showSnackbar('Data gagal  diupdate $e');
    }
  }

  Future<void> _getDataTransaction() async {
    try {
      DocumentSnapshot transactionDocSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(_scanBarcode)
          .get();

      if (transactionDocSnapshot.exists) {
        Map<String, dynamic> transactionData =
            transactionDocSnapshot.data() as Map<String, dynamic>;

        Timestamp transactionTimestamp = transactionData['timestamp'];

        setState(() {
          _uidController.text = transactionData['userId'];
          _statusController.text = transactionData['status'];
          _withdrawController.text =
              formatter.format(transactionData['inoutmoney']);
          _dateController.text = DateFormat('dd MMMM yyyy, HH:mm')
              .format(transactionTimestamp.toDate());
          _typeController.text = transactionData['type'];
        });
      } else {
        showSnackbar('Transaksi tidak ditemukan');
      }
    } catch (error) {
      showSnackbar('Terjadi kesalahan: $error');
    }
  }

  // Show Snackbar
  void showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(
        seconds: 3,
      ),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    // Display the snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: const Text(
          'QR Scan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _scanQR(),
                child: const Text('Start QR scan'),
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                label: 'ID Transaksi',
                controller: _textEditingController,
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                label: 'Tipe transaksi',
                controller: _typeController,
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                label: 'Jumlah transaksi',
                controller: _withdrawController,
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                label: 'Status',
                controller: _statusController,
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                label: 'Tanggal transaksi',
                controller: _dateController,
              ),
              const SizedBox(height: 18),
              // Tombol yang akan ditampilkan berdasarkan nilai status
              Visibility(
                visible: _statusController.text ==
                    'Proses', // Tampilkan jika status adalah 'proses'
                child: GestureDetector(
                  onTap: updateData,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Proses Transaksi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade500),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade500),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
          ),
          keyboardType: TextInputType.number,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          controller: controller,
          enabled: false,
        ),
      ],
    );
  }
}
