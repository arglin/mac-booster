```json
{
    "description": "[Left_Shift] == Left_Shift | toggle stage | show desktop space",
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
                "key_code": "left_shift",
                "modifiers": {
                    "optional": [
                        "any"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "left_shift"
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "s",
                    "modifiers": [
                        "right_control",
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
                "key_code": "left_shift",
                "modifiers": {
                    "optional": [
                        "any"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "left_shift"
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "d",
                    "modifiers": [
                        "right_shift",
                        "right_option",
                        "right_command"
                    ]
                }
            ],
            "type": "basic"
        }
    ]
}
```