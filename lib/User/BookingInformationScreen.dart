import 'package:flutter/material.dart';

class BookingInformationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> bookingHistory = [
    {
      'id': 'TS09 FH XXXX',
      'status': 'InActive',
      'amount': '\$25.00',
      'date': '10 July 2024',
      'time': '10:50 AM ~ 06:20 PM',
      'isActive': true,
    },
    {
      'id': 'TS09 FH XXXX',
      'status': 'InActive',
      'amount': '\$25.00',
      'date': '10 July 2024',
      'time': '10:50 AM ~ 06:20 PM',
      'isActive': false,
    },
    // Add more items as needed
    {
      'id': 'TS10 FH XXXX',
      'status': 'InActive',
      'amount': '\$55.00',
      'date': '10 July 2024',
      'time': '11:50 AM ~ 06:20 PM',
      'isActive': false,
    },
    {
      'id': 'TS11 FH XXXX',
      'status': 'InActive',
      'amount': '\$65.00',
      'date': '10 July 2024',
      'time': '12:50 AM ~ 06:20 PM',
      'isActive': false,
    },
    {
      'id': 'TS12 FH XXXX',
      'status': 'InActive',
      'amount': '\$75.00',
      'date': '10 July 2024',
      'time': '10:50 AM ~ 06:20 PM',
      'isActive': false,
    },
    {
      'id': 'TS13 FH XXXX',
      'status': 'InActive',
      'amount': '\$85.00',
      'date': '10 July 2024',
      'time': '10:50 AM ~ 06:20 PM',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Booking Details', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            color: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoCard('Parking ID:', '#5416568'),
                _infoCard('Amount:', '\$2250.00'),
              ],
            ),
          ),
          // Booking History Section
          Expanded(
            child: ListView.builder(
              itemCount: bookingHistory.length,
              itemBuilder: (context, index) {
                final item = bookingHistory[index];
                return _bookingHistoryCard(
                  id: item['id'],
                  status: item['status'],
                  amount: item['amount'],
                  date: item['date'],
                  time: item['time'],
                  isActive: item['isActive'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontSize: 12)),
          SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _bookingHistoryCard({
    required String id,
    required String status,
    required String amount,
    required String date,
    required String time,
    required bool isActive,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    id,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    amount,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Parking Status',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.orange : Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontSize: 12,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
