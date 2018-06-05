local hurtsByContact = class("misc.hurtsByContact", Component)

hurtsByContact.argList = {
    {"left", "boolean", false},
    {"right", "boolean", false},
    {"top", "boolean", false},
    {"bottom", "boolean", false},
    {"onlyWhenMoving", "boolean", false},
}

return hurtsByContact
