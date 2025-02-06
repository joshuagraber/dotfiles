local status_ok, feline = pcall(require, "feline")
if not status_ok then
    return
end

-- Basic feline setup without catppuccin dependency
feline.setup({
    components = {
        active = {},
        inactive = {},
    },
})

