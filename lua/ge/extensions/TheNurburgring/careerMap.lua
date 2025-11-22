return {
    onGetMaps = function()
        -- Register compatible map identifiers. Add `derby` so the career map
        -- extension will recognize a level whose identifier is `derby`.
        extensions.hook("returnCompatibleMap", {
            ["ks_nord"] = "Nürburgring Nordschleife",
            ["derby"] = "Derby"
        })
    end
}