```json
{
  "title": "[TrackPad top 1/4 touch + hjkl] == left_down_up_right arrow",
  "rules": [
    {
      "description": "[TrackPad top 1/4 touch + hjkl] == left_down_up_right arrow",
      "manipulators": [
        {
          "from": {
            "key_code": "h",
            "modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {
              "key_code": "left_arrow"
            }
          ],
			"conditions": [
                        {
                            "type": "variable_if",
                            "name": "multitouch_extension_finger_count_upper_quarter_area",
                            "value": 1
                        }
                    ],
          "type": "basic"
        },
        {
          "from": {
            "key_code": "j",
            "modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {
              "key_code": "down_arrow"
            }
          ],
			"conditions": [
                        {
                            "type": "variable_if",
                            "name": "multitouch_extension_finger_count_upper_quarter_area",
                            "value": 1
                        }
                    ],
          "type": "basic"
        },
        {
          "from": {
            "key_code": "k",
            "modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {
              "key_code": "up_arrow"
            }
          ],
			"conditions": [
                        {
                            "type": "variable_if",
                            "name": "multitouch_extension_finger_count_upper_quarter_area",
                            "value": 1
                        }
                    ],
          "type": "basic"
        },
        {
          "from": {
            "key_code": "l",
            "modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {
              "key_code": "right_arrow"
            }
          ],
			"conditions": [
                        {
                            "type": "variable_if",
                            "name": "multitouch_extension_finger_count_upper_quarter_area",
                            "value": 1
                        }
                    ],
          "type": "basic"
        }
      ]
    }
  ]
}
```