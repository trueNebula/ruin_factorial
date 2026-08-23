package logger

import "base:runtime"
import "core:debug/trace"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:terminal/ansi"
import "core:time"

@(private = "file")
tracker: trace.Tracking_Allocator

@(private = "file")
LOG_FOLDER_PATH :: "logs/"
@(private = "file")
FILE_HANDLE: ^os.File

@(private = "file")
PRINT_MARK :: "[LOG]:"
@(private = "file")
DEBUG_MARK :: "[DEBUG]:"
@(private = "file")
WARN_MARK :: "[WARN]:"
@(private = "file")
ERR_MARK :: "[ERR]:"

@(private = "file")
PRINT_COL :: ansi.FG_BLUE
@(private = "file")
DEBUG_COL :: ansi.FG_CYAN
@(private = "file")
WARN_COL :: ansi.FG_YELLOW
@(private = "file")
ERR_COL :: ansi.FG_RED

@(private = "file")
BOLD :: ansi.CSI + ansi.BOLD + ";"
@(private = "file")
MID :: ansi.CSI + ansi.RESET + ";"
@(private = "file")
END :: ansi.CSI + ansi.RESET + ansi.SGR

@(private = "file")
LogLevel :: enum {
	PRINT,
	DEBUG,
	WARNING,
	ERROR,
}

Init :: proc() {
	trace.tracking_allocator_init(&tracker, context.allocator)

	when ODIN_DEBUG {
		return
	}

	/* Dir check */
	if dir, err := os.open(LOG_FOLDER_PATH); err != nil {
		os.make_directory(LOG_FOLDER_PATH)
	}

	now := time.now()
	hmsBuf: [time.MIN_HMS_LEN]u8
	dmyBuf: [time.MIN_YYYY_DATE_LEN]u8
	hmsStr := time.time_to_string_hms(now, hmsBuf[:])
	dmyStr := time.to_string_dd_mm_yyyy(now, dmyBuf[:])
	path := strings.concatenate({LOG_FOLDER_PATH, hmsStr, "_", dmyStr, "_log.txt"})
	defer delete(path)
	handle, err := os.create(path)

	if (err != os.General_Error.None) {
		fmt.println("Unable to open log file to write to!", err)
		return
	}

	FILE_HANDLE = handle
}

Shutdown :: proc() {
	trace.tracking_allocator_destroy(&tracker)
	if (FILE_HANDLE != nil) {
		os.close(FILE_HANDLE)
	}
}

Print :: proc(format: string, args: ..any) {
	baseLog(format, ..args, level = .PRINT)
}

Debug :: proc(format: string, args: ..any) {
	baseLog(format, ..args, level = .DEBUG)
}

Warn :: proc(format: string, args: ..any) {
	baseLog(format, ..args, level = .WARNING)
}

Err :: proc(format: string, args: ..any, panic := true) {
	baseLog(format, ..args, level = .ERROR, panic = panic)
}

@(private = "file")
baseLog :: proc(format: string, args: ..any, level: LogLevel = .PRINT, panic := false) {
	mark, col: string

	switch level {
	case .PRINT:
		mark = PRINT_MARK
		col = PRINT_COL
	case .DEBUG:
		mark = DEBUG_MARK
		col = DEBUG_COL
	case .WARNING:
		mark = WARN_MARK
		col = WARN_COL
	case .ERROR:
		mark = ERR_MARK
		col = ERR_COL
		panic := true
	}

	baseString := fmt.tprintfln(format, ..args)
	string := strings.concatenate({mark, " ", baseString})
	defer delete(string)
	stringData := transmute([]byte)(string)

	if FILE_HANDLE != nil {
		os.write(FILE_HANDLE, stringData)
	}

	fmt.print(BOLD, col, ansi.SGR, mark, " " + MID + ansi.SGR, baseString, END, sep = "")

	traceCnt := level == .ERROR ? -1 : 2
	printTrace(traceCnt)

	if panic {
		Shutdown()
		runtime.trap()
	}
}

@(private = "file")
printTrace :: proc(lines: int) {
	context.allocator = trace.tracking_allocator(&tracker)
	capture := trace.capture(skip = 3)
	locations, err := trace.resolve(capture)

	if err != nil {
		fmt.eprintfln("Error getting trace: %v", err)
	}

	sb: strings.Builder
	strings.builder_init(&sb)
	defer strings.builder_destroy(&sb)

	for location, i in locations {
		if i == lines {
			break
		}

		fmt.sbprintf(&sb, "%s#%v %v at %v", "\t", i, location.procedure, location.file_path)
		if location.line > 0 {
			when ODIN_ERROR_POS_STYLE == .Default {
				fmt.sbprintf(&sb, "(%v", location.line)
				if location.column > 0 {
					fmt.sbprintf(&sb, ":%v)", location.column)
				} else {
					fmt.sbprint(&sb, ")")
				}
			} else when ODIN_ERROR_POS_STYLE == .Unix {
				fmt.sbprintf(&sb, ":%v", location.line)
				if location.column > 0 {
					fmt.sbprintf(&sb, ":%v", location.column)
				}
			} else {
				#panic("unhandled ODIN_ERROR_POS_STYLE")
			}
		}

		fmt.sbprintln(&sb)
	}

	traceStr := strings.to_string(sb)

	fmt.eprint(traceStr)
	if FILE_HANDLE != nil {
		os.write(FILE_HANDLE, transmute([]byte)traceStr)
	}

	trace.locations_destroy(locations)
}
