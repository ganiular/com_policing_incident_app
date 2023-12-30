// crime_detail_page.dart

// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:com_policing_incident_app/models/get-models/crime_report.dart';
import 'package:com_policing_incident_app/providers/persistance_data/preferences.dart';
import 'package:com_policing_incident_app/providers/persistance_data/user_adapter.dart';
import 'package:com_policing_incident_app/services/config.dart';
import 'package:com_policing_incident_app/utilities/global_variables.dart';
import 'package:com_policing_incident_app/utilities/http_error_handling.dart';
import 'package:com_policing_incident_app/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CrimeDetailPage extends StatefulWidget {
  final CrimeData crimeData;

  CrimeDetailPage({required this.crimeData});

  @override
  State<CrimeDetailPage> createState() => _CrimeDetailPageState();
}

class _CrimeDetailPageState extends State<CrimeDetailPage> {
  final requestBaseUrl = Config.AuthBaseUrl;

  Future<void> deleteData(BuildContext context) async {
    // Confirm deletion
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this report?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      String url = '$requestBaseUrl/crime/${widget.crimeData.id}';

      final preferences = await Preferences.getInstance();
      String? token = await preferences.getAccessToken();

      final requestHeaders = {
        'Accept': 'application/vnd.api+json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      try {
        http.Response response =
            await http.delete(Uri.parse(url), headers: requestHeaders);

        if (response.statusCode == 200) {
          // Successful deletion
          final responseData = json.decode(response.body)['message'];
          utils.successShowToast(context, responseData);
        } else {
          // Handle errors
          final responseData = json.decode(response.body)['message'];
          utils.showToast(context, responseData);
        }
      } catch (error) {
        print('Error during DELETE request: $error');
        utils.showToast(context, '$error');
      }
    }
  }

  void copyToClipboard(String text) {
    FlutterClipboard.copy(text).then((result) {
      Fluttertoast.showToast(
        msg: "Copied to clipboard",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAdapter = Provider.of<UserAdapter>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Report  Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Avatar.large(
                  img: NetworkImage('${userAdapter.user!.profilePicture}'),
                ),
                SizedBox(
                  height: 15,
                ),

                Text(
                  'Report Details',
                  style: TextStyle(
                      color: KprimaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 15,
                ),
                CrimeDetails(
                    userDetail: 'Category :',
                    userDetail2: '${widget.crimeData.category}'),
                SizedBox(
                  height: 15,
                ),
                CrimeDetails(
                    userDetail: 'Reference Number :',
                    userDetail2: '${widget.crimeData.ref}'),

                SizedBox(
                  height: 15,
                ),
                CrimeDetails(
                    userDetail: 'Details :',
                    userDetail2: '${widget.crimeData.details}'),

                SizedBox(
                  height: 15,
                ),

                CrimeDetails(
                    userDetail: 'Status :',
                    userDetail2: '${widget.crimeData.status}'),
                SizedBox(
                  height: 15,
                ),
                CrimeDetails(
                    userDetail: 'Police Unit',
                    userDetail2: '${widget.crimeData.policeUnit}'),

                SizedBox(
                  height: 15,
                ),
                CrimeDetails(
                    userDetail: 'Address :',
                    userDetail2: '${widget.crimeData.address}'),

                // Add more details as needed

                GestureDetector(
                  onTap: () {
                    deleteData(context);
                  },
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete,
                          size: 40,
                          color: Colors.red,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Delete Report',
                          style: TextStyle(
                              color: KprimaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CrimeDetails extends StatelessWidget {
  const CrimeDetails({
    super.key,
    required this.userDetail,
    required this.userDetail2,
  });

  final String userDetail;
  final String userDetail2;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text(
            userDetail,
            style: TextStyle(
                color: KprimaryColor,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(child: Text(userDetail2))
        ],
      ),
    );
  }
}
