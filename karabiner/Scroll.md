```json
{
    "title": "[TrackPad bottom 3/4 touch + hjkl hold] == left_down_up_right scroll",
    "rules": [
        {
            "description": "[TrackPad bottom 3/4 touch + hjkl hold] == left_down_up_right scroll",
            "manipulators": [
                {
                    "from": {
                        "key_code": "k", "modifiers": {
              "optional": [
                "any"
              ]
            }
                    },
                    "to": [
                        {
                            "mouse_key": {
                                "vertical_wheel": -64
                            }
                        }
                    ],
		"conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_if","name": "multitouch_extension_finger_count_upper_quarter_area","value": 0}],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "j", "modifiers": {
              "optional": [
                "any"
              ]

                    },
                    "to": [
                        {
                            "mouse_key": {
                                "vertical_wheel": 64
                            }
                        }
                    ],
"conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_if","name": "multitouch_extension_finger_count_upper_quarter_area","value": 0}],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "l", "modifiers": {
              "optional": [
                "any"
              ]

                    },
                    "to": [
                        {
                            "mouse_key": {
                                "horizontal_wheel": 64
                            }
                        }
                    ],
"conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_if","name": "multitouch_extension_finger_count_upper_quarter_area","value": 0}],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "h", "modifiers": {
              "optional": [
                "any"
              ]

                    },
                    "to": [
                        {
                            "mouse_key": {
                                "horizontal_wheel": -64
                            }
                        }
                    ],
"conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_if","name": "multitouch_extension_finger_count_upper_quarter_area","value": 0}],
                    "type": "basic"
                }
            ]
        }
    ]
}
```