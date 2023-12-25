```json
{
    "description": "[Left_command] == left_command | clickable tags | search to click",
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
                "key_code": "left_command",
                "modifiers": {
                    "optional": [
                        "any"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "left_command"
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "j",
                    "modifiers": [
                        "right_shift",
                        "right_control",
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
                "key_code": "left_command",
                "modifiers": {
                    "optional": [
                        "any"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "left_command"
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "up_arrow",
                    "modifiers": [
                        "right_shift",
                        "right_control",
                        "right_command"
                    ]
                }
            ],
            "type": "basic"
        }
    ]
}
```