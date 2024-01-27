{
    "description": "num_keyline relocate",
    "manipulators": [
        {
            "from": {
                "key_code": "backslash"
            },
            "to_after_key_up": [
                {
                    "set_variable": {
                        "name": "num_keyline_sign",
                        "value": 0
                    }
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "backslash"
                }
            ],
            "to_if_held_down": [
                {
                    "set_variable": {
                        "name": "num_keyline_sign",
                        "value": 1
                    }
                }
            ],
            "type": "basic"
        },
        {
            "from": {
                "key_code": "quote"
            },
            "to_after_key_up": [
                {
                    "set_variable": {
                        "name": "num_keyline",
                        "value": 0
                    }
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "quote"
                }
            ],
            "to_if_held_down": [
                {
                    "set_variable": {
                        "name": "num_keyline",
                        "value": 1
                    }
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "q"
            },
            "to": [
                {
                    "key_code": "2",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "q"
            },
            "to": [
                {
                    "key_code": "2"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "w"
            },
            "to": [
                {
                    "key_code": "3",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "w"
            },
            "to": [
                {
                    "key_code": "3"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "e"
            },
            "to": [
                {
                    "key_code": "4",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "e"
            },
            "to": [
                {
                    "key_code": "4"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "r"
            },
            "to": [
                {
                    "key_code": "5",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "r"
            },
            "to": [
                {
                    "key_code": "5"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "t"
            },
            "to": [
                {
                    "key_code": "1",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "t"
            },
            "to": [
                {
                    "key_code": "1"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "a"
            },
            "to": [
                {
                    "key_code": "6",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "a"
            },
            "to": [
                {
                    "key_code": "6"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "s"
            },
            "to": [
                {
                    "key_code": "7",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "s"
            },
            "to": [
                {
                    "key_code": "7"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "d"
            },
            "to": [
                {
                    "key_code": "8",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "d"
            },
            "to": [
                {
                    "key_code": "8"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "f"
            },
            "to": [
                {
                    "key_code": "9",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "f"
            },
            "to": [
                {
                    "key_code": "9"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "g"
            },
            "to": [
                {
                    "key_code": "0",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "g"
            },
            "to": [
                {
                    "key_code": "0"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "z"
            },
            "to": [
                {
                    "key_code": "hyphen",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "z"
            },
            "to": [
                {
                    "key_code": "hyphen"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "x"
            },
            "to": [
                {
                    "key_code": "equal_sign",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "x"
            },
            "to": [
                {
                    "key_code": "equal_sign"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "v"
            },
            "to": [
                {
                    "key_code": "open_bracket",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "v"
            },
            "to": [
                {
                    "key_code": "open_bracket"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "b"
            },
            "to": [
                {
                    "key_code": "close_bracket",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "b"
            },
            "to": [
                {
                    "key_code": "close_bracket"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline_sign",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "c"
            },
            "to": [
                {
                    "key_code": "grave_accent_and_tilde",
                    "modifiers": "left_shift"
                }
            ],
            "type": "basic"
        },
        {
            "conditions": [
                {
                    "name": "num_keyline",
                    "type": "variable_if",
                    "value": 1
                }
            ],
            "from": {
                "key_code": "c"
            },
            "to": [
                {
                    "key_code": "grave_accent_and_tilde"
                }
            ],
            "type": "basic"
        }
    ]
}