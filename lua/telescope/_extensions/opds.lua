opds = require('telescope-opds')

return require('telescope').register_extension {
    exports = {
        browse = opds.browse
    }
}
