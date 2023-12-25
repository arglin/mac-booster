```json
{
    "description": "[Caps Lock] == right(cmd+ctl+opt) | Escape if alone | cmd+w 1 finger trackpad",
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
                "key_code": "caps_lock",
                "modifiers": {
                    "optional": [
                        "any"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "right_option",
                    "lazy": true,
                    "modifiers": [
                        "right_option",
                        "right_command",
                        "right_control"
                    ]
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "escape"
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
                "key_code": "caps_lock",
                "modifiers": {
                    "optional": [
                        "any"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "right_option",
                    "lazy": true,
                    "modifiers": [
                        "right_option",
                        "right_command",
                        "right_control"
                    ]
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "w",
                    "lazy": true,
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