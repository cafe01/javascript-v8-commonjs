(function(global) {
    "use strict";

    var modules = {},
    callStack = [];

    global.require = function(id) {

        // native module
        var native = requireNative(id);
        if (native) {
            return native;
        }

        // resolve file
        var file = resolveModule(id);
        if (!file) {
            throw "Can't find module '" + id + "'"
        }

        // already cached
        if (modules[file]) {
            return modules[file].exports;
        }

        // load module
        var moduleSource = readFile(file),
        module = { exports: {} };

        (function(require, module, exports) { eval(moduleSource) })(global.require, module, module.exports);

        // cache and return
        module.__filename = file;
        modules[file] = module;
        return modules[file].exports;
    }

})(this)
