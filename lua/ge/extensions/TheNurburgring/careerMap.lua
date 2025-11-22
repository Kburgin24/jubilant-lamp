return {
    onGetMaps = function()
        -- To what I understand this allows beam to open derby as a map
        extensions.hook("returnCompatibleMap", {
            ["ks_nord"] = "Nürburgring Nordschleife",
            ["derby"] = "Derby"
        })
    end
}