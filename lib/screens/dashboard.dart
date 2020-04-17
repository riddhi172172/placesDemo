import 'package:app/helper/config_reader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/distance.dart';
import 'package:google_maps_webservice/places.dart';

import '../helper/color_res.dart';
import '../helper/constant.dart';
import '../helper/utils.dart';
import '../injection/dependency_injection.dart';
import '../model/place.dart';
import 'phone.dart';

// Here user can add the places from the google and can see, update and delete the places.
// user can Logout here if he wants

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Places"),
        actions: <Widget>[
          // action button
          new IconButton(
            icon: new Icon(Icons.settings_power),
            onPressed: () {
              _logout();
            },
          ),
          // action button
        ],
      ),
      body: showPlaces(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showGooglePlaces(null);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }


/*
  * this function will fetch all the places created/added by this user and display it here
  * using streamBuilder
  * */
  showPlaces() {
    return StreamBuilder<QuerySnapshot>(
        stream: Injector.firestoreRef
            .collection(Const.placesCollection)
            .document(Injector.user.id)
            .collection(Const.placesCollection)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // count of events
          if (snapshot.data != null) {
            final int eventCount = snapshot.data.documents.length;
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                return new ListView.builder(
                    shrinkWrap: true,
                    itemCount: eventCount,
                    itemBuilder: (context, index) {
                      if (snapshot.data != null &&
                          snapshot.data.documents.length > 0) {
                        Place place =
                            Place.fromJson(snapshot.data.documents[index].data);

                        return showAddressItem(place);
                      } else {
                        return Container();
                      }
                    });
            }
          } else
            return Container();
        });
  }

  /*
  *  here is the address item , by long clicking item you would be able to delete 
  * the record and by click on EDIT icon you would be able to edit the record
  * */
  showAddressItem(Place place) {
    return InkResponse(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: ColorRes.avatarGlow, blurRadius: 1.5)],
          color: ColorRes.white,
        ),
        margin: EdgeInsets.only(
            left: Utils.getDeviceWidth(context) / 15,
            right: Utils.getDeviceWidth(context) / 15,
            top: Utils.getDeviceWidth(context) / 25),
        child: ListTile(
          leading: FlutterLogo(size: 72.0),
          title: Text(place.placeName ?? ""),
          subtitle: Text(place.placeName ?? ""),
          trailing: InkResponse(
            child: Icon(Icons.edit),
            onTap: () {
              showGooglePlaces(place.id);
            },
          ),
          isThreeLine: true,
          onLongPress: () {
            showConfirmDialog(place);
          },
        ),
      ),
    );
  }

/*
* user can fetch and select google places by this function
* */
  showGooglePlaces(String placeId) async {
    Prediction p = await PlacesAutocomplete.show(
        context: context,
        mode: Mode.overlay,
        apiKey: ConfigReader.getSecretKey(),
        components: [Component(Component.country, "fr")]);

  /*
  *  if it is new place then add the place in firestore otherwise update it only
  * */
    if (placeId == null) {
      Place place = Place();
      place.id = Injector.uuid.v4();
      place.placeName = p.description.toString();

      await Injector.firestoreRef
          .collection(Const.placesCollection)
          .document(Injector.user.id)
          .collection(Const.placesCollection)
          .document(place.id)
          .setData(place.toJson());
    } else {
      await Injector.firestoreRef
          .collection(Const.placesCollection)
          .document(Injector.user.id)
          .collection(Const.placesCollection)
          .document(placeId)
          .updateData({"placeName": p.description.toString()});
    }
  }

  void showConfirmDialog(Place place) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Confirm"),
          content: new Text("Are you sure want to remove this record?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () async {
                Navigator.of(context).pop();

                // delete the place of this user from the firestore
                await Injector.firestoreRef
                    .collection(Const.placesCollection)
                    .document(Injector.user.id)
                    .collection(Const.placesCollection)
                    .document(place.id)
                    .delete();
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

/*
*  perform the logout and navigate to phoneAuth page
* */
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Injector.prefs.clear();
    navigateToLogin(context);
  }

  /*
  * after logout user will navigate to Phone auth page again.
  * */
  void navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneScreen(),
        ),
        ModalRoute.withName("/dashboard"));
  }


}
