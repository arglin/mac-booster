```json
{
    "description": "[TrackPad bottom 3/4 touch + hjkl hold] == left_down_up_right scroll",
    "manipulators": [
        {
            "conditions": [
                {
                    "name": "multitouch_extension_finger_count_total",
                    "type": "variable_if",
                    "value": 1
                },
                {
                    "name": "multitouch_extension_finger_count_upper_quarter_area",
                    "type": "variable_if",
                    "value": 0
                }
            ],
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
                    "mouse_key": {
                        "vertical_wheel": -64
                    }
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "multitouch_extension_finger_count_total",
                    "type": "variable_if",
                    "value": 1
                },
                {
                    "name": "multitouch_extension_finger_count_upper_quarter_area",
                    "type": "variable_if",
                    "value": 0
                }
            ],
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
                    "mouse_key": {
                        "vertical_wheel": 64
                    }
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "multitouch_extension_finger_count_total",
                    "type": "variable_if",
                    "value": 1
                },
                {
                    "name": "multitouch_extension_finger_count_upper_quarter_area",
                    "type": "variable_if",
                    "value": 0
                }
            ],
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
                    "mouse_key": {
                        "horizontal_wheel": 64
                    }
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "multitouch_extension_finger_count_total",
                    "type": "variable_if",
                    "value": 1
                },
                {
                    "name": "multitouch_extension_finger_count_upper_quarter_area",
                    "type": "variable_if",
                    "value": 0
                }
            ],
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
                    "mouse_key": {
                        "horizontal_wheel": -64
                    }
                }
            ],
            "type": "basic"
        }
    ]
}
```