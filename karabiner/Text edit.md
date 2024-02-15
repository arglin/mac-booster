```json
{
    "description": "[TrackPad 1 finger touch + (shift)+ |0|-|+|tab|q|w|e|r|t|y|u|i|a|s|d|f|g|z|x|c|v|b|n|m]",
    "manipulators": [
        {
            "conditions": [
                {
                    "name": "multitouch_extension_finger_count_total",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "q"
            },
            "to": [
                {
                    "key_code": "right_arrow",
                    "modifiers": [
                        "left_command"
                    ]
                },
                {
                    "key_code": "delete_or_backspace",
                    "modifiers": [
                        "left_command"
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
                "key_code": "q",
                "modifiers": {
                    "mandatory": [
                        "left_shift"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "right_arrow",
                    "modifiers": [
                        "left_command"
                    ]
                },
                {
                    "key_code": "left_arrow",
                    "modifiers": [
                        "left_command",
                        "left_shift"
                    ]
                },
                {
                    "key_code": "x",
                    "modifiers": [
                        "left_command"
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
                "key_code": "w"
            },
            "to": [
                {
                    "key_code": "delete_or_backspace",
                    "modifiers": [
                        "left_option"
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
                "key_code": "w",
                "modifiers": {
                    "mandatory": [
                        "left_shift"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "delete_or_backspace",
                    "modifiers": [
                        "left_option",
                        "fn"
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
                "key_code": "a",
                "modifiers": {
                    "optional": [
                        "left_shift"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "left_arrow",
                    "modifiers": [
                        "left_command"
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
                "key_code": "i",
                "modifiers": {
                    "optional": [
                        "left_shift"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "right_arrow",
                    "modifiers": [
                        "left_command"
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
                "key_code": "r"
            },
            "to": [
                {
                    "key_code": "z",
                    "modifiers": [
                        "left_command",
                        "left_shift"
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
                "key_code": "t",
                "modifiers": {
                    "optional": [
                        "left_shift"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "up_arrow",
                    "modifiers": [
                        "left_command"
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
                "key_code": "y"
            },
            "to": [
                {
                    "key_code": "a",
                    "modifiers": [
                        "left_control"
                    ]
                },
                {
                    "key_code": "e",
                    "modifiers": [
                        "left_control",
                        "left_shift"
                    ]
                },
                {
                    "key_code": "c",
                    "modifiers": [
                        "left_command"
                    ]
                },
                {
                    "key_code": "e",
                    "modifiers": [
                        "left_control"
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
                "key_code": "y",
                "modifiers": {
                    "mandatory": [
                        "left_shift"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "a",
                    "modifiers": [
                        "left_command"
                    ]
                },
                {
                    "key_code": "c",
                    "modifiers": [
                        "left_command"
                    ]
                },
                {
                    "key_code": "right_arrow"
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
                "key_code": "u"
            },
            "to": [
                {
                    "key_code": "z",
                    "modifiers": [
                        "left_command"
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
                "key_code": "s"
            },
            "to": [
                {
                    "key_code": "delete_or_backspace"
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
                "key_code": "x"
            },
            "to": [
                {
                    "key_code": "delete_or_backspace",
                    "modifiers": [
                        "fn"
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
                "key_code": "d"
            },
            "to": [
                {
                    "key_code": "delete_or_backspace",
                    "modifiers": [
                        "left_command"
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
                "key_code": "c"
            },
            "to": [
                {
                    "key_code": "right_arrow",
                    "modifiers": [
                        "left_command",
                        "left_shi "
                    ]
                },
                {
                {
                    "key_code": "delete_or_backspace"
                }
            ]
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
                "key_code": "b",
                "modifiers": {
                    "optional": [
                        "left_shift"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "left_arrow",
                    "modifiers": [
                        "left_option"
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
                "key_code": "e",
                "modifiers": {
                    "optional": [
                        "left_shift"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "right_arrow",
                    "modifiers": [
                        "left_option"
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
                "key_code": "g",
                "modifiers": {
                    "optional": [
                        "left_shift"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "down_arrow",
                    "modifiers": [
                        "left_command"
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
                "key_code": "o"
            },
            "to": [
                {
                    "key_code": "e",
                    "modifiers": [
                        "left_control"
                    ]
                },
                {
                    "key_code": "return_or_enter",
                    "modifiers": [
                        "left_shift"
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
                "key_code": "o",
                "modifiers": {
                    "mandatory": ["left_shift"]
                }
            },
            "to": [
                {
                    "key_code": "a",
                    "modifiers": [
                    "left_control"
                    ]
                },
                {
                    "key_code": "return_or_enter",
                    "modifiers": [
                    "left_shift"
                    ]
                },
                {
                    "key_code": "up_arrow"
                }
            ],
            "type": "basic"
        }
    ]
}
```
