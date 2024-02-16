{
    "description": "[Left_command] == left_command | homerow tags | search to click",
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
                    "key_code": "left_arrow",
                    "modifiers": [
                        "right_shift",
                        "right_control",
                        "right_option"
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
                    "key_code": "right_arrow",
                    "modifiers": [
                        "right_shift",
                        "right_control",
                        "right_option"
                    ]
                }
            ],
            "type": "basic"
        }
    ]
}