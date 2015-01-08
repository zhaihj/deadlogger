import structs/[ArrayList,HashMap]
import text/StringTokenizer

import [Level, Handler]

NoSuchLoggerError: class extends Exception {
    init: func ~withMsg (.message) {
        super(message)
    }
}

Logger: class {
    path: String
    subloggers: HashMap<String, Logger>
    handlers: ArrayList<Handler>
    parent: Logger

    init: func ~withParent (=path, =parent) {
        subloggers = HashMap<String, Logger> new()
        handlers = ArrayList<Handler> new()
    }

    init: func ~withoutParent (.path) {
        init(path, null)
    }

    getSubLogger: func (path: String, create: Bool) -> Logger {
        if(path contains?('.')) {
            idx := path indexOf('.')
            first := path substring(0, idx)
            rest := path substring(idx + 1, path length())
            return getSubLogger(first) getSubLogger(rest)
        } else {
            if(!subloggers contains?(path)) {
                if(!create) {
                    NoSuchLoggerError new("No such logger: '%s'" format(path)) throw()
                } else {
                    logger := Logger new(path, this)
                    subloggers put(path, logger)
                }
            }
            return subloggers get(path)
        }
    }

    attachHandler: func (handler: Handler) {
        handlers add(handler)
    }

    getSubLogger: func ~alwaysCreate (path: String) -> Logger {
        getSubLogger(path, true)
    }

    log: func (level: Int, emitter: Logger, msg: String) {
        accepted := false
        for(handler: Handler in handlers) {
            if(handler handle(this, level, emitter, msg)) {
                accepted = true
            }
        }
        if(!accepted) {
            if(parent) {
                parent log(level, emitter, msg)
            } else {
                /* TODO: lost! */
            }
        }
    }

    log: func ~emit (level: Int, msg: String) {
        log(level, this, msg)
    }

    debug: func (msg: String) {
        log(Level debug, msg)
    }

    info: func (msg: String) {
        log(Level info, msg)
    }

    warn: func (msg: String) {
        log(Level warn, msg)
    }

    error: func (msg: String) {
        log(Level error, msg)
    }

    critical: func (msg: String) {
        log(Level critical, msg)
    }
}
