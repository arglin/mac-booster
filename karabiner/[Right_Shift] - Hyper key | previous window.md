```json
{
    "description": "[Right_Shift] == left(cmd+ctl+shift) | Switch application if alone",
    "manipulators": [
        {
            "conditions": [
                {
                    "name": "multitouch_extension_finger_count_total",
                    "type": "variable_if",
                    "value": 0
                }
            ],
            "from": {
                "key_code": "right_shift",
                "modifiers": {
                    "optional": [
                        "any"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "left_command",
                    "lazy": true,
                    "modifiers": [
                        "left_command",
                        "left_control",
                        "left_shift"
                    ]
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "y",
                    "modifiers": [
                        "right_shift",
                        "right_option",
                        "right_command"
                    ]
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
                }
            ],
            "from": {
                "key_code": "right_shift",
                "modifiers": {
                    "optional": [
                        "any"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "left_command",
                    "lazy": true,
                    "modifiers": [
                        "left_command",
                        "left_control",
                        "left_shift"
                    ]
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "grave_accent_and_tilde",
                    "modifiers": [
                        "left_command"
                    ]
                }
            ],
            "type": "basic"
        }
    ]
}
```