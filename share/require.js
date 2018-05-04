(function(resolveModule, requireNative){

    var cache = {};

    function require (moduleName) {

        // build-in
        var module = requireNative(moduleName);
        if (module) return module;

        // js module
        var moduleFile = resolveModule(moduleName);
        if (!moduleFile) return;

        // return from cache
        if (cache[moduleFile])
            return cache[moduleFile];

        // load module
        var module = {
            id: moduleFile,
            exports: {}
        };

        cache[moduleFile] = module;

    };

})
