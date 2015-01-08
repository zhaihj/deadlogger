import text/[StringTemplate]
import structs/HashMap
import os/Time
import [Logger, Level, Handler]

Formatter: abstract class {
    format: abstract func (handler: Handler, logger: Logger, level: Int, emitter: Logger, msg: String) -> String
}

NiceFormatter: class extends Formatter {
    template: String

    init: func ~withTemplate (=template) {}

    init: func {
        template = "[{{dateTime}}] [{{level}}] [{{emitter}}] {{msg}}"
    }

    format: func (handler: Handler, logger: Logger, level: Int, emitter: Logger, msg: String) -> String {
        map := HashMap<String, String> new()
        map put("level", Level format(level)) .put("msg", msg) .put("emitter", emitter path) .put("dateTime", Time dateTime())
        return template formatTemplate(map)
    }
}

ColoredFormatter: class extends Formatter {
    inner: Formatter
    init: func (=inner) {}

    format: func (handler: Handler, logger: Logger, level: Int, emitter: Logger, msg: String) -> String {
        color: Int = match level {
            case Level debug => 36
            case Level info => 32
            case Level warn => 33
            case Level error => 35
            case Level critical => 31
            case => 0
        }
        buffer := Buffer new()
        if(color) {
            buffer append("\033[%dm" format(color)) /* I'd REALLY like to use os/Terminal here, but it can only print */
        }
        buffer append(inner format(handler, logger, level, emitter, msg))
        if(color) {
            buffer append("\033[0m")
        }
        return buffer toString()
    }
}
