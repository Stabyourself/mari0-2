Component = class("Component")

function Component:validationError(s)
    error(string.format(
[[Component argument error: %s
In Component "%s"
Of ActorTemplate "%s"]],
    s, self.class, self.actor.actorTemplate.name))
end

function Component:initialize(actor, args)
    self.actor = actor

    -- load args if any
    if self.argList then
        for _, arg in ipairs(self.argList) do
            local name = arg[1]
            local validations = arg[2]:split("|")
            local default = arg[3]
            local value = args[name]

            -- validations
            -- Check whether the variable is perhaps required and not supplied
            if inTable(validations, "required") then
                if value == nil then
                    self:validationError(string.format([["%s" is required]], name))
                end
            end

            if value ~= nil then -- if a value is supplied, it must pass validation
                local falseable = inTable(validations, "falseable")

                for _, validation in ipairs(validations) do
                    -- types
                    if not falseable or value ~= false then
                        if validation == "table" then
                            if type(value) ~= "table" then
                                self:validationError(string.format([["%s" should be a table]], name))
                            end

                        elseif validation == "number" then
                            if type(value) ~= "number" then
                                self:validationError(string.format([["%s" should be a number]], name))
                            end

                        elseif validation == "string" then
                            if type(value) ~= "string" then
                                self:validationError(string.format([["%s" should be a string]], name))
                            end

                        elseif validation == "boolean" then
                            if type(value) ~= "boolean" then
                                self:validationError(string.format([["%s" should be a boolean]], name))
                            end

                        elseif validation == "palette" then
                            if type(value) ~= "table" then
                                self:validationError(string.format([["%s" should be a palette table]], name))
                            end

                            value = convertPalette(value)
                        end
                    end
                end
            end

            self[name] = value

            if self[name] == nil and default ~= nil then
                if type(default) == "function" then
                    self[name] = default(self)
                else
                    self[name] = default
                end
            end
        end
    end
end
