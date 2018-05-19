local hurtsByContact = class("misc.hurtsByContact")

function hurtsByContact:initialize(actor, args)
    self.left = args.left or false
    self.right = args.right or false
    self.top = args.top or false
    self.bottom = args.bottom or false

    self.onlyWhenMoving = args.onlyWhenMoving or false
end

return hurtsByContact