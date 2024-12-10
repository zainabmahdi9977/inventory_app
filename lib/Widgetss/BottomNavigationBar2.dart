import 'package:flutter/material.dart';

class BottomNavigationBar2 extends StatelessWidget {
  final VoidCallback onPressed1;
  final VoidCallback onPressed2;
  final String Label1;
  final String Label2;

  const BottomNavigationBar2({
    Key? key,
    required this.onPressed1,
    required this.onPressed2,
    required this.Label1,
    required this.Label2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 80,
            child: ElevatedButton(
              onPressed: onPressed1,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF59c0d2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                Label1,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 80,
            child: ElevatedButton(
              onPressed: onPressed2,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF59c0d2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                Label2,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BottomNavigationBar3 extends StatelessWidget {
  final VoidCallback onPressed1;
  final VoidCallback onPressed2;
    final VoidCallback onPressed3;
  final String Label1;
  final String Label2;
    final String LabeL3;
 final bool isCommitEnabled;

  const BottomNavigationBar3({
    Key? key,
    required this.onPressed1,
    required this.onPressed2,
    required this.Label1,
    required this.Label2, required this.onPressed3, required this.LabeL3, required this.isCommitEnabled, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
         isCommitEnabled ? 
Expanded(
          child: SizedBox(
            height: 80,
            child: ElevatedButton(
              
              onPressed: onPressed1 , 
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: isCommitEnabled
                    ? const Color(0xFF59c0d2)
                    : const Color.fromARGB(255, 149, 209, 240), 
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                Label1,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ):SizedBox(),
        Expanded(
          child: SizedBox(
            height: 80,
            child: ElevatedButton(
              onPressed: onPressed2,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF59c0d2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                Label2,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ),
             Expanded(
          child: SizedBox(
            height: 80,
            child: ElevatedButton(
              onPressed: onPressed3,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF59c0d2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                LabeL3,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
