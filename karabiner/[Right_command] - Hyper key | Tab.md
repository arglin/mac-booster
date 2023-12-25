```json
{
    "description": "[Right_command] == left(cmd+ctl+opt+shift) | scroll | tab",
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
                "key_code": "right_command",
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
                        "left_option",
                        "left_shift"
                    ]
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "tab"
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
                "key_code": "right_command",
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
                        "left_option",
                        "left_shift"
                    ]
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "down_arrow",
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
