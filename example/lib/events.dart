import 'package:flutter/material.dart';
import 'package:fullstory_flutter/fs.dart';

// Send custom events to Fullstory
// These will show up in the event list on the right side of session replays

class Events extends StatelessWidget {
  const Events({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        TextButton(
          onPressed: () => FS.event("Name-only event"),
          child: const Text("Name-only event"),
        ),
        TextButton(
          onPressed: () => FS.event("Many properties event", {
            "string_val": "a string value",
            "int_val": 42,
            "double_val": 0.1,
            "bool_val": true,
            "null_val": null,
            "list_val": [1, 2, 3],

            // in playback, this is displayed as:
            // map_val.nested_map.val_bool: true
            // map_val.nested_string_str: nested string
            "map_val": {
              "nested_string": "nested string",
              "nested_map": {"val": true},
            },
            //"mixed_list_val": [4, "a", false], // not supported, error in playback
          }),
          child: const Text("Many properties event"),
        ),
        TextButton(
          onPressed: () => FS.event('Order Completed', {
            'orderId': '23f3er3d',

            // Not fully supported(as of Fullstory v1.54.0) - The products are silently dropped:"
            // "Note: Order Completed Events are not supported in Native Mobile as objects and arrays within arrays are not supported."
            // https://help.fullstory.com/hc/en-us/articles/360020623274-Sending-custom-event-data-into-Fullstory#Order%20Completed%20Events:~:text=Note%3A%20Order%20Completed%20Events%20are%20not%20supported%20in%20Native%20Mobile%20as%20objects%20and%20arrays%20within%20arrays%20are%20not%20supported.
            'products': [
              {'productId': '9v87h4f8', 'price': 20.00, 'quantity': 0.75},
              {'productId': '4738b43z', 'price': 12.87, 'quantity': 6},
            ],
          }),
          child: const Text('Order Completed event'),
        )
      ],
    );
  }
}
