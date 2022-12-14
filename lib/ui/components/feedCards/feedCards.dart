import 'dart:math';

import 'package:cng_mobile/data/bloc/FeedBloc.dart';
import 'package:cng_mobile/data/models/goodModel.dart';
import 'package:cng_mobile/ui/components/common/progressIndicator.dart';
import 'package:cng_mobile/ui/components/feedCards/feedCard.dart';
import 'package:flutter/material.dart';

class FeedCards extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FeedCards();
}

class _FeedCards extends State<FeedCards> {
  String status = 'stable';
  int random = 1;
  handleStart(){
    this.setState(() {
      random = Random().nextInt(3)+1;
    });
  }
  handleUpdate(DragUpdateDetails details){
    double offset = details.globalPosition.dx;
    if (offset > 225) {
      this.setState(() {
        status = 'like';
        
      });
    } else if (offset < 150) {
      this.setState(() {
        status = 'skip';
      });
    } else {
      this.setState(() {
        status = 'stable';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: StreamBuilder(
            stream: feedBloc.feed,
            builder: (context, AsyncSnapshot<List<GoodModel>> snapshot) {
              if (snapshot.hasData && snapshot.data!.length != null && snapshot.data!.length>= 2) {
                return Container(
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          height: 100,
                          width: 100,
                          child: Container(
                            child: status != 'stable' ? Image.asset('assets/'+status+'/'+random.toString()+'.png') : SizedBox(),
                          ))
                      ),
                      Draggable(
                        feedback: Positioned(
                          child: FeedCard(card: snapshot.data![0], status: status,),
                          left: 0,
                          top: 0,
                        ),
                        child: Positioned(
                          child: FeedCard(card: snapshot.data![0], status: status,),
                          left: 0,
                          top: 0,
                        ),
                        childWhenDragging: Container(),
                        axis: Axis.horizontal,
                        onDragUpdate: handleUpdate,
                        onDragStarted: handleStart,
                        onDragEnd: (d){
                              if (status == 'like') {
                                feedBloc.beaconAction(snapshot.data![0].id, true);
                              } else if (status == 'skip') {
                                feedBloc.beaconAction(snapshot.data![0].id, false);
                              }
                              
                        },
                      ),
                    ],
                  )
                );
              } else {
                return progressIndicator();
              }

            }
          )
        );
  }
}
