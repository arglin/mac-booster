```json
{
    "title": "[Enter] == left(ctl+opt+shift) | Enter if alone",
    "rules": [
        {
            "description": "[Enter] == left(ctl+opt+shift) | Enter if alone",
            "manipulators": [
                {
                    "from": {
                        "key_code": "return_or_enter",
                        "modifiers": {
                            "optional": [
                                "any"
                            ]
                        }
                    },
                    "to": [
                        {
                            "key_code": "left_control",
                            "modifiers": [
                                "left_control",
                                "left_option",
                                "left_shift"
                            ],
                            "lazy": true
                        }
                    ],
                    "to_if_alone": [
                        {
                            "key_code": "return_or_enter"
                        }
                    ],
                    "type": "basic"
                }
            ]
        }
    ]
}
```